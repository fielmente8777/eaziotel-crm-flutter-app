import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';

class WhatsappMessageItem {
  final String? id;
  final String? messageId;
  final String? body;
  final String? createdAt;
  final String? direction;
  final String? sender;
  final String? status;
  final String? messageType;
  final dynamic media;

  // Interactive message
  final WhatsappInteractiveModel? interactive;

  const WhatsappMessageItem({
    this.id,
    this.messageId,
    this.body,
    this.createdAt,
    this.direction,
    this.sender,
    this.status,
    this.messageType,
    this.media,
    this.interactive,
  });

  // ============================================================
  // API MESSAGE
  // ============================================================
  factory WhatsappMessageItem.fromApi(WhatsappMessageModel message) {
    return WhatsappMessageItem(
      id: message.id,
      messageId: message.messageId,
      body: message.body,
      createdAt: message.createdAt,
      direction: message.direction,
      sender: message.sender,
      status: message.status,
      messageType: message.messageType,
      media: message.media,
      interactive: message.interactive,
    );
  }

  // ============================================================
  // SOCKET MESSAGE
  // ============================================================
  factory WhatsappMessageItem.fromSocket(WhatsappSocketMessageModel message) {
    return WhatsappMessageItem(
      id: message.id,
      messageId: message.messageId,
      body: message.body,
      createdAt: message.createdAt,
      direction: message.direction,
      sender: message.sender,
      status: message.status,
      messageType: message.messageType,
      media: message.media,

      // Socket model mein interactive ho to uncomment/use:
      // interactive: message.interactive,
    );
  }

  // ============================================================
  // UNIQUE KEY
  // ============================================================
  String get uniqueKey {
    if (messageId != null && messageId!.isNotEmpty) {
      return 'message_$messageId';
    }

    if (id != null && id!.isNotEmpty) {
      return 'id_$id';
    }

    return 'fallback_${createdAt}_${body}';
  }

  // ============================================================
  // INCOMING / OUTGOING
  // ============================================================
  bool get isIncoming {
    return direction == 'inbound' || sender == 'contact';
  }

  // ============================================================
  // IMAGE
  // ============================================================
  bool get isImage {
    return messageType?.toLowerCase() == 'image' || media != null;
  }

  // ============================================================
  // INTERACTIVE
  // ============================================================
  bool get isInteractive {
    return messageType?.toLowerCase() == 'interactive' && interactive != null;
  }
}
