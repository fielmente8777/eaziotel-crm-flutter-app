import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class WhatsappFlowService {
  WhatsappFlowService._();

  static Future<dynamic> getWhatsappflow({required String hid}) async {
    // WhatsappApiEndpoint.flow = '/api/v1/whatsapp/flow/get?hid='
    final String endpoint = '${WhatsappApiEndpoint.flow}$hid';
    final String fullUrl = '${BaseUrl.production2}$endpoint';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('==================================================');
      debugPrint('📋 WHATSAPP FLOW API');
      debugPrint('flow URL: $fullUrl');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Flow API failed: ${response.statusCode}');
      }

      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      debugPrint('❌ WHATSAPP FLOW API ERROR: $e');
      debugPrint('flow URL: $fullUrl');
      debugPrint('STACK: $stackTrace');
      rethrow;
    }
  }
}
