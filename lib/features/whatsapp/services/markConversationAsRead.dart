
import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class MarkConversationAsRead {
  MarkConversationAsRead._();

  static Future<dynamic> markConversationAsRead({
    required String conversationId,
  }) async {
    try {
      final endpoint =
          WhatsappApiEndpoint.markAsRead(conversationId);

      debugPrint(
        'WHATSAPP MARK AS READ URL: '
        '${BaseUrl.production2}$endpoint',
      );

      final response = await ApiClient.patch(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint(
        'WHATSAPP MARK AS READ STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'WHATSAPP MARK AS READ RESPONSE: '
        '${response.body}',
      );

      return response;
    } catch (error, stackTrace) {
      debugPrint(
        'WHATSAPP MARK AS READ ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}

