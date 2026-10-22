// ============================================================
// SEO COMMON
//
// Small helpers used by all SEO models:
//   seoNum / seoNumOrNull / seoStr : API value as a number/text
//   seoBody   : same as web "res.result || res"
//   SeoRequest: the "request" part of the response
// ============================================================

double seoNum(dynamic v) => seoNumOrNull(v) ?? 0;

/// null / "" -> null (like when there is no rank)
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

/// Data sometimes comes inside "result", sometimes directly
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

  /// null if there is no "request"
  static SeoRequest? tryParse(dynamic json) =>
      json is Map ? SeoRequest.fromJson(seoMap(json)) : null;

  Map<String, dynamic> toJson() {
    return {'method': method, 'basesurl': basesurl, 'endpoint': endpoint};
  }
}
