import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';

class WhatsappMessageItem {
  final String? id;
  final String? messageId;
  final String? body;
  final String? createdAt;
  final String? updatedAt;
  final String? direction;
  final String? sender;
  final String? status;
  final String? messageType;

  /// Always a Map (or null) - a typed model is converted with toJson().
  final dynamic media;
  final dynamic location;
  final dynamic contacts;

  final WhatsappInteractiveModel? interactive;

  const WhatsappMessageItem({
    this.id,
    this.messageId,
    this.body,
    this.createdAt,
    this.updatedAt,
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
      updatedAt: message.updatedAt,
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
      updatedAt: message.updatedAt,
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
  // COPY WITH (for status updates)
  // ============================================================

  WhatsappMessageItem copyWith({String? status, String? updatedAt}) {
    return WhatsappMessageItem(
      id: id,
      messageId: messageId,
      body: body,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      direction: direction,
      sender: sender,
      status: status ?? this.status,
      messageType: messageType,
      media: media,
      location: location,
      contacts: contacts,
      interactive: interactive,
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
  // STATUS RANK (sent < delivered < read < failed)
  // ============================================================
  //
  // This way the status never goes "backwards" — if one copy is "read"
  // and the other is "sent", the "read" one always wins, even if its
  // updatedAt is missing or equal.

  int get statusRank {
    switch (status?.toLowerCase()) {
      case 'failed':
        return 4;
      case 'read':
        return 3;
      case 'delivered':
        return 2;
      case 'sent':
        return 1;
      default:
        return 0;
    }
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

  /// reads message.location / message.contacts (null if the field is missing).
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
  /// WhatsappContactModel...) into a Map, so the UI and
  /// so the media controller's `is Map` checks work.
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
