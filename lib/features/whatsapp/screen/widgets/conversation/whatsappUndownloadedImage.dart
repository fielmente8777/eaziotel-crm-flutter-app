import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/WhatsappImageController.dart.dart';

class WhatsappUndownloadedImage extends StatelessWidget {
  final WhatsappImageController controller;
  final double maxWidth;
  final double maxHeight;

  const WhatsappUndownloadedImage({
    super.key,
    required this.controller,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final downloading = controller.isDownloading.value;
      final progress = controller.progress.value;

      final url = controller.imageUrl;

      return GestureDetector(
        onTap: downloading ? null : controller.download,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: maxWidth,
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // =========================
                // IMAGE PREVIEW
                // =========================
                if (url != null && url.isNotEmpty)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Image.network(
                      url,

                      // Important:
                      // Flutter screen par image ko is size mein decode karega
                      cacheWidth: (maxWidth * 2).toInt(),
                      cacheHeight: 440,

                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                      gaplessPlayback: true,

                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(color: Colors.grey.shade300),

                // Dark overlay
                Container(color: Colors.black26),

                // =========================
                // DOWNLOAD BUTTON
                // =========================
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: downloading
                        ? Padding(
                            padding: const EdgeInsets.all(11),
                            child: CircularProgressIndicator(
                              value: progress > 0 ? progress : null,
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 29,
                          ),
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
