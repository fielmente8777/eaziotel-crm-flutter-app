// ============================================================
// AUTO MESSAGE CONFIG (model)
//
// "Auto Messaging Configuration" card ki EK line ka data.
// Jaise: Eazbot Leads -> on hai, Template bhejna hai, kaunsa template.
//
// Server se aisa aata hai (account/connection/details -> autoMessage):
//   "eazbot": { "enabled": true, "type": "template",
//               "templateName": "lead_assign_notification", "flowId": null }
// ============================================================

class AutoMessageConfig {
  AutoMessageConfig({
    required this.key,
    required this.label,
    this.enabled = false,
    this.type = typeTemplate,
    this.selection,
  });

  /// Server wala naam, jaise 'eazbot'
  final String key;

  /// Screen par dikhne wala naam, jaise 'Eazbot Leads'
  final String label;

  /// Switch on hai ya off
  bool enabled;

  /// 'Template' ya 'Flow'
  String type;

  /// Chuna hua template ka naam, ya flow ki id (kuch na chuna ho to null)
  String? selection;

  static const String typeTemplate = 'Template';
  static const String typeFlow = 'Flow';

  /// Pehle dropdown ke do option
  static const List<String> types = [typeTemplate, typeFlow];

  bool get isFlow => type == typeFlow;

  /// Paanch module: server ka naam -> screen ka naam (isi kram me dikhte hain)
  static const Map<String, String> modules = {
    'eazbot': 'Eazbot Leads',
    'webform': 'Webform Leads',
    'metaLead': 'Meta Leads',
    'googleLead': 'Google Leads',
    'whatsapp': 'WhatsApp',
  };

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
    final isFlow = json['type']?.toString().toLowerCase() == 'flow';

    // Flow ho to flowId chuna hua hai, warna templateName
    final selected = isFlow ? json['flowId'] : json['templateName'];

    return AutoMessageConfig(
      key: key,
      label: label,
      enabled: json['enabled'] == true,
      type: isFlow ? typeFlow : typeTemplate,
      selection: selected?.toString(),
    );
  }
}
