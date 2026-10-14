// ============================================================
// SEO TOKEN RESPONSE
// GET /api/v1/seo/seo-intelligence/tokens
//
//   result.balance : kitne credit bache hain
//   result.pricing : localPerKeyword, websitePerKeyword, geoGridScan
// ============================================================

import 'seo_common.dart';

class SeoTokenResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final SeoRequest? request;
  final SeoTokens result;

  SeoTokenResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result = const SeoTokens(),
  });

  factory SeoTokenResponse.fromJson(Map<String, dynamic> json) {
    return SeoTokenResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: SeoRequest.tryParse(json['request']),
      result: SeoTokens.fromJson(seoBody(json)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'result': result.toJson(),
    };
  }
}

class SeoTokens {
  /// null = pata nahi (API fail)
  final int? balance;
  final SeoTokenPricing pricing;

  const SeoTokens({this.balance, this.pricing = const SeoTokenPricing()});

  factory SeoTokens.fromJson(Map<String, dynamic> json) {
    return SeoTokens(
      balance: seoNumOrNull(json['balance'])?.round(),
      pricing: json['pricing'] is Map
          ? SeoTokenPricing.fromJson(seoMap(json['pricing']))
          : const SeoTokenPricing(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'balance': balance, 'pricing': pricing.toJson()};
  }
}

/// Kis kaam ke kitne credit lagte hain.
/// Default web dashboard (seoTokenPricing.ts) jaise hi hain.
class SeoTokenPricing {
  final int localPerKeyword;
  final int websitePerKeyword;
  final int geoGridScan;

  const SeoTokenPricing({
    this.localPerKeyword = 1,
    this.websitePerKeyword = 2,
    this.geoGridScan = 3,
  });

  /// Website keyword: India 2 credit, baaki desh 3 credit
  static int websiteFor(String country) =>
      country.isEmpty || country.toUpperCase() == 'IN' ? 2 : 3;

  factory SeoTokenPricing.fromJson(Map<String, dynamic> json) {
    int read(String key, int fallback) {
      final v = seoNumOrNull(json[key])?.round();
      return v == null || v <= 0 ? fallback : v;
    }

    return SeoTokenPricing(
      localPerKeyword: read('localPerKeyword', 1),
      websitePerKeyword: read('websitePerKeyword', 2),
      geoGridScan: read('geoGridScan', 3),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localPerKeyword': localPerKeyword,
      'websitePerKeyword': websitePerKeyword,
      'geoGridScan': geoGridScan,
    };
  }
}
