import 'dart:io';

import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
 import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappFullScreenImage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMediaPreview.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappImageMessage extends StatelessWidget {
  final String messageId;
  final dynamic media;
  final String? body;
  final String? createdAt;
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
                  GestureDetector(
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
                        constraints: const BoxConstraints(maxHeight: maxHeight),
                        child: Image.file(
                          File(path),
                          width: maxWidth,
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
                  )
                else
                  WhatsappMediaPreview(
                    controller: controller,
                    width: maxWidth,
                    height: type == WhatsappMediaType.sticker ? 170 : 220,
                    onTap: downloading ? null : controller.download,
                  ),
                const SizedBox(height: 2),
                WhatsappMessageTime(
                  createdAt: createdAt,
                  status: null,
                  isIncoming: isIncoming,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
