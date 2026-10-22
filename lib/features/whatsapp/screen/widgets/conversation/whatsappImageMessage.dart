import 'dart:io';

import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappFullScreenImage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMediaPreview.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappUploadProgress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappImageMessage extends StatelessWidget {
  final String messageId;
  final dynamic media;
  final String? body;
  final String? createdAt;
  final String? status;
  final bool isIncoming;
  final String? ndid;
  final WhatsappMediaType type; // image ya sticker

  const WhatsappImageMessage({
    super.key,
    required this.messageId,
    required this.media,
    required this.body,
    required this.createdAt,
    required this.isIncoming,
    required this.ndid,
    this.status,
    this.type = WhatsappMediaType.image,
  });

  String get tag => 'whatsapp_${type.name}_$messageId';

  @override
  Widget build(BuildContext context) {
    return GetX<WhatsappMediaController>(
      tag: tag,
      init: WhatsappMediaController(
        messageId: messageId,
        media: media,
        ndid: ndid,
        type: type,
      ),
      builder: (controller) {
        final path = controller.localPath.value;
        final downloading = controller.isDownloading.value;

        final maxWidth = MediaQuery.of(context).size.width * 0.78;
        const maxHeight = 420.0;

        final caption = (body ?? '').trim();

        return Align(
          alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(
              left: isIncoming ? 0 : 40,
              right: isIncoming ? 40 : 0,
              top: 3,
              bottom: 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (path != null && path.isNotEmpty && File(path).existsSync())
                  WhatsappUploadOverlay(
                    messageId: messageId,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                WhatsappFullScreenImage(imagePath: path),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: maxHeight,
                          ),
                          child: Image.file(
                            File(path),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                                size: 38,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  WhatsappMediaPreview(
                    controller: controller,
                    width: maxWidth,
                    height: type == WhatsappMediaType.sticker ? 170 : 220,
                    onTap: downloading ? null : controller.download,
                  ),

                // CAPTION (if text was sent with the image)
                if (caption.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Text(
                        caption,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),

                const SizedBox(height: 2),

                // TIME + STATUS (sent / delivered / read ticks)
                _ImageMessageMeta(
                  createdAt: createdAt,
                  status: status,
                  isIncoming: isIncoming,
                  // temp id = still uploading -> clock icon
                  isPending: messageId.startsWith('temp_'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// MESSAGE META (time + status tick)
// ============================================================

class _ImageMessageMeta extends StatelessWidget {
  final String? createdAt;
  final String? status;
  final bool isIncoming;
  final bool isPending;

  const _ImageMessageMeta({
    required this.createdAt,
    required this.status,
    required this.isIncoming,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(createdAt),
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        if (!isIncoming)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: _ImageStatusIcon(status: status, isPending: isPending),
          ),
      ],
    );
  }
}

class _ImageStatusIcon extends StatelessWidget {
  final String? status;
  final bool isPending;

  const _ImageStatusIcon({required this.status, this.isPending = false});

  @override
  Widget build(BuildContext context) {
    // Upload running -> clock
    if (isPending) {
      return const Icon(Icons.access_time, size: 14, color: Colors.grey);
    }

    final value = status?.toLowerCase();

    if (value == 'read') {
      return const Icon(Icons.done_all, size: 15, color: Color(0xff53bdeb));
    }

    if (value == 'delivered') {
      return const Icon(Icons.done_all, size: 15, color: Colors.grey);
    }

    if (value == 'sent') {
      return const Icon(Icons.done, size: 15, color: Colors.grey);
    }

    if (value == 'failed') {
      return const Icon(Icons.error_outline, size: 15, color: Colors.red);
    }

    return const SizedBox.shrink();
  }
}

String _formatTime(String? value) {
  if (value == null || value.isEmpty) return '';

  final date = DateTime.tryParse(value);
  if (date == null) return '';

  final localDate = date.toLocal();
  final hour = localDate.hour;
  final minute = localDate.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;

  return '$displayHour:$minute $period';
}
