class WhatsappResponseModel {
  final bool success;
  final int responseStatusCode;
  final String responseMessage;
  final WhatsappRequestModel request;
  final WhatsappResultModel result;

  WhatsappResponseModel({
    required this.success,
    required this.responseStatusCode,
    required this.responseMessage,
    required this.request,
    required this.result,
  });

  factory WhatsappResponseModel.fromJson(Map<String, dynamic> json) {
    return WhatsappResponseModel(
      success: json['success'] ?? false,
      responseStatusCode: json['responseStatusCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      request: WhatsappRequestModel.fromJson(
        json['request'] ?? {},
      ),
      result: WhatsappResultModel.fromJson(
        json['result'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request.toJson(),
      'result': result.toJson(),
    };
  }
}

// ======================================================
// REQUEST
// ======================================================

class WhatsappRequestModel {
  final String method;
  final String basesurl;
  final String endpoint;

  WhatsappRequestModel({
    required this.method,
    required this.basesurl,
    required this.endpoint,
  });

  factory WhatsappRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappRequestModel(
      method: json['method'] ?? '',
      basesurl: json['basesurl'] ?? '',
      endpoint: json['endpoint'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'basesurl': basesurl,
      'endpoint': endpoint,
    };
  }
}

// ======================================================
// RESULT
// ======================================================

class WhatsappResultModel {
  final List<WhatsappConversationModel> conversations;

  WhatsappResultModel({
    required this.conversations,
  });

  factory WhatsappResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappResultModel(
      conversations: (json['conversations'] as List? ?? [])
          .map(
            (e) => WhatsappConversationModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversations':
          conversations.map((e) => e.toJson()).toList(),
    };
  }
}

// ======================================================
// CONVERSATION
// ======================================================

class WhatsappConversationModel {
  final WhatsappLastMessageModel? lastMessage;
  final WhatsappHandlingModel? handling;

  final String id;
  final String hid;
  final String ndid;
  final String phone;
  final String phoneNumberId;

  final String? name;

  final int unreadCount;

  final String status;
  final bool markAsLead;

  final List<WhatsappNoteModel> notes;

  final String createdAt;
  final String updatedAt;

  final int version;

  final String? assignedTo;

  WhatsappConversationModel({
    this.lastMessage,
    this.handling,
    required this.id,
    required this.hid,
    required this.ndid,
    required this.phone,
    required this.phoneNumberId,
    this.name,
    required this.unreadCount,
    required this.status,
    required this.markAsLead,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.assignedTo,
  });

  factory WhatsappConversationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappConversationModel(
      lastMessage: json['last_message'] != null
          ? WhatsappLastMessageModel.fromJson(
              json['last_message'],
            )
          : null,

      handling: json['handling'] != null
          ? WhatsappHandlingModel.fromJson(
              json['handling'],
            )
          : null,

      id: json['_id']?.toString() ?? '',
      hid: json['hid']?.toString() ?? '',
      ndid: json['ndid']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      phoneNumberId:
          json['phoneNumberId']?.toString() ?? '',

      name: json['name']?.toString(),

      unreadCount: json['unread_count'] is int
          ? json['unread_count']
          : int.tryParse(
                json['unread_count']?.toString() ?? '0',
              ) ??
              0,

      status: json['status']?.toString() ?? '',

      markAsLead: json['markAsLead'] ?? false,

      notes: (json['notes'] as List? ?? [])
          .map(
            (e) => WhatsappNoteModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),

      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',

      version: json['__v'] is int
          ? json['__v']
          : int.tryParse(
                json['__v']?.toString() ?? '0',
              ) ??
              0,

      assignedTo: json['assignedTo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_message': lastMessage?.toJson(),
      'handling': handling?.toJson(),
      '_id': id,
      'hid': hid,
      'ndid': ndid,
      'phone': phone,
      'phoneNumberId': phoneNumberId,
      'name': name,
      'unread_count': unreadCount,
      'status': status,
      'markAsLead': markAsLead,
      'notes': notes.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
      'assignedTo': assignedTo,
    };
  }
}

// ======================================================
// LAST MESSAGE
// ======================================================

class WhatsappLastMessageModel {
  final String? sender;
  final String? text;
  final String? type;
  final String? createdAt;
  final String? updatedAt;

  WhatsappLastMessageModel({
    this.sender,
    this.text,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory WhatsappLastMessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappLastMessageModel(
      sender: json['sender']?.toString(),
      text: json['text']?.toString(),
      type: json['type']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
      'type': type,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ======================================================
// HANDLING
// ======================================================

class WhatsappHandlingModel {
  final String? mode;
  final String? assignedTo;
  final String? assignedAt;
  final String? assignedBy;

  WhatsappHandlingModel({
    this.mode,
    this.assignedTo,
    this.assignedAt,
    this.assignedBy,
  });

  factory WhatsappHandlingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappHandlingModel(
      mode: json['mode']?.toString(),
      assignedTo: json['assignedTo']?.toString(),
      assignedAt: json['assignedAt']?.toString(),
      assignedBy: json['assignedBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'assignedTo': assignedTo,
      'assignedAt': assignedAt,
      'assignedBy': assignedBy,
    };
  }
}

// ======================================================
// NOTES
// ======================================================

class WhatsappNoteModel {
  final String? activitySource;
  final String? createdAt;
  final String? message;
  final String? id;

  WhatsappNoteModel({
    this.activitySource,
    this.createdAt,
    this.message,
    this.id,
  });

  factory WhatsappNoteModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappNoteModel(
      activitySource:
          json['activitySource']?.toString(),
      createdAt:
          json['createdAt']?.toString(),
      message:
          json['message']?.toString(),
      id:
          json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activitySource': activitySource,
      'createdAt': createdAt,
      'message': message,
      '_id': id,
    };
  }
}