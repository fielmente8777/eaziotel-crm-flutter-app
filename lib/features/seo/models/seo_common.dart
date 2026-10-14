// ============================================================
// SEO COMMON
//
// Sab SEO model me kaam aane wale chhote helper:
//   seoNum / seoNumOrNull / seoStr : API ki value number/text me
//   seoBody   : web jaisa "res.result || res"
//   SeoRequest: response ka "request" hissa
// ============================================================

double seoNum(dynamic v) => seoNumOrNull(v) ?? 0;

/// null / "" -> null (jaise rank nahi mila)
double? seoNumOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();

  final text = v.toString().trim();
  return text.isEmpty ? null : double.tryParse(text);
}

String seoStr(dynamic v) => v == null ? '' : v.toString();

Map<String, dynamic> seoMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> seoMaps(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

/// Data kabhi "result" ke andar aata hai, kabhi seedha
Map<String, dynamic> seoBody(Map<String, dynamic> json) =>
    json['result'] is Map ? seoMap(json['result']) : json;

class SeoRequest {
  final String? method;
  final String? basesurl;
  final String? endpoint;

  SeoRequest({this.method, this.basesurl, this.endpoint});

  factory SeoRequest.fromJson(Map<String, dynamic> json) {
    return SeoRequest(
      method: json['method'] as String?,
      basesurl: json['basesurl'] as String?,
      endpoint: json['endpoint'] as String?,
    );
  }

  /// "request" na ho to null
  static SeoRequest? tryParse(dynamic json) =>
      json is Map ? SeoRequest.fromJson(seoMap(json)) : null;

  Map<String, dynamic> toJson() {
    return {'method': method, 'basesurl': basesurl, 'endpoint': endpoint};
  }
}
