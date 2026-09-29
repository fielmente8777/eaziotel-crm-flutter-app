import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class WhatsappMessageSand {
  WhatsappMessageSand._();

  // ============================================================
  // SEND NORMAL TEXT MESSAGE
  // ============================================================

  static Future<dynamic> sendWhatsappMessage({
    required String hid,
    required String phone,
    required String text,
  }) async {
    try {
      final endpoint = '${WhatsappApiEndpoint.sandmessages}$hid';

      debugPrint('==================================================');
      debugPrint('WHATSAPP TEXT MESSAGE SEND');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('PHONE: $phone');
      debugPrint('TEXT: $text');

      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
        body: {
          'phone': phone,
          'text': text,
        },
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('RESPONSE: ${response.body}');
      debugPrint('==================================================');

      return response;
    } catch (error, stackTrace) {
      debugPrint('WHATSAPP TEXT SEND ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // SEND WHATSAPP TEMPLATE MESSAGE
  // ============================================================

  static Future<dynamic> sendWhatsappTemplate({
    required String hid,
    required String phone,
    required String templateName,
    required String templateLanguage,
    List<String> templateParams = const [],
    List<String> templateParamsHeader = const [],
  }) async {
    try {
      final endpoint = '${WhatsappApiEndpoint.sandmessages}$hid';

      final body = <String, dynamic>{
        'phone': phone,
        'templateName': templateName,
        'templateLanguage': templateLanguage,
        'templateParams': templateParams,
        'templateParamsHeader': templateParamsHeader,
      };

      debugPrint('==================================================');
      debugPrint('WHATSAPP TEMPLATE SEND');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('PAYLOAD: $body');

      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
        body: body,
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('RESPONSE: ${response.body}');
      debugPrint('==================================================');

      return response;
    } catch (error, stackTrace) {
      debugPrint('WHATSAPP TEMPLATE SEND ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}