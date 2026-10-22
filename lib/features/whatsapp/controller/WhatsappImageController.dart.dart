import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

enum WhatsappMediaType { image, video, audio, document, sticker, unknown }

class WhatsappMediaController extends GetxController {
  static const String _baseUrl =
      'https://gian-1eve.onrender.com/api/v1/whatsapp/media';

  final String messageId;
  final dynamic media;
  final String? ndid;
  final WhatsappMediaType type;

  WhatsappMediaController({
    required this.messageId,
    required this.media,
    required this.ndid,
    required this.type,
  });

  // ------------------------------------------------------------
  // Reactive state
  // ------------------------------------------------------------

  final RxnString localPath = RxnString();
  final RxnString thumbnailPath = RxnString();

  final RxBool isDownloading = false.obs;
  final RxBool isThumbnailDownloading = false.obs;

  final RxDouble progress = 0.0.obs;

  bool get isDownloaded =>
      localPath.value != null && localPath.value!.isNotEmpty;

  bool get hasThumbnail =>
      thumbnailPath.value != null && thumbnailPath.value!.isNotEmpty;

  // ------------------------------------------------------------
  // Media info
  // ------------------------------------------------------------

  /// Reads the value whether media is a Map or a typed model (WhatsappMediaModel).
  String? _read(String key) {
    final m = media;
    if (m == null) return null;

    try {
      dynamic value;

      if (m is Map) {
        value = m[key];
      } else {
        switch (key) {
          case 'id':
            value = m.id;
            break;
          case 'mimeType':
            value = m.mimeType;
            break;
          case 'filename':
            value = m.filename;
            break;
        }
      }

      final text = value?.toString();
      if (text == null || text.isEmpty || text == 'null') return null;
      return text;
    } catch (_) {
      return null;
    }
  }

  String? get mediaId => _read('id');

  bool get _canBuildUrl {
    final id = mediaId;
    return id != null && id.isNotEmpty && ndid != null && ndid!.isNotEmpty;
  }

  String? get mediaUrl =>
      _canBuildUrl ? '$_baseUrl/$mediaId/?ndid=$ndid' : null;

  bool get _supportsThumbnail =>
      type == WhatsappMediaType.image ||
      type == WhatsappMediaType.video ||
      type == WhatsappMediaType.sticker;

  String? get thumbnailUrl => (_canBuildUrl && _supportsThumbnail)
      ? '$_baseUrl/$mediaId/thumbnail/?ndid=$ndid'
      : null;

  /// The document's original name (if the API gives it), otherwise a default.
  String get fileName {
    final name = _read('filename') ?? _read('file_name') ?? _read('name');
    if (name != null && name.trim().isNotEmpty) return name;
    return 'Document.$extension';
  }

  // ------------------------------------------------------------
  // Extension
  // ------------------------------------------------------------

  String get extension {
    switch (type) {
      case WhatsappMediaType.image:
        return _extensionFromMedia('jpg');
      case WhatsappMediaType.video:
        return _extensionFromMedia('mp4');
      case WhatsappMediaType.audio:
        return _extensionFromMedia('mp3');
      case WhatsappMediaType.document:
        return _extensionFromMedia('pdf');
      case WhatsappMediaType.sticker:
        return _extensionFromMedia('webp');
      case WhatsappMediaType.unknown:
        return _extensionFromMedia('bin');
    }
  }

  String _extensionFromMedia(String fallback) {
    final mimeType = _read('mimeType') ?? _read('mime_type') ?? _read('type');

    {
      if (mimeType != null && mimeType.contains('/')) {
        // "audio/ogg; codecs=opus" -> "ogg"
        final subtype = mimeType.split('/').last.split(';').first.trim();

        if (subtype.isNotEmpty) {
          switch (subtype) {
            case 'jpeg':
              return 'jpg';
            case 'x-m4a':
            case 'mp4a-latm':
              return 'm4a';
            case 'mpeg':
              return type == WhatsappMediaType.audio ? 'mp3' : 'mpeg';
            case 'quicktime':
              return 'mov';
            case 'msword':
              return 'doc';
            case 'vnd.ms-excel':
              return 'xls';
            case 'vnd.ms-powerpoint':
              return 'ppt';
            case 'plain':
              return 'txt';
            case 'vnd.openxmlformats-officedocument.wordprocessingml.document':
              return 'docx';
            case 'vnd.openxmlformats-officedocument.spreadsheetml.sheet':
              return 'xlsx';
            case 'vnd.openxmlformats-officedocument.presentationml.presentation':
              return 'pptx';
            default:
              return subtype;
          }
        }
      }

      final name = _read('filename') ?? _read('file_name') ?? _read('name');

      if (name != null && name.contains('.')) {
        return name.split('.').last.toLowerCase();
      }
    }

    return fallback;
  }

