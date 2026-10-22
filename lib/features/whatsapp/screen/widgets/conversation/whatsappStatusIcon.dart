import 'package:flutter/material.dart';

class WhatsappStatusIcon extends StatelessWidget {
  final String? status;

  const WhatsappStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _buildIcon(),
    );
  }

  Widget _buildIcon() {
    switch (status?.toLowerCase()) {
      case 'read':
        return const Icon(
          Icons.done_all,
          key: ValueKey('read'),
          size: 14,
          color: Colors.blue,
        );

      case 'delivered':
        return Icon(
          Icons.done_all,
          key: const ValueKey('delivered'),
          size: 14,
          color: Colors.grey.shade600,
        );

      case 'sent':
        return Icon(
          Icons.done,
          key: const ValueKey('sent'),
          size: 14,
          color: Colors.grey.shade600,
        );

      // pending / failed / null -> no icon
      case 'failed':
        return const Icon(
          Icons.error_outline,
          key: ValueKey('failed'),
          size: 14,
          color: Colors.red,
        );

      default:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }
}
