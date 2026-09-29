import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:flutter/foundation.dart';

class WhatsappTemaplate {
  WhatsappTemaplate._();

  static Future<WhatsappTemplateResponse> getWhatsappTemplates({
    required String hid,
  }) async {
    try {
      final response = await ApiClient.get(
        '${WhatsappApiEndpoint.template}$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📱 WHATSAPP TEMPLATE API');
      debugPrint('==================================================');
      debugPrint(
        'URL: ${BaseUrl.production2}${WhatsappApiEndpoint.template}$hid',
      );
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return WhatsappTemplateResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP TEMPLATE API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
