// ============================================================
// SEO SUGGESTION RESPONSE
// POST /api/v1/seo/seo-intelligence/suggest-keywords
//
//   result.suggestions : ["hotel in indirapuram", ...]
// ============================================================

import 'seo_common.dart';

class SeoSuggestionResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final SeoRequest? request;
  final List<String> suggestions;

  SeoSuggestionResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.suggestions = const [],
  });

  factory SeoSuggestionResponse.fromJson(Map<String, dynamic> json) {
    final list = seoBody(json)['suggestions'];

    return SeoSuggestionResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: SeoRequest.tryParse(json['request']),
      suggestions: list is List
          ? list.map(seoStr).where((s) => s.trim().isNotEmpty).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'suggestions': suggestions,
    };
  }
}
