// ============================================================
// WHATSAPP HANDLING SERVICE  (chat me "Take over" / "Hand back to AI")
//
//   isAiEnabled     : GET  account/connection/details -> ai.enabled
//   takeOver        : PUT  conversations/<id>/takeover   { userEmail }
//   handBack        : PUT  conversations/<id>/release    { userEmail }
//   isFlowActive    : GET  flow-session?hid&ndid&phone   -> flowSession.isActive
//   stopFlow        : PUT  flow-session?hid&ndid         { phone, isActive:false }
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:flutter/foundation.dart';

class WhatsappHandlingService {
  WhatsappHandlingService._();

  static void _log(String title, String url, int status, String body) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('🤝 $title');
    debugPrint('==================================================');
    debugPrint('URL: ${BaseUrl.production2}$url');
    debugPrint('STATUS: $status');
    debugPrint('BODY: $body');
    debugPrint('==================================================');
  }

  /// json[a][b][c] bina crash ke (beech me kuch na ho to null)
  static dynamic _at(dynamic json, List<String> path) {
    dynamic value = json;
    for (final key in path) {
      if (value is! Map) return null;
      value = value[key];
    }
    return value;
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

  // ============================================================
  // AI ON HAI? (account/connection/details -> ai.enabled)
  // ============================================================

  static Future<bool> isAiEnabled({required String hid}) async {
    final url = '${WhatsappApiEndpoint.accountDetails}?hid=$hid';

    try {
      final response = await ApiClient.get(
        url,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      _log('WHATSAPP AI STATUS API', url, response.statusCode, response.body);

      final json = jsonDecode(response.body);
      final ai = _at(json, ['result', 'docs', 'ai']);

      return ai is Map && ai['enabled'] == true;
    } catch (e, stackTrace) {
      _logError('WHATSAPP AI STATUS API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // MERA EMAIL (take over me bhejna hota hai)
  // GET https://nexon.eazotel.com/user/user-details  -> User.emailId
  // (web dashboard bhi yahi API use karta hai)
  // ============================================================

  static Future<String> getMyEmail() async {
    const url = AuthApiEndpoint.userDetails;

    try {
      final response = await ApiClient.get(url, authenticated: true);

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('👤 USER DETAILS API (email)');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production}$url');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      final json = jsonDecode(response.body);

      return (_at(json, ['User', 'emailId']) ?? '').toString().trim();
    } catch (e, stackTrace) {
      _logError('USER DETAILS API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // TAKE OVER / HAND BACK
  // Server naya handling { mode, assignedTo } bhejta hai
  // ============================================================

  static Future<WhatsappHandlingModel?> takeOver({
    required String conversationId,
    required String userEmail,
  }) {
    return _setHandling(
      WhatsappApiEndpoint.takeOver(conversationId),
      userEmail,
      'WHATSAPP TAKE OVER API',
    );
  }

  static Future<WhatsappHandlingModel?> handBack({
    required String conversationId,
    required String userEmail,
  }) {
    return _setHandling(
      WhatsappApiEndpoint.release(conversationId),
      userEmail,
      'WHATSAPP HAND BACK API',
    );
  }

  static Future<WhatsappHandlingModel?> _setHandling(
    String url,
    String userEmail,
    String title,
  ) async {
    try {
      final response = await ApiClient.put(
        url,
        body: {'userEmail': userEmail},
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      _log(title, url, response.statusCode, response.body);

      final json = jsonDecode(response.body);
      final handling = _at(json, ['result', 'handling']);

      return handling is Map
          ? WhatsappHandlingModel.fromJson(Map<String, dynamic>.from(handling))
          : null;
    } catch (e, stackTrace) {
      _logError(title, e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // AUTOMATED FLOW (form) CHAL RAHA HAI?
  // ============================================================

  static Future<bool> isFlowActive({
    required String hid,
    required String ndid,
    required String phone,
  }) async {
    final url = Uri(
      path: WhatsappApiEndpoint.flowSession,
      queryParameters: {'hid': hid, 'ndid': ndid, 'phone': phone},
    ).toString();

    try {
      final response = await ApiClient.get(
        url,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      _log(
        'WHATSAPP FLOW SESSION API',
        url,
        response.statusCode,
        response.body,
      );

      final json = jsonDecode(response.body);
      final session = _at(json, ['result', 'docs', 'flowSession']);

      return session is Map && session['isActive'] == true;
    } catch (e, stackTrace) {
      _logError('WHATSAPP FLOW SESSION API', e, stackTrace);
      rethrow;
    }
  }

  /// Flow band karo taaki team ka banda reply kar sake
  static Future<void> stopFlow({
    required String hid,
    required String ndid,
    required String phone,
  }) async {
    final url = Uri(
      path: WhatsappApiEndpoint.flowSession,
      queryParameters: {'hid': hid, 'ndid': ndid},
    ).toString();

    try {
      final response = await ApiClient.put(
        url,
        body: {'phone': phone, 'isActive': false},
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      _log('WHATSAPP STOP FLOW API', url, response.statusCode, response.body);
    } catch (e, stackTrace) {
      _logError('WHATSAPP STOP FLOW API', e, stackTrace);
      rethrow;
    }
  }
}
