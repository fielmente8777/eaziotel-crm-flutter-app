// ============================================================
// GOOGLE ADS COMMON (used by all response models)
//
//   GoogleAdsRequest : the "request" part of the response (method, basesurl, endpoint)
//   AdsDropdownItem  : one line of the Account / Campaign / Ad Group / Ad dropdown
//   adsNum / adsStr  : get a number / text from JSON (null safe)
//   adsIsEnabled     : same as web, only ENABLED ("2") items are shown
//   adsList          : works whether the list is in "data" or "result.<key>"
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

/// Same as web: `response.data` or `response.result.<key>`
List<Map<String, dynamic>> adsList(Map<String, dynamic> json, String key) {
  final result = json['result'];
  final raw = json['data'] ?? (result is Map ? result[key] : null);

  return raw is List
      ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : [];
}

/// What is shown in the dropdown
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

  /// null if there is no "request"
  static GoogleAdsRequest? tryParse(dynamic json) => json is Map
      ? GoogleAdsRequest.fromJson(Map<String, dynamic>.from(json))
      : null;

  Map<String, dynamic> toJson() {
    return {'method': method, 'basesurl': basesurl, 'endpoint': endpoint};
  }
}
