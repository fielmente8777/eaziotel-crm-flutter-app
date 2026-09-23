class WhatsappSocketMessageModel {
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
      conversationId: json['conversationId']?.toString(),
      messageId: json['messageId']?.toString(),
      sender: json['sender']?.toString(),
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      direction: json['direction']?.toString(),
      messageType: json['messageType']?.toString(),
      body: json['body']?.toString(),
      media: json['media'],
      template: json['template'],
      status: json['status']?.toString(),
      adSourceId: json['adSourceId']?.toString(),
      id: json['_id']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      ndid: json['ndid']?.toString(),
      name: json['name']?.toString(),
      unreadCount: json['unread_count'] is int
          ? json['unread_count']
          : int.tryParse(
              json['unread_count']?.toString() ?? '',
            ),
      context: json['context'],
    );
  }
}