// ============================================================
// MESSAGE TEMPLATE SERVICE
//
//   createTemplate : POST /api/v1/whatsapp/message/template/create?hid=
//   updateTemplate : PUT  /api/v1/whatsapp/message/template/<id>?hid=
//
// Both send form-data (same as web):
//   name, language, category, headerType, header, body, footer,
//   headerVariables (JSON), bodyVariables (JSON), buttons (JSON),
//   file (header photo, only for an IMAGE header)
//
// Delete happens from the Overview card (WhatsappSettingService).
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import '../../models/whatsapp_action_response.dart';

class MessageTemplateService {
  MessageTemplateService._();

  static Future<WhatsappActionResponse> createTemplate({
    required String hid,
    required Map<String, dynamic> fields,
    String? headerFilePath,
  }) {
    return _send(
      title: 'WHATSAPP TEMPLATE CREATE API',
      method: 'POST',
      endpoint: '${WhatsappApiEndpoint.createTemplate}?hid=$hid',
      fields: fields,
      headerFilePath: headerFilePath,
    );
  }

  static Future<WhatsappActionResponse> updateTemplate({
    required String hid,
    required String templateId,
    required Map<String, dynamic> fields,
    String? headerFilePath,
  }) {
    return _send(
      title: 'WHATSAPP TEMPLATE UPDATE API',
      method: 'PUT',
      endpoint: '${WhatsappApiEndpoint.updateTemplate(templateId)}?hid=$hid',
      fields: fields,
      headerFilePath: headerFilePath,
    );
  }

  static Future<WhatsappActionResponse> _send({
    required String title,
    required String method,
    required String endpoint,
    required Map<String, dynamic> fields,
    String? headerFilePath,
  }) async {
    try {
      final response = await ApiClient.multipart(
        endpoint,
        method: method,
        fields: fields,
        files: [
          if (headerFilePath != null)
            ApiUploadFile(field: 'file', path: headerFilePath),
        ],
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📝 $title');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode -> Model
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return WhatsappActionResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ $title ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
