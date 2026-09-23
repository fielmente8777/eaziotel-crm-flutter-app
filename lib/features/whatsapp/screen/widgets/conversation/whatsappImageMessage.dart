import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappFullScreenImage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappUndownloadedImage.dart';

class WhatsappImageMessage extends StatelessWidget {
  final String messageId;
  final dynamic media;
  final String? body;
  final String? createdAt;
  final bool isIncoming;
  final String? ndid;

  const WhatsappImageMessage({
    super.key,
    required this.messageId,
    required this.media,
    required this.body,
    required this.createdAt,
    required this.isIncoming,
    required this.ndid,
  });

  String get tag => 'whatsapp_image_$messageId';

  @override
  Widget build(BuildContext context) {
    return GetX<WhatsappImageController>(
      tag: tag,

      init: WhatsappImageController(
        messageId: messageId,
        media: media,
        ndid: ndid,
      ),

      builder: (controller) {
        final path = controller.localPath.value;

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
                  WhatsappUndownloadedImage(
                    controller: controller,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
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
