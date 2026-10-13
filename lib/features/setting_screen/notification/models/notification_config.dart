// ============================================================
// NOTIFICATION CONFIG (models)
//
// Settings > Notification tab ka data.
// Server se aata hai: GET /api/v1/setting/get-config -> result.docs
//
//   LeadSourceNotification : ek lead source (Webform, Eazbot ...) par kisko
//                            WhatsApp aur kisko Email jaye
//   CallMessage            : call na lagne par guest ko kya bheje
//                            (Not Answered / Missed Call / Busy)
//   NotificationConfig     : upar ke dono ek saath
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

  /// Server ka naam, jaise 'webform'
  final String key;

  /// Screen ka naam, jaise 'Webform'
  final String label;

  /// In numbers par WhatsApp notification jata hai
  List<String> phones;
  bool isPhoneAllowed;

  /// In email par Email notification jata hai
  List<String> emails;
  bool isEmailAllowed;

  /// Paanch source, isi kram me dikhte hain
  static const Map<String, String> sources = {
    'webform': 'Webform',
    'eazbot': 'Eazbot',
    'whatsapp': 'Whatsapp',
    'facebook': 'Facebook',
    'google': 'Google',
  };

  /// Server ke `config` Map se paanchon source (na mile to khali + band)
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

  /// Save API ke body ka hissa
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

  /// Server ka naam: notAnswered / missedCall / busy
  final String key;

  /// Screen ka naam: Not Answered / Missed Call / Busy
  final String label;

  /// 'Template' ya 'Flow'
  String type;

  /// Template ka naam ya flow ki id (kuch na chuna ho to null)
  String? selection;

  /// Server ka "message" field (screen par nahi dikhta, save me waisa hi jata hai)
  final String message;

  static const String typeTemplate = 'Template';
  static const String typeFlow = 'Flow';

  static const List<String> types = [typeTemplate, typeFlow];

  bool get isFlow => type == typeFlow;

  /// Teen haalat, isi kram me dikhti hain
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

  /// Save API ke body ka hissa.
  /// [templateMeta] chune hue template ki jaankari (flow ho to null).
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

  /// "Call Notification" ka switch
  final bool callEnabled;

  final List<CallMessage> callMessages;

  /// Server ka callConfig._id (save me wapas bheja jata hai, web ki tarah)
  final String? callConfigId;

  /// [docs] = get-config ka `result.docs`
  factory NotificationConfig.fromJson(Map<String, dynamic> docs) {
    final call = _toMap(docs['callConfig']);

    return NotificationConfig(
      sources: LeadSourceNotification.listFromJson(_toMap(docs['config'])),
      callEnabled: call['enabled'] == true,
      callMessages: CallMessage.listFromJson(_toMap(call['configs'])),
      callConfigId: call['_id']?.toString(),
    );
  }

  /// Data na aaye to sab khali aur band
  factory NotificationConfig.empty() => NotificationConfig.fromJson({});
}
