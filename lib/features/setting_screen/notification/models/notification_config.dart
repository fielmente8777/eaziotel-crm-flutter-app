// ============================================================
// NOTIFICATION CONFIG (models)
//
// Data of the Settings > Notification tab.
// Comes from the server: GET /api/v1/setting/get-config -> result.docs
//
//   LeadSourceNotification : for one lead source (Webform, Eazbot ...), who gets
//                            WhatsApp and who gets the Email
//   CallMessage            : what to send the guest when a call does not connect
//                            (Not Answered / Missed Call / Busy)
//   NotificationConfig     : both of the above together
// ============================================================

List<String> _toStringList(dynamic value) {
  if (value is! List) return [];

  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

Map<String, dynamic> _toMap(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : {};
}

// ============================================================
// LEAD SOURCE
// ============================================================

class LeadSourceNotification {
  LeadSourceNotification({
    required this.key,
    required this.label,
    required this.phones,
    required this.isPhoneAllowed,
    required this.emails,
    required this.isEmailAllowed,
  });

  /// Server name, like 'webform'
  final String key;

  /// Screen name, like 'Webform'
  final String label;

  /// WhatsApp notifications go to these numbers
  List<String> phones;
  bool isPhoneAllowed;

  /// Email notifications go to these emails
  List<String> emails;
  bool isEmailAllowed;

  /// Five sources, shown in this order
  static const Map<String, String> sources = {
    'webform': 'Webform',
    'eazbot': 'Eazbot',
    'whatsapp': 'Whatsapp',
    'facebook': 'Facebook',
    'google': 'Google',
  };

  /// All five sources from the server's `config` Map (empty + off if missing)
  static List<LeadSourceNotification> listFromJson(
    Map<String, dynamic> config,
  ) {
    return [
      for (final source in sources.entries)
        LeadSourceNotification._fromJson(
          key: source.key,
          label: source.value,
          json: _toMap(config[source.key]),
        ),
    ];
  }

  /// Part of the save API body
  Map<String, dynamic> toJson() => {
    'email': emails,
    'phone': phones,
    'isEmailAllowed': isEmailAllowed,
    'isPhoneAllowed': isPhoneAllowed,
  };

  factory LeadSourceNotification._fromJson({
    required String key,
    required String label,
    required Map<String, dynamic> json,
  }) {
    return LeadSourceNotification(
      key: key,
      label: label,
      phones: _toStringList(json['phone']),
      isPhoneAllowed: json['isPhoneAllowed'] == true,
      emails: _toStringList(json['email']),
      isEmailAllowed: json['isEmailAllowed'] == true,
    );
  }
}

// ============================================================
// CALL MESSAGE
// ============================================================

class CallMessage {
  CallMessage({
    required this.key,
    required this.label,
    this.type = typeTemplate,
    this.selection,
    this.message = '',
  });

  /// Server name: notAnswered / missedCall / busy
  final String key;

  /// Screen name: Not Answered / Missed Call / Busy
  final String label;

  /// 'Template' ya 'Flow'
  String type;

  /// Template name or flow id (null if nothing is chosen)
  String? selection;

  /// The server's "message" field (not shown on screen, sent back as is on save)
  final String message;

  static const String typeTemplate = 'Template';
  static const String typeFlow = 'Flow';

  static const List<String> types = [typeTemplate, typeFlow];

  bool get isFlow => type == typeFlow;

  /// Three states, shown in this order
  static const Map<String, String> cases = {
    'notAnswered': 'Not Answered',
    'missedCall': 'Missed Call',
    'busy': 'Busy',
  };

  static List<CallMessage> listFromJson(Map<String, dynamic> configs) {
    return [
      for (final item in cases.entries)
        CallMessage._fromJson(
          key: item.key,
          label: item.value,
          json: _toMap(configs[item.key]),
        ),
    ];
  }

  /// Part of the save API body.
  /// [templateMeta] is info about the chosen template (null for a flow).
  Map<String, dynamic> toJson({Map<String, dynamic>? templateMeta}) => {
    'type': isFlow ? 'flow' : 'template',
    'templateName': isFlow ? null : selection,
    'templateMeta': isFlow ? null : templateMeta,
    'message': message,
    'flowId': isFlow ? (selection ?? '') : '',
  };

  factory CallMessage._fromJson({
    required String key,
    required String label,
    required Map<String, dynamic> json,
  }) {
    final isFlow = json['type']?.toString().toLowerCase() == 'flow';
    final selected = (isFlow ? json['flowId'] : json['templateName'])
        ?.toString()
        .trim();

    return CallMessage(
      key: key,
      label: label,
      type: isFlow ? typeFlow : typeTemplate,
      selection: (selected == null || selected.isEmpty) ? null : selected,
      message: json['message']?.toString() ?? '',
    );
  }
}

// ============================================================
// POORA CONFIG
// ============================================================

class NotificationConfig {
  const NotificationConfig({
    required this.sources,
    required this.callEnabled,
    required this.callMessages,
    this.callConfigId,
  });

  final List<LeadSourceNotification> sources;

  /// The "Call Notification" switch
  final bool callEnabled;

  final List<CallMessage> callMessages;

  /// The server's callConfig._id (sent back on save, like the web)
  final String? callConfigId;

  /// [docs] = `result.docs` of get-config
  factory NotificationConfig.fromJson(Map<String, dynamic> docs) {
    final call = _toMap(docs['callConfig']);

    return NotificationConfig(
      sources: LeadSourceNotification.listFromJson(_toMap(docs['config'])),
      callEnabled: call['enabled'] == true,
      callMessages: CallMessage.listFromJson(_toMap(call['configs'])),
      callConfigId: call['_id']?.toString(),
    );
  }

  /// If no data comes, everything is empty and off
  factory NotificationConfig.empty() => NotificationConfig.fromJson({});
}
