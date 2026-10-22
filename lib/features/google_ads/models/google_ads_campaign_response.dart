// ============================================================
// GOOGLE ADS CAMPAIGN RESPONSE
// GET /api/v1/google-ads/campaigns/<accountId>
// ============================================================

import 'google_ads_common.dart';

class GoogleAdsCampaignResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final GoogleAdsRequest? request;
  final List<GoogleAdsCampaign> campaigns;

  GoogleAdsCampaignResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.campaigns = const [],
  });

  /// Same as web: only ENABLED, and each campaign id only once
  List<GoogleAdsCampaign> get enabled {
    final seen = <String>{};
    return campaigns
        .where((c) => c.isEnabled && seen.add(c.campaignId))
        .toList();
  }

  factory GoogleAdsCampaignResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAdsCampaignResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: GoogleAdsRequest.tryParse(json['request']),
      campaigns: adsList(
        json,
        'campaigns',
      ).map(GoogleAdsCampaign.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'campaigns': campaigns.map((c) => c.toJson()).toList(),
    };
  }
}

class GoogleAdsCampaign implements AdsDropdownItem {
  final String campaignId;
  final String name;
  final String status;

  GoogleAdsCampaign({
    required this.campaignId,
    required this.name,
    required this.status,
  });

  bool get isEnabled => adsIsEnabled(status);

  @override
  String get id => campaignId;

  @override
  String get label => name.isEmpty ? campaignId : name;

  factory GoogleAdsCampaign.fromJson(Map<String, dynamic> json) {
    return GoogleAdsCampaign(
      campaignId: adsStr(json['campaignId']),
      name: adsStr(json['name']),
      status: adsStr(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'campaignId': campaignId, 'name': name, 'status': status};
  }
}
