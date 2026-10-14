// ============================================================
// AUTO MESSAGE CONFIG (model)
//
// "Auto Messaging Configuration" card ki EK line ka data (web jaisa).
// Jaise: Eazbot Leads -> on hai, Template bhejna hai, kaunsa template.
//
// Server se aisa aata hai (account/connection/details -> autoMessage):
//   "eazbot": { "enabled": true, "type": "template",
//               "templateName": "lead_assign_notification",
//               "message": null, "flowId": null }
//
// Type teen hain: template / text / flow
// (flow sirf "WhatsApp" module me, web jaisa)
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

  /// Server wala naam, jaise 'eazbot'
  final String key;

  /// Screen par dikhne wala naam, jaise 'Eazbot Leads'
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

  /// Flow sirf WhatsApp module me
  bool get canUseFlow => key == 'whatsapp';

  /// Pehle dropdown ke option (value -> naam)
  Map<String, String> get typeOptions => {
    typeTemplate: 'Template',
    typeText: 'Text',
    if (canUseFlow) typeFlow: 'Flow',
  };

  bool get isTemplate => type == typeTemplate;
  bool get isText => type == typeText;
  bool get isFlow => type == typeFlow;

  /// Paanch module: server ka naam -> screen ka naam (isi kram me dikhte hain)
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

  /// Dusre module ki setting is module me (Apply to all)
  void copyFrom(AutoMessageConfig other) {
    enabled = other.enabled;
    type = other.isFlow && !canUseFlow ? typeTemplate : other.type;
    templateName = other.templateName;
    message = other.message;
    flowId = canUseFlow ? other.flowId : '';
  }

  /// Badlav pakadne ke liye (Save button tabhi dikhta hai)
  String get signature => '$enabled|$type|$templateName|$message|$flowId';

  /// Server ke `autoMessage` Map se paanchon module ki list banata hai.
  /// Khali Map do to sab module band (off) aate hain.
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
