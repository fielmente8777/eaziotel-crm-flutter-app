// ============================================================
// QUICK REPLY SERVICE
//
//   getQuickReplies  : GET    /api/v1/quick-reply?hid=
//   saveQuickReply   : POST   /api/v1/quick-reply?hid=        (new)
//                      PUT    /api/v1/quick-reply/<id>?hid=   (edit)
//   deleteQuickReply : DELETE /api/v1/quick-reply/<id>?hid=
//
// Save sends form-data (same as web):
//   title, text, shortcut,
//   file  (har nayi photo / video / document, ek hi naam se kai baar),
//   media (JSON: already uploaded files to keep)
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import '../../models/whatsapp_action_response.dart';
import '../models/quick_reply_response.dart';

class QuickReplyService {
  QuickReplyService._();

  static const String _base = BaseUrl.production2;

  static Future<QuickReplyListResponse> getQuickReplies({
    required String hid,
  }) async {
    final endpoint = '${QuickReplyApiEndpoint.list}?hid=$hid';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: _base,
      );

      _log(
        'QUICK REPLY LIST API',
        endpoint,
        response.statusCode,
        response.body,
      );

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return QuickReplyListResponse.fromJson(json);
    } catch (e, stackTrace) {
      _logError('QUICK REPLY LIST API', e, stackTrace);
      rethrow;
    }
  }

  static Future<WhatsappActionResponse> saveQuickReply({
    required String hid,
    String? id,
    required String title,
    required String text,
    String shortcut = '',
    List<String> newFilePaths = const [],
    List<QuickReplyMedia> keepMedia = const [],
  }) async {
    final isEdit = id != null && id.isNotEmpty;
    final endpoint = isEdit
        ? '${QuickReplyApiEndpoint.byId(id)}?hid=$hid'
        : '${QuickReplyApiEndpoint.list}?hid=$hid';

    try {
      final response = await ApiClient.multipart(
        endpoint,
        method: isEdit ? 'PUT' : 'POST',
        fields: {
          'title': title,
          'text': text,
          'shortcut': shortcut,
          'media': jsonEncode(keepMedia.map((m) => m.toJson()).toList()),
        },
        files: [
          for (final path in newFilePaths)
            ApiUploadFile(field: 'file', path: path),
        ],
        authenticated: true,
        baseUrl: _base,
      );

      _log(
        'QUICK REPLY SAVE API',
        endpoint,
        response.statusCode,
        response.body,
      );

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return WhatsappActionResponse.fromJson(json);
    } catch (e, stackTrace) {
      _logError('QUICK REPLY SAVE API', e, stackTrace);
      rethrow;
    }
  }

  static Future<WhatsappActionResponse> deleteQuickReply({
    required String hid,
    required String id,
  }) async {
    final endpoint = '${QuickReplyApiEndpoint.byId(id)}?hid=$hid';

    try {
      final response = await ApiClient.delete(
        endpoint,
        authenticated: true,
        baseUrl: _base,
      );

      _log(
        'QUICK REPLY DELETE API',
        endpoint,
        response.statusCode,
        response.body,
      );

      final Map<String, dynamic> json = response.body.trim().isEmpty
          ? {'success': true}
          : jsonDecode(response.body) as Map<String, dynamic>;

      return WhatsappActionResponse.fromJson(json);
    } catch (e, stackTrace) {
      _logError('QUICK REPLY DELETE API', e, stackTrace);
      rethrow;
    }
  }

  static void _log(String title, String endpoint, int status, String body) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('⚡ $title');
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
