// ============================================================
// FLOW BUILDER SERVICE
//   createFlow : POST /api/v1/whatsapp/flow/create?hid=
//                body { flowName, category, screens }
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import '../../models/whatsapp_action_response.dart';

class FlowBuilderService {
  FlowBuilderService._();

  static Future<WhatsappActionResponse> createFlow({
    required String hid,
    required String flowName,
    required String category,
    required List<Map<String, dynamic>> screens,
  }) async {
    final endpoint = '${WhatsappApiEndpoint.createFlow}?hid=$hid';

    try {
      final response = await ApiClient.post(
        endpoint,
        body: {'flowName': flowName, 'screens': screens, 'category': category},
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🧩 WHATSAPP FLOW CREATE API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return WhatsappActionResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP FLOW CREATE API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');
      rethrow;
    }
  }
}
