// ============================================================
// GSC SETTINGS  (Google Search Console)
//
// GET  /google/gsc-settings/<propertyId>
//   {"configured": true, "email": "", "propertyType": "domain",
//    "property_id": "341834766", "rawDomain": "fielmente.com",
//    "siteUrl": "sc-domain:fielmente.com"}
//
// property_id = hotel ki Google Analytics property (activePropertyId)
// ============================================================

/// Property Type dropdown
enum GscPropertyType {
  domain('domain', 'Domain (sc-domain:example.com)'),
  urlPrefix('url', 'URL prefix (https://example.com/)');

  const GscPropertyType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static GscPropertyType fromApi(String? value) => values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => GscPropertyType.domain,
  );
}

class GscSettings {
  const GscSettings({
    this.configured = false,
    this.propertyType = GscPropertyType.domain,
    this.rawDomain = '',
    this.siteUrl = '',
    this.email = '',
  });

  final bool configured;
  final GscPropertyType propertyType;
  final String rawDomain;
  final String siteUrl;
  final String email;

  factory GscSettings.fromJson(Map<String, dynamic> json) => GscSettings(
    configured: json['configured'] == true,
    propertyType: GscPropertyType.fromApi(json['propertyType']?.toString()),
    rawDomain: json['rawDomain']?.toString() ?? '',
    siteUrl: json['siteUrl']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
  );

  /// POST /google/save-gsc-settings ka body (web jaisa)
  static Map<String, dynamic> saveBody({
    required String propertyId,
    required String hid,
    required GscPropertyType type,
    required String domain,
    required String email,
  }) => {
    'property_id': propertyId,
    'hid': hid,
    'email': email,
    'rawDomain': domain,
    'propertyType': type.apiValue,
  };
}
