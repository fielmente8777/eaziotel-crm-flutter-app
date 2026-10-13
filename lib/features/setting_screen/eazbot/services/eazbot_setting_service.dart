// ============================================================
// EAZBOT SETTING SERVICE
//
// Settings > Eazbot tab ki API. Sirf yahi file server se baat karti hai.
//
//   publish : POST /leadeazbot/create?hid=<hid>   (JSON)
//             -> {"Message": "Eazbot updated successfully", "Status": true}
//
// Saved bot load karne ki API abhi nahi hai.
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class EazbotSettingService {
  EazbotSettingService._();

  /// Return: server ka message
  static Future<String> publish({
    required String hid,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = '${EazbotApiEndpoint.create}?hid=$hid';

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production,
        body: body,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🤖 EAZBOT: PUBLISH API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      final json = jsonDecode(response.body);

      if (json is Map && json['Status'] == false) {
        throw Exception(json['Message'] ?? 'Unable to publish the chatbot');
      }

      return json is Map
          ? (json['Message']?.toString() ?? 'Chatbot published')
          : 'Chatbot published';
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ EAZBOT: PUBLISH API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
