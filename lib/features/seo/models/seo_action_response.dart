// ============================================================
// SEO ACTION RESPONSE
// Jo API sirf "ho gaya" batati hain:
//   track, track-link, refresh-keyword, delete, trigger-grid-scan,
//   update-radius, update-grid-keyword, onboarding, set-website,
//   update-website-country
// ============================================================

import 'seo_common.dart';

class SeoActionResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final SeoRequest? request;

  /// API ka baaki data (jaisa aaya waisa)
  final Map<String, dynamic> result;

  SeoActionResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result = const {},
  });

  factory SeoActionResponse.fromJson(Map<String, dynamic> json) {
    return SeoActionResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: SeoRequest.tryParse(json['request']),
      result: seoBody(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'result': result,
    };
  }
}
