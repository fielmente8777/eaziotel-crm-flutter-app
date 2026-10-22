// ============================================================
// AUTO MESSAGE CONFIG (model)
//
// Data of ONE line of the "Auto Messaging Configuration" card (same as web).
// For example: Eazbot Leads -> on, send a Template, which template.
//
// It comes from the server like this (account/connection/details -> autoMessage):
//   "eazbot": { "enabled": true, "type": "template",
//               "templateName": "lead_assign_notification",
//               "message": null, "flowId": null }
//
// There are three types: template / text / flow
// (flow only in the "WhatsApp" module, same as web)
// ============================================================

class AutoMessageConfig {
  AutoMessageConfig({
    required this.key,
    required this.label,
    this.enabled = false,
    this.type = typeTemplate,
    this.templateName = '',
    this.message = '',
    this.flowId = '',
  });

  /// Name used by the server, like 'eazbot'
  final String key;

  /// Name shown on screen, like 'Eazbot Leads'
  final String label;

  bool enabled;

  /// template / text / flow
  String type;
  String templateName;
  String message;
  String flowId;

  static const String typeTemplate = 'template';
  static const String typeText = 'text';
  static const String typeFlow = 'flow';

  /// Flow only in the WhatsApp module
  bool get canUseFlow => key == 'whatsapp';

  /// Options of the first dropdown (value -> name)
  Map<String, String> get typeOptions => {
    typeTemplate: 'Template',
    typeText: 'Text',
    if (canUseFlow) typeFlow: 'Flow',
  };

  bool get isTemplate => type == typeTemplate;
  bool get isText => type == typeText;
  bool get isFlow => type == typeFlow;

  /// Five modules: server name -> screen name (shown in this order)
  static const Map<String, String> modules = {
    'eazbot': 'Eazbot Leads',
    'webform': 'Webform Leads',
    'metaLead': 'Meta Leads',
    'googleLead': 'Google Leads',
    'whatsapp': 'WhatsApp',
  };

  AutoMessageConfig copy() => AutoMessageConfig(
    key: key,
    label: label,
    enabled: enabled,
    type: type,
    templateName: templateName,
    message: message,
    flowId: flowId,
  );

  /// Another module's setting in this module (Apply to all)
  void copyFrom(AutoMessageConfig other) {
    enabled = other.enabled;
    type = other.isFlow && !canUseFlow ? typeTemplate : other.type;
    templateName = other.templateName;
    message = other.message;
    flowId = canUseFlow ? other.flowId : '';
  }

  /// To detect changes (the Save button shows only then)
  String get signature => '$enabled|$type|$templateName|$message|$flowId';

  /// Builds the list of all five modules from the server's `autoMessage` Map.
  /// An empty Map gives all modules turned off.
  static List<AutoMessageConfig> listFromJson(Map<String, dynamic> json) {
    return [
      for (final module in modules.entries)
        AutoMessageConfig._fromJson(
          key: module.key,
          label: module.value,
          json: json[module.key] is Map
              ? Map<String, dynamic>.from(json[module.key])
              : {},
        ),
    ];
  }

  factory AutoMessageConfig._fromJson({
    required String key,
    required String label,
    required Map<String, dynamic> json,
  }) {
    var type = json['type']?.toString().toLowerCase() ?? typeTemplate;
    if (![typeTemplate, typeText, typeFlow].contains(type)) {
      type = typeTemplate;
    }
    if (type == typeFlow && key != 'whatsapp') type = typeTemplate;

    String text(dynamic v) => v == null ? '' : v.toString();

    return AutoMessageConfig(
      key: key,
      label: label,
      enabled: json['enabled'] == true,
      type: type,
      templateName: text(json['templateName']),
      message: text(json['message']),
      flowId: text(json['flowId']),
    );
  }
}
