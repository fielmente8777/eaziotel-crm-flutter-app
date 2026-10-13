// ============================================================
// NOTIFICATION SETTING SERVICE
//
// Settings > Notification tab ki nayi API. Sirf yahi file server se baat karti hai.
//
//   getConfig    : GET  /api/v1/setting/get-config     -> lead source + call notification
//   updateConfig : POST /api/v1/setting/update-config  -> Save button
//
// Baaki data pehle se bani services se aata hai (dobara nahi likha):
//   WhatsappSettingService.getAccountDetails -> notification.enable ("Enable WhatsApp")
//   WhatsappSettingService.getFlowIds        -> "Flow" dropdown
//   WhatsappTemaplate.getWhatsappTemplates   -> "Template" dropdown + preview
//   DashboardController.userNameResponse     -> team members ke naam
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class NotificationSettingService {
  NotificationSettingService._();

  // ============================================================
  // CONFIG
  // GET /api/v1/setting/get-config?hid=<hid>
  // result.docs -> config (lead source), callConfig (call notification)
  // ============================================================

  static Future<Map<String, dynamic>> getConfig({required String hid}) async {
    final endpoint = '${SettingApiEndpoint.getConfig}?hid=$hid';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🔔 NOTIFICATION SETTING: CONFIG API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // result.docs
      final docs = json['result']?['docs'];

      return docs is Map ? Map<String, dynamic>.from(docs) : {};
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ NOTIFICATION SETTING: CONFIG API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // SAVE CONFIG
  // POST /api/v1/setting/update-config?hid=<hid>   (JSON)
  // body: {"config": {...}, "callConfig": {...}}
  // ============================================================

  static Future<void> updateConfig({
    required String hid,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = '${SettingApiEndpoint.updateConfig}?hid=$hid';

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
        body: body,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('💾 NOTIFICATION SETTING: UPDATE CONFIG API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // Server 200 ke saath bhi "success": false bhej sakta hai
      final json = jsonDecode(response.body);

      if (json is Map && json['success'] == false) {
        throw Exception(json['responseMessage'] ?? 'Unable to save');
      }
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ NOTIFICATION SETTING: UPDATE CONFIG API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
