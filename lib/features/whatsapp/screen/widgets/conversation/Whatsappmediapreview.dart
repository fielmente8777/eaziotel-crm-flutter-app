import 'dart:io';
import 'dart:ui';

import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
 import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Common preview for Image / Video / Sticker:
/// thumbnail (blurred if not downloaded) + download / progress / play button.
class WhatsappMediaPreview extends StatelessWidget {
  final WhatsappMediaController controller;
  final double width;
  final double height;
  final bool showPlay;
  final VoidCallback? onTap;

  const WhatsappMediaPreview({
    super.key,
    required this.controller,
    required this.width,
    required this.height,
    this.showPlay = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final downloading = controller.isDownloading.value;
      final progress = controller.progress.value;
      final downloaded = controller.isDownloaded;
      final thumb = controller.thumbnailPath.value;

      final hasThumb =
          thumb != null && thumb.isNotEmpty && File(thumb).existsSync();

      Widget image = hasThumb
          ? Image.file(
              File(thumb),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
            )
          : Container(
              color: Colors.grey.shade300,
              child: Icon(
                showPlay ? Icons.videocam_outlined : Icons.image_outlined,
                color: Colors.grey,
                size: 40,
              ),
            );

      if (!downloaded && hasThumb) {
        image = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: image,
        );
      }

      Widget? overlay;

      if (downloading) {
        overlay = Padding(
          padding: const EdgeInsets.all(11),
          child: CircularProgressIndicator(
            value: progress > 0 ? progress : null,
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        );
      } else if (!downloaded) {
        overlay = const Icon(
          Icons.download_rounded,
          color: Colors.white,
          size: 29,
        );
      } else if (showPlay) {
        overlay = const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36,
        );
      }

      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                image,
                if (!downloaded) Container(color: Colors.black26),
                if (overlay != null)
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: overlay,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}