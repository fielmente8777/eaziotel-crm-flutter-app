import 'package:flutter/material.dart';

class WhatsappStatusIcon extends StatelessWidget {
  final String? status;

  const WhatsappStatusIcon({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status?.toLowerCase()) {
      case 'read':
        return const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.blue,
        );

      case 'delivered':
        return Icon(
          Icons.done_all,
          size: 14,
          color: Colors.grey.shade600,
        );

      case 'sent':
        return Icon(
          Icons.done,
          size: 14,
          color: Colors.grey.shade600,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}