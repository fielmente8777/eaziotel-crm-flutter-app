// ============================================================
// GOOGLE ADS ACCOUNT RESPONSE
// GET /api/v1/google-ads/accounts
// ============================================================

import 'google_ads_common.dart';

class GoogleAdsAccountResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final GoogleAdsRequest? request;
  final List<GoogleAdsAccount> accounts;

  GoogleAdsAccountResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.accounts = const [],
  });

  factory GoogleAdsAccountResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAdsAccountResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: GoogleAdsRequest.tryParse(json['request']),
      accounts: adsList(json, 'accounts')
          .map(GoogleAdsAccount.fromJson)
          .where((account) => account.id.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'accounts': accounts.map((a) => a.toJson()).toList(),
    };
  }
}

class GoogleAdsAccount implements AdsDropdownItem {
  final String clientCustomerId;
  final String accountName;

  GoogleAdsAccount({required this.clientCustomerId, required this.accountName});

  @override
  String get id => clientCustomerId;

  @override
  String get label => accountName.isEmpty ? clientCustomerId : accountName;

  factory GoogleAdsAccount.fromJson(Map<String, dynamic> json) {
    return GoogleAdsAccount(
      // Kuch account me id "googleAccountId" naam se aati hai
      clientCustomerId: adsStr(
        json['clientCustomerId'] ?? json['googleAccountId'],
      ),
      accountName: adsStr(json['accountName']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'clientCustomerId': clientCustomerId, 'accountName': accountName};
  }
}
