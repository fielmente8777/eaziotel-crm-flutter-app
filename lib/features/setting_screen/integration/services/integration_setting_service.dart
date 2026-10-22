// ============================================================
// INTEGRATION SETTING SERVICE
//
// API calls for the Settings > Integration tab. Only this file talks to the server.
//
//   getGoogleStatus    : GET  /google/status/<hid>
//   getGaPropertyId    : GET  /google/analytics-data/<hid>  -> activePropertyId
//   getGscSettings     : GET  /google/gsc-settings/<propertyId>
//   saveGscSettings    : POST /google/save-gsc-settings
//   getGoogleAdsAuthUrl: GET  /api/v1/google-ads/auth/google/start?ndid=
//   connectExotel      : POST /api/v1/call/auth/connect
//
// An existing service is reused (not written again):
//   WhatsappApiService.getWhatsappIntegration -> /api/v1/integration/get
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/whatsapp/services/whatsapp_Integration_api.dart';
import 'package:flutter/foundation.dart';

import '../models/gsc_settings.dart';
import '../models/integration_item.dart';

class IntegrationSettingService {
  IntegrationSettingService._();

  /// integration/get -> result.docs  (like {"exotel": true, "meta": true ...})
  static Future<Map<String, dynamic>> getIntegrations({
    required String hid,
  }) async {
    final json = await WhatsappApiService.getWhatsappIntegration(hid: hid);
    final docs = json is Map && json['result'] is Map
        ? json['result']['docs']
        : null;

    return docs is Map ? Map<String, dynamic>.from(docs) : {};
  }

  static Future<GoogleConnection> getGoogleStatus({required String hid}) async {
    final endpoint = IntegrationApiEndpoint.googleStatus(hid);

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🔗 INTEGRATION: GOOGLE STATUS API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      final json = jsonDecode(response.body);

      return json is Map
          ? GoogleConnection.fromJson(Map<String, dynamic>.from(json))
          : const GoogleConnection();
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ INTEGRATION: GOOGLE STATUS API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // SEARCH CONSOLE
  // ============================================================

  /// The hotel's Google Analytics property id. null if not found (GA not connected).
  static Future<String?> getGaPropertyId({required String hid}) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final json = await _send(
      'GA PROPERTY',
      () => ApiClient.get(
        '${AnalytisApiEndpoint.analytics_data}$hid?startDate=$today&endDate=$today',
        authenticated: true,
        baseUrl: BaseUrl.production,
      ),
      logBody: false,
    );

    final id = json['activePropertyId']?.toString() ?? '';

    return id.isEmpty ? null : id;
  }

  static Future<GscSettings> getGscSettings({
    required String propertyId,
  }) async {
    final json = await _send(
      'GSC SETTINGS',
      () => ApiClient.get(
        IntegrationApiEndpoint.gscSettings(propertyId),
        authenticated: true,
        baseUrl: BaseUrl.production,
      ),
    );

    return GscSettings.fromJson(json);
  }

  static Future<void> saveGscSettings({
    required Map<String, dynamic> body,
  }) async {
    final json = await _send(
      'SAVE GSC SETTINGS',
      () => ApiClient.post(
        IntegrationApiEndpoint.saveGscSettings,
        authenticated: true,
        baseUrl: BaseUrl.production,
        body: body,
      ),
    );

    if (json['success'] == false) {
      throw Exception(json['message'] ?? 'Unable to save');
    }
  }

  // ============================================================
  // GOOGLE ADS  (Google login link, opens in the browser)
  // ============================================================

  static Future<String> getGoogleAdsAuthUrl({required String ndid}) async {
    final json = await _send(
      'GOOGLE ADS START',
      () => ApiClient.get(
        '${IntegrationApiEndpoint.googleAdsStart}?ndid=$ndid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      ),
    );

    final url = json['googleAuthUrl']?.toString() ?? '';

    if (!url.startsWith('http')) throw Exception('Google login link not found');

    return url;
  }

  // ============================================================
  // EXOTEL
  // body: {apiKey, authToken, subDomain, accountSID, virtualNumber}
  // The server encrypts and saves the credentials.
  // ============================================================

  static Future<void> connectExotel({
    required Map<String, dynamic> body,
  }) async {
    final json = await _send(
      'EXOTEL CONNECT',
      () => ApiClient.post(
        CallApiEndpoint.connectExotel,
        authenticated: true,
        baseUrl: BaseUrl.production2,
        body: body,
      ),
      // The body has encrypted keys, do not show them in the log
      logBody: false,
    );

    if (json['success'] == false) {
      throw Exception(json['responseMessage'] ?? 'Unable to connect Exotel');
    }
  }

  // ============================================================
  // COMMON: log + JSON
  // ============================================================

  static Future<Map<String, dynamic>> _send(
    String tag,
    Future<dynamic> Function() request, {
    bool logBody = true,
  }) async {
    try {
      final response = await request();

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🔗 INTEGRATION: $tag API');
      debugPrint('==================================================');
      debugPrint('URL: ${response.request?.url}');
      debugPrint('STATUS: ${response.statusCode}');
      if (logBody) debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      final json = jsonDecode(response.body);

      return json is Map ? Map<String, dynamic>.from(json) : {};
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ INTEGRATION: $tag API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