  // ------------------------------------------------------------
  // File names
  // ------------------------------------------------------------

  String get safeMessageId {
    final value = messageId.isEmpty ? 'unknown' : messageId;
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  String get _filePrefix => 'whatsapp_${type.name}';

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/${_filePrefix}_$safeMessageId.$extension');
  }

  Future<File> _thumbnailFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/${_filePrefix}_thumbnail_$safeMessageId.jpg');
  }

  // ------------------------------------------------------------
  // Init
  // ------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    await checkDownloaded();

    if (thumbnailUrl == null) return;

    await checkThumbnail();

    // If the image is already fully downloaded, no thumbnail is needed.
    final needThumb = !(type == WhatsappMediaType.image && isDownloaded);

    if (thumbnailPath.value == null && needThumb) {
      await downloadThumbnail();
    }
  }

  // ------------------------------------------------------------
  // Cache check
  // ------------------------------------------------------------

  Future<void> checkDownloaded() async {
    try {
      final file = await _localFile();
      if (await file.exists() && await file.length() > 0) {
        localPath.value = file.path;
      }
    } catch (e) {
      debugPrint('MEDIA CACHE ERROR: $e');
    }
  }

  Future<void> checkThumbnail() async {
    try {
      final file = await _thumbnailFile();
      if (await file.exists() && await file.length() > 0) {
        thumbnailPath.value = file.path;
      }
    } catch (e) {
      debugPrint('THUMBNAIL CACHE ERROR: $e');
    }
  }

  // ------------------------------------------------------------
  // Thumbnail download
  // ------------------------------------------------------------

  Future<void> downloadThumbnail() async {
    if (isThumbnailDownloading.value) return;

    final url = thumbnailUrl;
    if (url == null || url.isEmpty) return;

    final client = http.Client();

    try {
      isThumbnailDownloading.value = true;

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
    } catch (e) {
      debugPrint('THUMBNAIL DOWNLOAD ERROR: $e');
    } finally {
      isThumbnailDownloading.value = false;
      client.close();
    }
  }

  // ------------------------------------------------------------
  // Full media download
  // ------------------------------------------------------------

  Future<void> download() async {
    if (isDownloading.value) return;

    final url = mediaUrl;

    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Media',
        'Media URL not available',
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

      final response = await client.send(http.Request('GET', Uri.parse(url)));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final file = await _localFile();
      tempFile = File('${file.path}.part');

      if (await tempFile.exists()) await tempFile.delete();

      sink = tempFile.openWrite();

      final total = response.contentLength ?? 0;
      int received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) progress.value = received / total;
      }

      await sink.flush();
      await sink.close();
      sink = null;

      if (await file.exists()) await file.delete();
      await tempFile.rename(file.path);

      localPath.value = file.path;
      progress.value = 1.0;
    } catch (e) {
      debugPrint('MEDIA DOWNLOAD ERROR: $e');

      try {
        await sink?.close();
      } catch (_) {}

      if (tempFile != null) {
        try {
          if (await tempFile.exists()) await tempFile.delete();
        } catch (_) {}
      }

      progress.value = 0.0;

      Get.snackbar(
        'Download failed',
        'Unable to download ${type.name}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      client.close();
      isDownloading.value = false;
    }
  }

  // ------------------------------------------------------------
  // Delete
  // ------------------------------------------------------------

  Future<void> deleteLocalFile() async {
    try {
      final file = await _localFile();
      if (await file.exists()) await file.delete();
      localPath.value = null;
      progress.value = 0.0;
    } catch (e) {
      debugPrint('DELETE MEDIA ERROR: $e');
    }
  }

  Future<void> deleteThumbnail() async {
    try {
      final file = await _thumbnailFile();
      if (await file.exists()) await file.delete();
      thumbnailPath.value = null;
    } catch (e) {
      debugPrint('DELETE THUMBNAIL ERROR: $e');
    }
  }
}
