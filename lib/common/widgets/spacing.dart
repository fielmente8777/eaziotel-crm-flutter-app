import 'package:flutter/material.dart';

class VSpace extends StatelessWidget {
  final double height;

  const VSpace({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}

class HSpace extends StatelessWidget {
  final double width;

  const HSpace({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }
}