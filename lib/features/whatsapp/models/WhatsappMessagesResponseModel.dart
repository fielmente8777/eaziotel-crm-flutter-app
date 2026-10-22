class WhatsappMessagesResponseModel {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final WhatsappRequestModel? request;
  final WhatsappMessagesResultModel? result;

  WhatsappMessagesResponseModel({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result,
  });

  factory WhatsappMessagesResponseModel.fromJson(Map<String, dynamic> json) {
    return WhatsappMessagesResponseModel(
      success: json['success'] as bool?,

      responseStatusCode: json['responseStatusCode'] is int
          ? json['responseStatusCode'] as int
          : int.tryParse(json['responseStatusCode']?.toString() ?? ''),

      responseMessage: json['responseMessage']?.toString(),

      request: json['request'] is Map<String, dynamic>
          ? WhatsappRequestModel.fromJson(
              json['request'] as Map<String, dynamic>,
            )
          : null,

      result: json['result'] is Map<String, dynamic>
          ? WhatsappMessagesResultModel.fromJson(
              json['result'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'result': result?.toJson(),
    };
  }
}

// ============================================================
// REQUEST
// ============================================================

class WhatsappRequestModel {
  final String? method;
  final String? basesurl;
  final String? endpoint;

  WhatsappRequestModel({this.method, this.basesurl, this.endpoint});

  factory WhatsappRequestModel.fromJson(Map<String, dynamic> json) {
    return WhatsappRequestModel(
      method: json['method']?.toString(),
      basesurl: json['basesurl']?.toString(),
      endpoint: json['endpoint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'method': method, 'basesurl': basesurl, 'endpoint': endpoint};
  }
}

// ============================================================
// RESULT
// ============================================================

class WhatsappMessagesResultModel {
  final List<WhatsappMessageModel> messages;

  WhatsappMessagesResultModel({this.messages = const []});

  factory WhatsappMessagesResultModel.fromJson(Map<String, dynamic> json) {
    return WhatsappMessagesResultModel(
      messages: (json['messages'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappMessageModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'messages': messages.map((e) => e.toJson()).toList()};
  }
}

// ============================================================
// MESSAGE
// ============================================================

class WhatsappMessageModel {
  // ============================================================
  // TEMPLATE
  // ============================================================

  final WhatsappTemplateWrapperModel? template;

  // ============================================================
  // BASIC
  // ============================================================

  final String? id;
  final String? conversationId;
  final String? messageId;

  final String? sender;
  final String? from;
  final String? to;

  final String? direction;
  final String? messageType;

  final String? body;
  final String? status;

  final String? createdAt;
  final String? updatedAt;

  final int? version;

  // ============================================================
  // MEDIA
  // ============================================================

  final WhatsappMediaModel? media;

  // ============================================================
  // INTERACTIVE
  // ============================================================

  final WhatsappInteractiveModel? interactive;

  // ============================================================
  // LOCATION
  // ============================================================

  final WhatsappLocationModel? location;

  // ============================================================
  // CONTACTS
  // ============================================================

  final List<WhatsappContactModel> contacts;

  WhatsappMessageModel({
    this.template,
    this.id,
    this.conversationId,
    this.messageId,
    this.sender,
    this.from,
    this.to,
    this.direction,
    this.messageType,
    this.body,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.media,
    this.interactive,
    this.location,
    this.contacts = const [],
  });

  factory WhatsappMessageModel.fromJson(Map<String, dynamic> json) {
    return WhatsappMessageModel(
      // ========================================================
      // TEMPLATE
      // ========================================================
      template: json['template'] is Map<String, dynamic>
          ? WhatsappTemplateWrapperModel.fromJson(
              json['template'] as Map<String, dynamic>,
            )
          : null,

      // ========================================================
      // BASIC
      // ========================================================
      id: json['_id']?.toString(),

      conversationId: json['conversationId']?.toString(),

      messageId: json['messageId']?.toString(),

      sender: json['sender']?.toString(),

      from: json['from']?.toString(),

      to: json['to']?.toString(),

      direction: json['direction']?.toString(),

      messageType: json['messageType']?.toString(),

      body: json['body']?.toString(),

      status: json['status']?.toString(),

      createdAt: json['createdAt']?.toString(),

      updatedAt: json['updatedAt']?.toString(),

      version: json['__v'] is int
          ? json['__v'] as int
          : int.tryParse(json['__v']?.toString() ?? ''),

      // ========================================================
      // MEDIA
      // ========================================================
      media: json['media'] is Map<String, dynamic>
          ? WhatsappMediaModel.fromJson(json['media'] as Map<String, dynamic>)
          : null,

      // ========================================================
      // INTERACTIVE
      // ========================================================
      interactive: json['interactive'] is Map<String, dynamic>
          ? WhatsappInteractiveModel.fromJson(
              json['interactive'] as Map<String, dynamic>,
            )
          : null,

      // ========================================================
      // LOCATION
      // ========================================================
      location: json['location'] is Map<String, dynamic>
          ? WhatsappLocationModel.fromJson(
              json['location'] as Map<String, dynamic>,
            )
          : null,

      // ========================================================
      // CONTACTS
      // ========================================================
      contacts: (json['contacts'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappContactModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // TEMPLATE
      'template': template?.toJson(),

      // BASIC
      '_id': id,
      'conversationId': conversationId,
      'messageId': messageId,

      'sender': sender,
      'from': from,
      'to': to,

      'direction': direction,
      'messageType': messageType,

      'body': body,
      'status': status,

      'createdAt': createdAt,
      'updatedAt': updatedAt,

      '__v': version,

      // MEDIA
      'media': media?.toJson(),

      // INTERACTIVE
      'interactive': interactive?.toJson(),

      // LOCATION
      'location': location?.toJson(),

      // CONTACTS
      'contacts': contacts.map((e) => e.toJson()).toList(),
    };
  }
}
// ============================================================
// CONTACT
// ============================================================

class WhatsappContactModel {
  final String? name;
  final String? phone;
  final String? firstName;
  final String? lastName;

  const WhatsappContactModel({
    this.name,
    this.phone,
    this.firstName,
    this.lastName,
  });

  factory WhatsappContactModel.fromJson(Map<String, dynamic> json) {
    final nameData = json['name'];

    String? displayName;

    String? firstName;
    String? lastName;

    if (nameData is Map<String, dynamic>) {
      displayName = nameData['formatted_name']?.toString();

      firstName = nameData['first_name']?.toString();

      lastName = nameData['last_name']?.toString();
    } else {
      displayName = nameData?.toString();
    }

    return WhatsappContactModel(
      name: displayName,
      phone: json['phone']?.toString(),
      firstName: firstName,
      lastName: lastName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}

class WhatsappMediaModel {
  final String? id;
  final String? mimeType;

  const WhatsappMediaModel({this.id, this.mimeType});

  factory WhatsappMediaModel.fromJson(Map<String, dynamic> json) {
    return WhatsappMediaModel(
      id: json['id']?.toString(),
      mimeType: json['mimeType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'mimeType': mimeType};
  }
}

class WhatsappLocationModel {
  final double? latitude;
  final double? longitude;
  final String? name;
  final String? address;

  const WhatsappLocationModel({
    this.latitude,
    this.longitude,
    this.name,
    this.address,
  });

  factory WhatsappLocationModel.fromJson(Map<String, dynamic> json) {
    return WhatsappLocationModel(
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? ''),

      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? ''),

      name: json['name']?.toString(),

      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'address': address,
    };
  }
}

// ============================================================
// INTERACTIVE
// ============================================================
class WhatsappInteractiveModel {
  final String? type;

  final WhatsappInteractiveBodyModel? header;
  final WhatsappInteractiveBodyModel? body;
  final WhatsappInteractiveBodyModel? footer;

  final WhatsappInteractiveActionModel? action;

  /// data of flow_response (Name, Date, ...)
  final Map<String, dynamic>? data;

  const WhatsappInteractiveModel({
    this.type,
    this.header,
    this.body,
    this.footer,
    this.action,
    this.data,
  });

  factory WhatsappInteractiveModel.fromJson(Map<String, dynamic> json) {
    return WhatsappInteractiveModel(
      type: json['type']?.toString(),

      header: json['header'] is Map<String, dynamic>
          ? WhatsappInteractiveBodyModel.fromJson(
              json['header'] as Map<String, dynamic>,
            )
          : null,

      body: json['body'] is Map<String, dynamic>
          ? WhatsappInteractiveBodyModel.fromJson(
              json['body'] as Map<String, dynamic>,
            )
          : null,

      footer: json['footer'] is Map<String, dynamic>
          ? WhatsappInteractiveBodyModel.fromJson(
              json['footer'] as Map<String, dynamic>,
            )
          : null,

      action: json['action'] is Map<String, dynamic>
          ? WhatsappInteractiveActionModel.fromJson(
              json['action'] as Map<String, dynamic>,
            )
          : null,

      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'header': header?.toJson(),
      'body': body?.toJson(),
      'footer': footer?.toJson(),
      'action': action?.toJson(),
      'data': data,
    };
  }
}
// ============================================================
// INTERACTIVE BODY
// ============================================================

class WhatsappInteractiveBodyModel {
  final String? text;

  const WhatsappInteractiveBodyModel({this.text});

  factory WhatsappInteractiveBodyModel.fromJson(Map<String, dynamic> json) {
    return WhatsappInteractiveBodyModel(text: json['text']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}

// ============================================================
// INTERACTIVE ACTION
//
// Supports:
// 1. button
// 2. buttons
// 3. sections
// 4. cards
// ============================================================



class WhatsappInteractiveActionModel {
  final String? button;
  final String? flowCta; // for the flow
  final List<WhatsappInteractiveButtonModel> buttons;
  final List<WhatsappInteractiveSectionModel> sections;
  final List<WhatsappInteractiveCardModel> cards;

  const WhatsappInteractiveActionModel({
    this.button,
    this.flowCta,
    this.buttons = const [],
    this.sections = const [],
    this.cards = const [],
  });

  factory WhatsappInteractiveActionModel.fromJson(Map<String, dynamic> json) {
    final params = json['parameters'];

    return WhatsappInteractiveActionModel(
      button: json['button']?.toString(),
      flowCta: params is Map ? params['flow_cta']?.toString() : null,
      buttons: (json['buttons'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappInteractiveButtonModel.fromJson(e))
          .toList(),
      sections: (json['sections'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappInteractiveSectionModel.fromJson(e))
          .toList(),
      cards: (json['cards'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappInteractiveCardModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'button': button,
      'flow_cta': flowCta,
      'buttons': buttons.map((e) => e.toJson()).toList(),
      'sections': sections.map((e) => e.toJson()).toList(),
      'cards': cards.map((e) => e.toJson()).toList(),
    };
  }
}



// ============================================================
// INTERACTIVE BUTTON
// ============================================================

class WhatsappInteractiveButtonModel {
  final String? type;

  final WhatsappInteractiveReplyModel? reply;

  const WhatsappInteractiveButtonModel({this.type, this.reply});

  factory WhatsappInteractiveButtonModel.fromJson(Map<String, dynamic> json) {
    return WhatsappInteractiveButtonModel(
      type: json['type']?.toString(),

      reply: json['reply'] is Map<String, dynamic>
          ? WhatsappInteractiveReplyModel.fromJson(
              json['reply'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'reply': reply?.toJson()};
  }
}

// ============================================================
// BUTTON REPLY
// ============================================================

class WhatsappInteractiveReplyModel {
  final String? id;

  final String? title;

  const WhatsappInteractiveReplyModel({this.id, this.title});

  factory WhatsappInteractiveReplyModel.fromJson(Map<String, dynamic> json) {
    return WhatsappInteractiveReplyModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

// ============================================================
// LIST SECTION
// ============================================================

class WhatsappInteractiveSectionModel {
  final String? title;

  final List<WhatsappInteractiveRowModel> rows;

  const WhatsappInteractiveSectionModel({this.title, this.rows = const []});

  factory WhatsappInteractiveSectionModel.fromJson(Map<String, dynamic> json) {
    return WhatsappInteractiveSectionModel(
      title: json['title']?.toString(),

      rows: (json['rows'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappInteractiveRowModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'rows': rows.map((e) => e.toJson()).toList()};
  }
}

// ============================================================
// LIST ROW
// ============================================================

class WhatsappInteractiveRowModel {
  final String? id;

  final String? title;

  final String? description;

  const WhatsappInteractiveRowModel({this.id, this.title, this.description});

  factory WhatsappInteractiveRowModel.fromJson(Map<String, dynamic> json) {
    return WhatsappInteractiveRowModel(
      id: json['id']?.toString(),

      title: json['title']?.toString(),

      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'description': description};
  }
}

// ============================================================
// CAROUSEL CARD
// ============================================================

class WhatsappInteractiveCardModel {
  final int? cardIndex;

  final String? type;

  final WhatsappInteractiveCardHeaderModel? header;

  final WhatsappInteractiveBodyModel? body;

  final WhatsappInteractiveCardActionModel? action;

  const WhatsappInteractiveCardModel({
    this.cardIndex,
    this.type,
    this.header,
    this.body,
    this.action,
  });

  factory WhatsappInteractiveCardModel.fromJson(Map<String, dynamic> json) {
    return WhatsappInteractiveCardModel(
      cardIndex: json['card_index'] is int
          ? json['card_index'] as int
          : int.tryParse(json['card_index']?.toString() ?? ''),

      type: json['type']?.toString(),

      header: json['header'] is Map<String, dynamic>
          ? WhatsappInteractiveCardHeaderModel.fromJson(
              json['header'] as Map<String, dynamic>,
            )
          : null,

      body: json['body'] is Map<String, dynamic>
          ? WhatsappInteractiveBodyModel.fromJson(
              json['body'] as Map<String, dynamic>,
            )
          : null,

      action: json['action'] is Map<String, dynamic>
          ? WhatsappInteractiveCardActionModel.fromJson(
              json['action'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_index': cardIndex,

      'type': type,

      'header': header?.toJson(),

      'body': body?.toJson(),

      'action': action?.toJson(),
    };
  }
}

// ============================================================
// CAROUSEL CARD HEADER
// ============================================================

class WhatsappInteractiveCardHeaderModel {
  final String? type;

  final WhatsappInteractiveCardImageModel? image;

  const WhatsappInteractiveCardHeaderModel({this.type, this.image});

  factory WhatsappInteractiveCardHeaderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappInteractiveCardHeaderModel(
      type: json['type']?.toString(),

      image: json['image'] is Map<String, dynamic>
          ? WhatsappInteractiveCardImageModel.fromJson(
              json['image'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'image': image?.toJson()};
  }
}

// ============================================================
// CAROUSEL CARD IMAGE
// ============================================================

class WhatsappInteractiveCardImageModel {
  final String? link;

  const WhatsappInteractiveCardImageModel({this.link});

  factory WhatsappInteractiveCardImageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappInteractiveCardImageModel(link: json['link']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'link': link};
  }
}

// ============================================================
// CAROUSEL CARD ACTION
// ============================================================

class WhatsappInteractiveCardActionModel {
  final List<WhatsappInteractiveButtonModel> buttons;

  const WhatsappInteractiveCardActionModel({this.buttons = const []});

  factory WhatsappInteractiveCardActionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsappInteractiveCardActionModel(
      buttons: (json['buttons'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappInteractiveButtonModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'buttons': buttons.map((e) => e.toJson()).toList()};
  }
}

// ============================================================
// TEMPLATE WRAPPER
// ============================================================

class WhatsappTemplateWrapperModel {
  final WhatsappTemplateModel? template;

  final String? type;

  WhatsappTemplateWrapperModel({this.template, this.type});

  factory WhatsappTemplateWrapperModel.fromJson(Map<String, dynamic> json) {
    return WhatsappTemplateWrapperModel(
      template: json['template'] is Map<String, dynamic>
          ? WhatsappTemplateModel.fromJson(
              json['template'] as Map<String, dynamic>,
            )
          : null,

      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'template': template?.toJson(), 'type': type};
  }
}

// ============================================================
// TEMPLATE
// ============================================================

class WhatsappTemplateModel {
  final WhatsappLanguageModel? language;

  final String? name;

  final List<WhatsappComponentModel> components;

  WhatsappTemplateModel({this.language, this.name, this.components = const []});

  factory WhatsappTemplateModel.fromJson(Map<String, dynamic> json) {
    return WhatsappTemplateModel(
      language: json['language'] is Map<String, dynamic>
          ? WhatsappLanguageModel.fromJson(
              json['language'] as Map<String, dynamic>,
            )
          : null,

      name: json['name']?.toString(),

      components: (json['components'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappComponentModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language?.toJson(),
      'name': name,
      'components': components.map((e) => e.toJson()).toList(),
    };
  }
}

// ============================================================
// LANGUAGE
// ============================================================

class WhatsappLanguageModel {
  final String? code;

  WhatsappLanguageModel({this.code});

  factory WhatsappLanguageModel.fromJson(Map<String, dynamic> json) {
    return WhatsappLanguageModel(code: json['code']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'code': code};
  }
}

// ============================================================
// COMPONENT
// ============================================================

class WhatsappComponentModel {
  final String? type;

  final List<WhatsappParameterModel> parameters;

  final String? id;

  WhatsappComponentModel({this.type, this.parameters = const [], this.id});

  factory WhatsappComponentModel.fromJson(Map<String, dynamic> json) {
    return WhatsappComponentModel(
      type: json['type']?.toString(),

      parameters: (json['parameters'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => WhatsappParameterModel.fromJson(e))
          .toList(),

      id: json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,

      'parameters': parameters.map((e) => e.toJson()).toList(),

      '_id': id,
    };
  }
}

// ============================================================
// PARAMETER
// ============================================================

class WhatsappParameterModel {
  final String? type;

  final String? text;

  final String? id;

  WhatsappParameterModel({this.type, this.text, this.id});

  factory WhatsappParameterModel.fromJson(Map<String, dynamic> json) {
    return WhatsappParameterModel(
      type: json['type']?.toString(),

      text: json['text']?.toString(),

      id: json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'text': text, '_id': id};
  }
}
