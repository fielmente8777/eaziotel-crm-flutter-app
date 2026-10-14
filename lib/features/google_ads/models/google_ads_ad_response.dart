// ============================================================
// GOOGLE ADS AD RESPONSE
// GET /api/v1/google-ads/ads/<adGroupId>
// ============================================================

import 'google_ads_common.dart';

class GoogleAdsAdResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final GoogleAdsRequest? request;
  final List<GoogleAdsAd> ads;

  GoogleAdsAdResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.ads = const [],
  });

  /// Sirf ENABLED, aur ek ad id sirf ek baar
  List<GoogleAdsAd> get enabled {
    final seen = <String>{};
    return ads.where((a) => a.isEnabled && seen.add(a.adId)).toList();
  }

  factory GoogleAdsAdResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAdsAdResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: GoogleAdsRequest.tryParse(json['request']),
      ads: adsList(json, 'ads').map(GoogleAdsAd.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'ads': ads.map((a) => a.toJson()).toList(),
    };
  }
}

class GoogleAdsAd implements AdsDropdownItem {
  final String adId;
  final String status;
  final List<String> headlines;
  final List<String> descriptions;
  final List<String> finalUrls;

  GoogleAdsAd({
    required this.adId,
    required this.status,
    this.headlines = const [],
    this.descriptions = const [],
    this.finalUrls = const [],
  });

  bool get isEnabled => adsIsEnabled(status);

  String get finalUrl => finalUrls.isEmpty ? '' : finalUrls.first;

  /// "www.example.com" (link na ho to khali)
  String get displayUrl => Uri.tryParse(finalUrl)?.host ?? '';

  @override
  String get id => adId;

  @override
  String get label => finalUrl.isEmpty ? adId : finalUrl;

  factory GoogleAdsAd.fromJson(Map<String, dynamic> json) {
    // headline kabhi {"text": ".."} hota hai, kabhi seedha text
    List<String> texts(dynamic list) => list is List
        ? list
              .map((e) => e is Map ? adsStr(e['text']) : adsStr(e))
              .where((t) => t.isNotEmpty)
              .toList()
        : const [];

    return GoogleAdsAd(
      adId: adsStr(json['adId']),
      status: adsStr(json['status']),
      headlines: texts(json['headlines']),
      descriptions: texts(json['descriptions']),
      finalUrls: texts(json['finalUrls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adId': adId,
      'status': status,
      'headlines': headlines,
      'descriptions': descriptions,
      'finalUrls': finalUrls,
    };
  }
}
