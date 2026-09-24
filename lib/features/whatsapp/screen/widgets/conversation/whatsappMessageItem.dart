
 import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
 
class WhatsappMessageItem {
  final String? id;
  final String? messageId;
  final String? body;
  final String? createdAt;
  final String? direction;
  final String? sender;
  final String? status;
  final String? messageType;
 
  /// Hamesha Map (ya null) - typed model ho to toJson() se convert hota hai.
  final dynamic media;
  final dynamic location;
  final dynamic contacts;
 
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
    this.location,
    this.contacts,
    this.interactive,
  });
 
  // ============================================================
  // API
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
      media: _normalize(message.media),
      location: _normalize(_readProperty(message, 'location')),
      contacts: _normalize(_readProperty(message, 'contacts')),
      interactive: message.interactive,
    );
  }
 
  // ============================================================
  // SOCKET
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
      media: _normalize(message.media),
      location: _normalize(_readProperty(message, 'location')),
      contacts: _normalize(_readProperty(message, 'contacts')),
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
 
    return 'fallback_${createdAt}_${body}_$messageType';
  }
 
  // ============================================================
  // INCOMING
  // ============================================================
 
  bool get isIncoming {
    return direction?.toLowerCase() == 'inbound' ||
        sender?.toLowerCase() == 'contact';
  }
 
  // ============================================================
  // TYPE
  // ============================================================
 
  String get type => messageType?.toLowerCase().trim() ?? 'unknown';
 
  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio' || type == 'voice';
  bool get isDocument => type == 'document';
  bool get isSticker => type == 'sticker';
  bool get isLocation => type == 'location';
  bool get isContacts => type == 'contacts';
  bool get isInteractive => type == 'interactive';
 
  bool get isUnknown {
    return !isText &&
        !isImage &&
        !isVideo &&
        !isAudio &&
        !isDocument &&
        !isSticker &&
        !isLocation &&
        !isContacts &&
        !isInteractive;
  }
 
  // ============================================================
  // HELPERS
  // ============================================================
 
  /// message.location / message.contacts padhta hai (field na ho to null).
  static dynamic _readProperty(dynamic object, String property) {
    try {
      if (object is Map) return object[property];
 
      switch (property) {
        case 'location':
          return object.location;
        case 'contacts':
          return object.contacts;
      }
    } catch (_) {}
 
    return null;
  }
 
  /// Typed model (WhatsappMediaModel, WhatsappLocationModel,
  /// WhatsappContactModel...) ko Map mein badalta hai, taaki UI aur
  /// media controller ke `is Map` checks kaam karein.
  static dynamic _normalize(dynamic value) {
    if (value == null || value is Map || value is String || value is num) {
      return value;
    }
 
    if (value is List) {
      return value.map(_normalize).toList();
    }
 
    try {
      return value.toJson();
    } catch (_) {
      return value;
    }
  }
}
 
