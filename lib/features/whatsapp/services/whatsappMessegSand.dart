import 'dart:io';

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
        body: {'phone': phone, 'text': text},
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

  // ============================================================
  // SEND WHATSAPP FLOW MESSAGE (interactive flow)
  //
  // Payload:
  // {
  //   "phone": "+91...",
  //   "interactive": {
  //     "type": "flow",
  //     "header": {"type": "text", "text": "..."},      (optional)
  //     "body":   {"text": "..."},
  //     "footer": {"text": "..."},                      (optional)
  //     "action": {
  //       "name": "flow",
  //       "parameters": {
  //         "flow_message_version": "3",
  //         "flow_token": "flow_<timestamp>",
  //         "flow_id": "<flowId>",
  //         "flow_cta": "Fill Details"
  //       }
  //     }
  //   }
  // }
  // ============================================================

  static Future<dynamic> sendWhatsappFlow({
    required String hid,
    required String phone,
    required String flowId,
    required String body,
    String header = '',
    String footer = '',
    String ctaText = 'Fill Details',
  }) async {
    try {
      final endpoint = '${WhatsappApiEndpoint.sandmessages}$hid';

      final payload = <String, dynamic>{
        'phone': phone,
        'interactive': {
          'type': 'flow',
          if (header.trim().isNotEmpty)
            'header': {'type': 'text', 'text': header.trim()},
          'body': {'text': body.trim()},
          if (footer.trim().isNotEmpty) 'footer': {'text': footer.trim()},
          'action': {
            'name': 'flow',
            'parameters': {
              'flow_message_version': '3',
              'flow_token': 'flow_${DateTime.now().millisecondsSinceEpoch}',
              'flow_id': flowId,
              'flow_cta': ctaText.trim().isEmpty
                  ? 'Fill Details'
                  : ctaText.trim(),
            },
          },
        },
      };

      debugPrint('==================================================');
      debugPrint('WHATSAPP FLOW SEND');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('PAYLOAD: $payload');

      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
        body: payload,
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('RESPONSE: ${response.body}');
      debugPrint('==================================================');

      return response;
    } catch (error, stackTrace) {
      debugPrint('WHATSAPP FLOW SEND ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // SEND IMAGE (file multipart, everything else like text/template)
  // ============================================================

  static Future<dynamic> sendWhatsappImage({
    required String hid,
    required String phone,
    required File file,
    String caption = '',
    void Function(double progress)? onProgress, // 0.0 - 1.0
  }) async {
    try {
      final endpoint = '${WhatsappApiEndpoint.sandmessages}$hid';

      final body = <String, dynamic>{
        'phone': phone,
        'text': 'this is atestmeseg',
        if (caption.trim().isNotEmpty) 'text': caption.trim(),
      };

      debugPrint('==================================================');
      debugPrint('WHATSAPP IMAGE SEND');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('PAYLOAD: $body');
      debugPrint('FILE: ${file.path}');

      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
        body: body,
        fileField: 'file',
        filePath: file.path,
        onUploadProgress: onProgress == null
            ? null
            : (sent, total) => onProgress(total > 0 ? sent / total : 0),
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('RESPONSE: ${response.body}');
      debugPrint('==================================================');

      return response;
    } catch (error, stackTrace) {
      debugPrint('WHATSAPP IMAGE SEND ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
