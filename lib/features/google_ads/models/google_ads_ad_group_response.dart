// ============================================================
// GOOGLE ADS AD GROUP RESPONSE
// GET /api/v1/google-ads/adgroups/<campaignId>
// ============================================================

import 'google_ads_common.dart';

class GoogleAdsAdGroupResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final GoogleAdsRequest? request;
  final List<GoogleAdsAdGroup> adGroups;

  GoogleAdsAdGroupResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.adGroups = const [],
  });

  /// Sirf ENABLED, aur ek id sirf ek baar
  List<GoogleAdsAdGroup> get enabled {
    final seen = <String>{};
    return adGroups.where((g) => g.isEnabled && seen.add(g.adGroupId)).toList();
  }

  factory GoogleAdsAdGroupResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAdsAdGroupResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: GoogleAdsRequest.tryParse(json['request']),
      adGroups: adsList(
        json,
        'adGroups',
      ).map(GoogleAdsAdGroup.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'adGroups': adGroups.map((g) => g.toJson()).toList(),
    };
  }
}

class GoogleAdsAdGroup implements AdsDropdownItem {
  final String adGroupId;
  final String name;
  final String status;

  GoogleAdsAdGroup({
    required this.adGroupId,
    required this.name,
    required this.status,
  });

  bool get isEnabled => adsIsEnabled(status);

  @override
  String get id => adGroupId;

  @override
  String get label => name.isEmpty ? adGroupId : name;

  factory GoogleAdsAdGroup.fromJson(Map<String, dynamic> json) {
    return GoogleAdsAdGroup(
      adGroupId: adsStr(json['adGroupId']),
      name: adsStr(json['name']),
      status: adsStr(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'adGroupId': adGroupId, 'name': name, 'status': status};
  }
}
