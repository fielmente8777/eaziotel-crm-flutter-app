// ============================================================
// MARKETING SERVICE
//
// WhatsApp + Email Marketing ki API calls. Sirf yahi file server se baat karti hai.
//
//   getWhatsappCampaigns : GET /api/v1/whatsapp/campaign?hid=
//   getCampaignDetail    : GET /api/v1/whatsapp/campaign/broadcast/<id>?page=&limit=
//   getEmailRecipients   : GET /api/v1/email-marketing/recipients?hid=&page=&limit=
//   getEmailCampaigns    : GET /api/v1/email-marketing/campaigns?hid=&page=&limit=
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import '../models/marketing_models.dart';

class MarketingService {
  MarketingService._();

  // ============================================================
  // WHATSAPP
  // ============================================================

  static Future<List<WhatsappCampaign>> getWhatsappCampaigns({
    required String hid,
  }) async {
    final json = await _get(
      'WHATSAPP CAMPAIGNS',
      '${MarketingApiEndpoint.whatsappCampaigns}?hid=$hid',
    );

    final list = _map(_map(json['result'])['docs'])['campaigns'];

    return list is List
        ? list
              .whereType<Map>()
              .map(
                (e) => WhatsappCampaign.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : [];
  }

  static Future<
    ({
      WhatsappCampaign campaign,
      List<CampaignRecipient> recipients,
      MarketingPage page,
    })
  >
  getCampaignDetail({
    required String id,
    required int page,
    int limit = 10,
  }) async {
    final json = await _get(
      'CAMPAIGN DETAIL',
      '${MarketingApiEndpoint.whatsappCampaignDetail(id)}?page=$page&limit=$limit',
    );

    final doc = _map(_map(json['result'])['doc']);
    final list = doc['recipients'];

    return (
      campaign: WhatsappCampaign.fromJson(_map(doc['campaign'])),
      recipients: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) =>
                      CampaignRecipient.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <CampaignRecipient>[],
      page: MarketingPage.fromJson(doc['pagination']),
    );
  }

  // ============================================================
  // EMAIL
  // ============================================================

  static Future<({List<EmailRecipient> items, MarketingPage page})>
  getEmailRecipients({
    required String hid,
    required int page,
    int limit = 50,
  }) async {
    final json = await _get(
      'EMAIL RECIPIENTS',
      '${MarketingApiEndpoint.emailRecipients}?hid=$hid&page=$page&limit=$limit',
    );

    final result = _map(json['result']);
    final list = result['doc'];

    return (
      items: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => EmailRecipient.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <EmailRecipient>[],
      page: MarketingPage.fromJson(result['pagination']),
    );
  }

  static Future<({List<EmailCampaign> items, MarketingPage page})>
  getEmailCampaigns({
    required String hid,
    required int page,
    int limit = 20,
  }) async {
    final json = await _get(
      'EMAIL CAMPAIGNS',
      '${MarketingApiEndpoint.emailCampaigns}?hid=$hid&page=$page&limit=$limit',
      // Campaign me poora HTML aata hai, log bhar jata hai
      logBody: false,
    );

    final result = _map(json['result']);
    final list = result['doc'];

    return (
      items: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => EmailCampaign.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <EmailCampaign>[],
      page: MarketingPage.fromJson(result['pagination']),
    );
  }

  // ============================================================
  // COMMON: GET + log + JSON
  // ============================================================

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static Future<Map<String, dynamic>> _get(
    String tag,
    String endpoint, {
    bool logBody = true,
  }) async {
    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📣 MARKETING: $tag API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      if (logBody) debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      return _map(jsonDecode(response.body));
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ MARKETING: $tag API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
