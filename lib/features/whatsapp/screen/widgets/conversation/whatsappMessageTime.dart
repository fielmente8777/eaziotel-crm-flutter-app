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
      // Incoming messages ke liye status tick nahi dikhta
      return Text(
        time,
        style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
      );
    }

    // Outgoing message -> time + status icon
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(time, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
        const SizedBox(width: 3),

        // status yahan se aata hai — jab bhi parent widget
        // (WhatsappTextBubble) ko naya status value milega,
        // ye poora widget rebuild hoga aur icon change ho jayega
        WhatsappStatusIcon(status: status),
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

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
