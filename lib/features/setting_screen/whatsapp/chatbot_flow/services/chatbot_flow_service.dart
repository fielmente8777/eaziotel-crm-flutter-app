// ============================================================
// CHATBOT FLOW SERVICE  (WhatsApp Flow)
//
//   getChatbotFlow     : GET  /api/v1/whatsapp/flow?hid=
//   publishChatbotFlow : POST /api/v1/whatsapp/flow?hid=  (form-data)
//                          nodes (JSON), edges (JSON),
//                          file_<blockId> (Send Message ki photo/video...)
//   uploadImage        : POST /api/v1/image/upload (form-data "file")
//                          carousel card ki photo -> result.doc.imageUrl
//
// Form flow ki list (Flow node ke liye): WhatsappSettingService.getFlows
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import '../../models/whatsapp_action_response.dart';
import '../models/chatbot_flow_models.dart';

class ChatbotFlowService {
  ChatbotFlowService._();

  static const String _base = BaseUrl.production2;

  static Future<ChatbotFlowResponse> getChatbotFlow({
    required String hid,
  }) async {
    final endpoint = '${WhatsappApiEndpoint.chatbotFlow}?hid=$hid';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: _base,
      );

      _log(
        'CHATBOT FLOW GET API',
        endpoint,
        response.statusCode,
        response.body,
      );

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return ChatbotFlowResponse.fromJson(json);
    } catch (e, stackTrace) {
      _logError('CHATBOT FLOW GET API', e, stackTrace);
      rethrow;
    }
  }

  static Future<WhatsappActionResponse> publishChatbotFlow({
    required String hid,
    required List<ChatbotNode> nodes,
    required List<ChatbotEdge> edges,

    /// blockId -> phone / computer par file ka rasta
    Map<String, String> files = const {},
  }) async {
    final endpoint = '${WhatsappApiEndpoint.chatbotFlow}?hid=$hid';

    try {
      final response = await ApiClient.multipart(
        endpoint,
        fields: {
          'nodes': jsonEncode(nodes.map((n) => n.toJson()).toList()),
          'edges': jsonEncode(edges.map((e) => e.toJson()).toList()),
        },
        files: [
          for (final f in files.entries)
            ApiUploadFile(field: 'file_${f.key}', path: f.value),
        ],
        authenticated: true,
        baseUrl: _base,
      );

      _log(
        'CHATBOT FLOW PUBLISH API',
        endpoint,
        response.statusCode,
        response.body,
      );

      final Map<String, dynamic> json = response.body.trim().isEmpty
          ? {'success': true}
          : jsonDecode(response.body) as Map<String, dynamic>;

      return WhatsappActionResponse.fromJson(json);
    } catch (e, stackTrace) {
      _logError('CHATBOT FLOW PUBLISH API', e, stackTrace);
      rethrow;
    }
  }

  /// Return: photo ka link (fail ho to null)
  static Future<String?> uploadImage({required String path}) async {
    const endpoint = WhatsappApiEndpoint.imageUpload;

    try {
      final response = await ApiClient.multipart(
        endpoint,
        files: [ApiUploadFile(field: 'file', path: path)],
        authenticated: false,
        baseUrl: _base,
      );

      _log('IMAGE UPLOAD API', endpoint, response.statusCode, response.body);

      final json = jsonDecode(response.body);
      final link = chatbotMap(
        chatbotMap(chatbotMap(json)['result'])['doc'],
      )['imageUrl'];
      return link?.toString();
    } catch (e, stackTrace) {
      _logError('IMAGE UPLOAD API', e, stackTrace);
      return null;
    }
  }

  static void _log(String title, String endpoint, int status, String body) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('🤖 $title');
    debugPrint('==================================================');
    debugPrint('URL: $_base$endpoint');
    debugPrint('STATUS: $status');
    debugPrint('BODY: $body');
    debugPrint('==================================================');
  }

  static void _logError(String title, Object e, StackTrace stackTrace) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('❌ $title ERROR');
    debugPrint('==================================================');
    debugPrint('ERROR: $e');
    debugPrint('STACK: $stackTrace');
    debugPrint('==================================================');
  }
}
