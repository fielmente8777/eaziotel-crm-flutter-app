import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';

class WhatsappSocketMessageModel {
  final String? hid;

  final String? conversationId;
  final String? messageId;

  final String? sender;
  final String? from;
  final String? to;

  final String? direction;
  final String? messageType;

  final String? body;

  final dynamic media;
  final dynamic template;

  final WhatsappInteractiveModel? interactive;
  final WhatsappLocationModel? location;

  final List<WhatsappContactModel> contacts;

  final String? status;

  final String? adSourceId;
  final String? id;

  final String? createdAt;
  final String? updatedAt;

  final String? ndid;
  final String? name;

  final int? unreadCount;

  final dynamic context;

  WhatsappSocketMessageModel({
    this.hid,
    this.conversationId,
    this.messageId,
    this.sender,
    this.from,
    this.to,
    this.direction,
    this.messageType,
    this.body,
    this.media,
    this.template,
    this.interactive,
    this.location,
    this.contacts = const [],
    this.status,
    this.adSourceId,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.ndid,
    this.name,
    this.unreadCount,
    this.context,
  });

  factory WhatsappSocketMessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappSocketMessageModel(
      hid: json['hid']?.toString(),

      conversationId: json['conversationId']?.toString(),
      messageId: json['messageId']?.toString(),

      sender: json['sender']?.toString(),
      from: json['from']?.toString(),
      to: json['to']?.toString(),

      direction: json['direction']?.toString(),
      messageType: json['messageType']?.toString(),

      body: json['body']?.toString(),

      // MEDIA
      media: json['media'],

      // TEMPLATE
      template: json['template'],

      // INTERACTIVE
      interactive: json['interactive'] is Map<String, dynamic>
          ? WhatsappInteractiveModel.fromJson(
              json['interactive'] as Map<String, dynamic>,
            )
          : null,

      // LOCATION
      location: json['location'] is Map<String, dynamic>
          ? WhatsappLocationModel.fromJson(
              json['location'] as Map<String, dynamic>,
            )
          : null,

      // CONTACTS
      contacts: _parseContacts(json['contacts']),

      status: json['status']?.toString(),

      adSourceId: json['adSourceId']?.toString(),

      id: json['_id']?.toString(),

      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),

      ndid: json['ndid']?.toString(),
      name: json['name']?.toString(),

      unreadCount: json['unread_count'] is int
          ? json['unread_count'] as int
          : int.tryParse(
              json['unread_count']?.toString() ?? '',
            ),

      context: json['context'],
    );
  }

  static List<WhatsappContactModel> _parseContacts(
    dynamic value,
  ) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => WhatsappContactModel.fromJson(e),
        )
        .toList();
  }
}