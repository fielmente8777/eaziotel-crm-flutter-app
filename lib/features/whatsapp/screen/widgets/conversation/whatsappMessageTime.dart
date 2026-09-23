import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappStatusIcon.dart';
import 'package:flutter/material.dart';

class WhatsappMessageTime extends StatelessWidget {
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const WhatsappMessageTime({
    super.key,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(createdAt);

    if (isIncoming) {
      return Text(
        time,
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey.shade600,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 3),
        WhatsappStatusIcon(
          status: status,
        ),
      ],
    );
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return '';
    }

    final local = date.toLocal();

    final hour =
        local.hour % 12 == 0
            ? 12
            : local.hour % 12;

    final minute =
        local.minute.toString().padLeft(2, '0');

    final period =
        local.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}