// ============================================================
// GOOGLE ADS SYNC RESPONSE
// GET /api/v1/google-ads/sync?startDate=&endDate=&targetAccountId=&targetCampaignId=
// (pulls fresh data from Google into the DB)
// ============================================================

import 'google_ads_common.dart';

class GoogleAdsSyncResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final GoogleAdsRequest? request;

  GoogleAdsSyncResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
  });

  factory GoogleAdsSyncResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAdsSyncResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: GoogleAdsRequest.tryParse(json['request']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
    };
  }
}
