import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:flutter/foundation.dart';

class Whatsappleade {
  Whatsappleade._();

  static Future deleteLeads({
    required String hid,
    required List<String> conversationIds,
  }) async {
    try {
      final body = {'conversationIds': conversationIds};

      // deletWhatsappLeads = '/api/v1/whatsapp/conversations?hid='
      final endpoint = '${WhatsappApiEndpoint.deletWhatsappLeads}$hid';

      debugPrint('==================================================');
      debugPrint('🗑️ WHATSAPP DELETE CONVERSATIONS API');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('REQUEST BODY: ${jsonEncode(body)}');

      final response = await ApiClient.delete(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
        body: body,
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return WhatsappTemplateResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('❌ WHATSAPP DELETE CONVERSATIONS API ERROR: $e');
      debugPrint('STACK: $stackTrace');
      rethrow;
    }
  }
}
