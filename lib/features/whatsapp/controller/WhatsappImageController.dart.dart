import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class WhatsappImageController extends GetxController {
  final String messageId;
  final dynamic media;
  final String? ndid;

  WhatsappImageController({
    required this.messageId,
    required this.media,
    required this.ndid,
  });

  final RxnString localPath = RxnString();
  final RxnString thumbnailPath = RxnString();

  final RxBool isDownloading = false.obs;
  final RxBool isThumbnailDownloading = false.obs;

  final RxDouble progress = 0.0.obs;

  String? get mediaId {
    if (media is Map) {
      return media['id']?.toString();
    }

    return null;
  }

  String? get imageUrl {
    final id = mediaId;

    if (id == null || id.isEmpty) return null;
    if (ndid == null || ndid!.isEmpty) return null;

    return 'https://gian-1eve.onrender.com/api/v1/whatsapp/media/$id/?ndid=$ndid';
  }

  String? get thumbnailUrl {
    final id = mediaId;

    if (id == null || id.isEmpty) return null;
    if (ndid == null || ndid!.isEmpty) return null;

    return 'https://gian-1eve.onrender.com/api/v1/whatsapp/media/$id/thumbnail/?ndid=$ndid';
  }

  @override
  void onInit() {
    super.onInit();

    _initializeCache();
  }

  Future<void> _initializeCache() async {
    await checkDownloaded();

    // If thumbnail already exists locally,
    // don't download it again.
    await checkThumbnail();

    if (thumbnailPath.value == null) {
      await downloadThumbnail();
    }
  }

  Future<File> _localFile() async {
    final directory = await getApplicationDocumentsDirectory();

    var safeMessageId = messageId;

    if (safeMessageId.isEmpty) {
      safeMessageId = 'unknown';
    }

    safeMessageId = safeMessageId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    return File('${directory.path}/whatsapp_image_$safeMessageId.jpg');
  }

  Future<File> _thumbnailFile() async {
    final directory = await getApplicationDocumentsDirectory();

    var safeMessageId = messageId;

    if (safeMessageId.isEmpty) {
      safeMessageId = 'unknown';
    }

    safeMessageId = safeMessageId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    return File('${directory.path}/whatsapp_thumbnail_$safeMessageId.jpg');
  }

  Future<void> checkDownloaded() async {
    try {
      final file = await _localFile();

      if (await file.exists()) {
        final size = await file.length();

        if (size > 0) {
          localPath.value = file.path;

          debugPrint('IMAGE CACHE FOUND: ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('IMAGE CACHE ERROR: $e');
    }
  }

  Future<void> checkThumbnail() async {
    try {
      final file = await _thumbnailFile();

      if (await file.exists()) {
        final size = await file.length();

        if (size > 0) {
          thumbnailPath.value = file.path;

          debugPrint('THUMBNAIL CACHE FOUND: ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('THUMBNAIL CACHE ERROR: $e');
    }
  }

  Future<void> downloadThumbnail() async {
    if (isThumbnailDownloading.value) {
      return;
    }

    final url = thumbnailUrl;

    if (url == null || url.isEmpty) {
      return;
    }

    final client = http.Client();

    try {
      isThumbnailDownloading.value = true;

      debugPrint('DOWNLOADING THUMBNAIL: $url');

      final response = await client.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Thumbnail HTTP ${response.statusCode}');
      }

      if (response.bodyBytes.isEmpty) {
        throw Exception('Thumbnail response is empty');
      }

      final file = await _thumbnailFile();

      await file.writeAsBytes(response.bodyBytes, flush: true);

      thumbnailPath.value = file.path;

      debugPrint('THUMBNAIL SAVED: ${file.path}');
    } catch (e) {
      debugPrint('THUMBNAIL DOWNLOAD ERROR: $e');
    } finally {
      isThumbnailDownloading.value = false;

      client.close();
    }
  }

  Future<void> download() async {
    if (isDownloading.value) {
      return;
    }

    final url = imageUrl;

    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Image',
        'Image URL not available',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final client = http.Client();

    File? tempFile;
    IOSink? sink;

    try {
      isDownloading.value = true;
      progress.value = 0.0;

      debugPrint('DOWNLOADING FULL IMAGE: $url');

      final request = http.Request('GET', Uri.parse(url));

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final file = await _localFile();

      tempFile = File('${file.path}.part');

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      sink = tempFile.openWrite();

      final total = response.contentLength ?? 0;

      int received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);

        received += chunk.length;

        if (total > 0) {
          progress.value = received / total;
        }
      }

      await sink.flush();
      await sink.close();

      sink = null;

      if (await file.exists()) {
        await file.delete();
      }

      await tempFile.rename(file.path);

      localPath.value = file.path;

      progress.value = 1.0;

      debugPrint('FULL IMAGE SAVED: ${file.path}');
    } catch (e) {
      debugPrint('FULL IMAGE DOWNLOAD ERROR: $e');

      try {
        await sink?.close();
      } catch (_) {}

      if (tempFile != null) {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (_) {}
      }

      progress.value = 0.0;

      Get.snackbar(
        'Download failed',
        'Unable to download image',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      client.close();

      isDownloading.value = false;
    }
  }
}
