import 'dart:io';

import 'package:flutter/material.dart';

class WhatsappFullScreenImage extends StatelessWidget {
  final String imagePath;

  const WhatsappFullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                // minScale: 0.8,
                // maxScale: 5.0,
                // boundaryMargin: const EdgeInsets.all(100),
                // panEnabled: true,
                // scaleEnabled: true,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 60,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 2,
              left: 2,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
