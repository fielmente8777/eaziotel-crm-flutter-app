import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class WhatsappApiService {
  WhatsappApiService._();

  /// GET https://gian-1eve.onrender.com/api/v1/integration/get?hid=<hid>
  static Future<dynamic> getWhatsappIntegration({required String hid}) async {
    try {
      final response = await ApiClient.get(
        '${WhatsappApiEndpoint.getIntegration}?hid=$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📱 WHATSAPP INTEGRATION API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}${WhatsappApiEndpoint.getIntegration}?hid=$hid');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP INTEGRATION API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}