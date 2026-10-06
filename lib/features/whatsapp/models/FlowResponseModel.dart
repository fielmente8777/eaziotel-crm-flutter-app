// ============================================================
// FLOW RESPONSE (GET /api/v1/whatsapp/flow/get?hid=...)
// ============================================================

class FlowResponseModel {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final FlowRequestModel? request;
  final FlowResultModel? result;

  FlowResponseModel({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result,
  });

  factory FlowResponseModel.fromJson(Map<String, dynamic> json) {
    return FlowResponseModel(
      success: json['success'] as bool?,
      responseStatusCode: _toInt(json['responseStatusCode']),
      responseMessage: json['responseMessage']?.toString(),
      request: _toMap(json['request']) != null
          ? FlowRequestModel.fromJson(_toMap(json['request'])!)
          : null,
      result: _toMap(json['result']) != null
          ? FlowResultModel.fromJson(_toMap(json['result'])!)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'responseStatusCode': responseStatusCode,
    'responseMessage': responseMessage,
    'request': request?.toJson(),
    'result': result?.toJson(),
  };
}

// ============================================================
// REQUEST
// ============================================================

class FlowRequestModel {
  final String? method;
  final String? basesurl;
  final String? endpoint;

  FlowRequestModel({this.method, this.basesurl, this.endpoint});

  factory FlowRequestModel.fromJson(Map<String, dynamic> json) {
    return FlowRequestModel(
      method: json['method']?.toString(),
      basesurl: json['basesurl']?.toString(),
      endpoint: json['endpoint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'method': method,
    'basesurl': basesurl,
    'endpoint': endpoint,
  };
}

// ============================================================
// RESULT
// ============================================================

class FlowResultModel {
  final FlowDocsModel? docs;

  FlowResultModel({this.docs});

  factory FlowResultModel.fromJson(Map<String, dynamic> json) {
    return FlowResultModel(
      docs: _toMap(json['docs']) != null
          ? FlowDocsModel.fromJson(_toMap(json['docs'])!)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'docs': docs?.toJson()};
}

// ============================================================
// DOCS
// ============================================================

class FlowDocsModel {
  final List<FlowItemModel>? flows;

  FlowDocsModel({this.flows});

  factory FlowDocsModel.fromJson(Map<String, dynamic> json) {
    final raw = json['flows'];

    return FlowDocsModel(
      flows: raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (item) =>
                      FlowItemModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : <FlowItemModel>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'flows': flows?.map((f) => f.toJson()).toList(),
  };
}

// ============================================================
// FLOW ITEM
// ============================================================

class FlowItemModel {
  final String? id; // _id
  final String? ndid;
  final String? hid;
  final String? flowId;
  final String? flowName;
  final List<FlowScreenModel>? screens;
  final String? createdAt;
  final String? updatedAt;
  final int? version; // __v

  FlowItemModel({
    this.id,
    this.ndid,
    this.hid,
    this.flowId,
    this.flowName,
    this.screens,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory FlowItemModel.fromJson(Map<String, dynamic> json) {
    final rawScreens = json['screens'];

    return FlowItemModel(
      id: json['_id']?.toString(),
      ndid: json['ndid']?.toString(),
      hid: json['hid']?.toString(),
      flowId: json['flowId']?.toString(),
      flowName: json['flowName']?.toString(),
      screens: rawScreens is List
          ? rawScreens
                .whereType<Map>()
                .map(
                  (item) =>
                      FlowScreenModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : <FlowScreenModel>[],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      version: _toInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'ndid': ndid,
    'hid': hid,
    'flowId': flowId,
    'flowName': flowName,
    'screens': screens?.map((s) => s.toJson()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': version,
  };
}

// ============================================================
// SCREEN
// ============================================================

class FlowScreenModel {
  final String? id;
  final String? title;
  final List<FlowFieldModel>? fields;

  FlowScreenModel({this.id, this.title, this.fields});

  factory FlowScreenModel.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];

    return FlowScreenModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      fields: rawFields is List
          ? rawFields
                .whereType<Map>()
                .map(
                  (item) =>
                      FlowFieldModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : <FlowFieldModel>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'fields': fields?.map((f) => f.toJson()).toList(),
  };
}

// ============================================================
// FIELD
// ============================================================

class FlowFieldModel {
  final String? label;
  final String? type; // text, date, email ...
  final bool? required;

  FlowFieldModel({this.label, this.type, this.required});

  factory FlowFieldModel.fromJson(Map<String, dynamic> json) {
    return FlowFieldModel(
      label: json['label']?.toString(),
      type: json['type']?.toString(),
      required: json['required'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'type': type,
    'required': required,
  };
}

// ============================================================
// SAFE HELPERS
// ============================================================

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
