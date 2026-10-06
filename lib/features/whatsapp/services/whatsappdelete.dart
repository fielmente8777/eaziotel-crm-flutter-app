 import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:flutter/foundation.dart';

class WhatsappDeleteChat {
  WhatsappDeleteChat._();

  static Future deleteChats({
    required List<String> ids,
  }) async {
    try {
      final body = {
        'ids': ids,
      };

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🗑️ WHATSAPP DELETE CHAT API');
      debugPrint('==================================================');
      debugPrint(
        'URL: ${BaseUrl.production2}${WhatsappApiEndpoint.deltechat}',
      );
      debugPrint('REQUEST BODY: ${jsonEncode(body)}');

      final response = await ApiClient.delete(
        WhatsappApiEndpoint.deltechat,
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
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP DELETE CHAT API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
