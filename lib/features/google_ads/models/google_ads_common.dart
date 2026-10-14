// ============================================================
// GOOGLE ADS COMMON (saare response model ke kaam ka)
//
//   GoogleAdsRequest : response ka "request" hissa (method, basesurl, endpoint)
//   AdsDropdownItem  : Account / Campaign / Ad Group / Ad dropdown ki ek line
//   adsNum / adsStr  : JSON se number / text nikalna (null safe)
//   adsIsEnabled     : web jaisa, sirf ENABLED ("2") wale dikhte hain
//   adsList          : list "data" me ho ya "result.<key>" me, dono chalte hain
// ============================================================

double adsNum(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

String adsStr(dynamic v) {
  final text = v?.toString().trim() ?? '';
  return text == 'null' ? '' : text;
}

bool adsIsEnabled(dynamic status) {
  final s = adsStr(status).toUpperCase();
  return s == 'ENABLED' || s == '2';
}

/// Web jaisa: `response.data` ya `response.result.<key>`
List<Map<String, dynamic>> adsList(Map<String, dynamic> json, String key) {
  final result = json['result'];
  final raw = json['data'] ?? (result is Map ? result[key] : null);

  return raw is List
      ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : [];
}

/// Dropdown me dikhne wali cheez
abstract class AdsDropdownItem {
  String get id;
  String get label;
}

class GoogleAdsRequest {
  final String? method;
  final String? basesurl;
  final String? endpoint;

  GoogleAdsRequest({this.method, this.basesurl, this.endpoint});

  factory GoogleAdsRequest.fromJson(Map<String, dynamic> json) {
    return GoogleAdsRequest(
      method: json['method'] as String?,
      basesurl: json['basesurl'] as String?,
      endpoint: json['endpoint'] as String?,
    );
  }

  /// "request" na ho to null
  static GoogleAdsRequest? tryParse(dynamic json) => json is Map
      ? GoogleAdsRequest.fromJson(Map<String, dynamic>.from(json))
      : null;

  Map<String, dynamic> toJson() {
    return {'method': method, 'basesurl': basesurl, 'endpoint': endpoint};
  }
}
