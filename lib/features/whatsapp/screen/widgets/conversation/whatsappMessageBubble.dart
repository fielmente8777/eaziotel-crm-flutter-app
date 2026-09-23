import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappImageMessage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappInteractiveMessage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageItem.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappTextBubble.dart';
import 'package:flutter/material.dart';

class WhatsappMessageBubble extends StatelessWidget {
  final WhatsappMessageItem message;
  final String? ndid;

  const WhatsappMessageBubble({
    super.key,
    required this.message,
    required this.ndid,
  });

  @override
  Widget build(BuildContext context) {
     // INTERACTIVE
     if (message.isInteractive) {
      return WhatsappInteractiveMessage(
        interactive: message.interactive,
        createdAt: message.createdAt,
        status: message.status,
        isIncoming: message.isIncoming,
      );
    }

     // IMAGE
     if (message.isImage) {
      return WhatsappImageMessage(
        key: ValueKey('image_${message.uniqueKey}'),
        messageId: message.messageId ?? message.id ?? '',
        media: message.media,
        body: message.body,
        createdAt: message.createdAt,
        isIncoming: message.isIncoming,
        ndid: ndid,
      );
    }

     // TEXT
     return WhatsappTextBubble(
      body: message.body ?? '',
      createdAt: message.createdAt,
      status: message.status,
      isIncoming: message.isIncoming,
    );
  }
}
