// ============================================================
// GOOGLE ADS SERVICE
//
// Google Ads Insights ki saari API. Har function:
//   API call  ->  log (URL, STATUS, BODY)  ->  JSON  ->  Response model
//
//   syncGoogleAds        : GET /api/v1/google-ads/sync
//   getGoogleAdsAccounts : GET /api/v1/google-ads/accounts
//   getGoogleAdsCampaigns: GET /api/v1/google-ads/campaigns/<accountId>
//   getGoogleAdsAdGroups : GET /api/v1/google-ads/adgroups/<campaignId>
//   getGoogleAdsAds      : GET /api/v1/google-ads/ads/<adGroupId>
//   getGoogleAdsSummary  : GET /api/v1/google-ads/metrics/summary/<id>
//   getGoogleAdsDevices  : GET /api/v1/google-ads/metrics/devices/<id>
//
// "Connected hai ya nahi" Settings > Integration ki service se aata hai.
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/setting_screen/integration/models/integration_item.dart';
import 'package:eazotel/features/setting_screen/integration/services/integration_setting_service.dart';
import 'package:flutter/foundation.dart';

import '../models/google_ads_account_response.dart';
import '../models/google_ads_ad_group_response.dart';
import '../models/google_ads_ad_response.dart';
import '../models/google_ads_campaign_response.dart';
import '../models/google_ads_device_response.dart';
import '../models/google_ads_summary_response.dart';
import '../models/google_ads_sync_response.dart';

class GoogleAdsService {
  GoogleAdsService._();

  // ============================================================
  // CONNECTED?  (integration/get -> googleAdsInsight.status)
  // ============================================================

  static Future<bool> isGoogleAdsConnected({required String hid}) async {
    final docs = await IntegrationSettingService.getIntegrations(hid: hid);

    return IntegrationItem.isOn(docs['googleAdsInsight']);
  }

  // ============================================================
  // SYNC  (Google -> DB, web hamesha 90 din)
  // ============================================================

  static Future<GoogleAdsSyncResponse> syncGoogleAds({
    required String startDate,
    required String endDate,
    String? accountId,
    String? campaignId,
  }) async {
    final query = [
      'startDate=$startDate',
      'endDate=$endDate',
      if (accountId != null && accountId.isNotEmpty)
        'targetAccountId=$accountId',
      if (campaignId != null && campaignId.isNotEmpty)
        'targetCampaignId=$campaignId',
    ].join('&');

    final endpoint = '${GoogleAdsApiEndpoint.sync}?$query';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📈 GOOGLE ADS SYNC API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return GoogleAdsSyncResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ GOOGLE ADS SYNC API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // ACCOUNTS
  // ============================================================

  static Future<GoogleAdsAccountResponse> getGoogleAdsAccounts() async {
    const endpoint = GoogleAdsApiEndpoint.accounts;

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📈 GOOGLE ADS ACCOUNTS API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return GoogleAdsAccountResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ GOOGLE ADS ACCOUNTS API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // CAMPAIGNS
  // ============================================================

  static Future<GoogleAdsCampaignResponse> getGoogleAdsCampaigns({
    required String accountId,
  }) async {
    final endpoint = GoogleAdsApiEndpoint.campaigns(accountId);

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📈 GOOGLE ADS CAMPAIGNS API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return GoogleAdsCampaignResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ GOOGLE ADS CAMPAIGNS API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // AD GROUPS
  // ============================================================

  static Future<GoogleAdsAdGroupResponse> getGoogleAdsAdGroups({
    required String campaignId,
  }) async {
    final endpoint = GoogleAdsApiEndpoint.adGroups(campaignId);

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📈 GOOGLE ADS AD GROUPS API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return GoogleAdsAdGroupResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ GOOGLE ADS AD GROUPS API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // ADS
  // ============================================================

  static Future<GoogleAdsAdResponse> getGoogleAdsAds({
    required String adGroupId,
  }) async {
    final endpoint = GoogleAdsApiEndpoint.ads(adGroupId);

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📈 GOOGLE ADS ADS API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return GoogleAdsAdResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ GOOGLE ADS ADS API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // SUMMARY  (level = account / campaign / ad)
  // ============================================================

  static Future<GoogleAdsSummaryResponse> getGoogleAdsSummary({
    required String entityId,
    required String level,
    required String startDate,
    required String endDate,
  }) async {
    final endpoint =
        '${GoogleAdsApiEndpoint.summary(entityId)}'
        '?level=$level&startDate=$startDate&endDate=$endDate';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📈 GOOGLE ADS SUMMARY API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return GoogleAdsSummaryResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ GOOGLE ADS SUMMARY API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // DEVICES
  // ============================================================

  static Future<GoogleAdsDeviceResponse> getGoogleAdsDevices({
    required String entityId,
    required String level,
    required String startDate,
    required String endDate,
  }) async {
    final endpoint =
        '${GoogleAdsApiEndpoint.devices(entityId)}'
        '?level=$level&startDate=$startDate&endDate=$endDate';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📈 GOOGLE ADS DEVICES API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return GoogleAdsDeviceResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ GOOGLE ADS DEVICES API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
