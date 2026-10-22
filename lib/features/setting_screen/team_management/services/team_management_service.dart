// ============================================================
// TEAM MANAGEMENT SERVICE
//
// API calls for Settings > Team Management. Only this file talks to the server.
//
//   createUser : POST /user/create/<token>
//   editUser   : POST /user/edit/<token>
//   deleteUser : POST /user/delete/<emailId>
//
// The members list does not come from a separate API: it comes from the dashboard's
// GET /user/<token> (DashboardController.getUserDetails).
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class TeamManagementService {
  TeamManagementService._();

  // ============================================================
  // CREATE USER
  // ============================================================

  static Future<String> createUser({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _post(TeamApiEndpoint.createUser(token), body, label: 'CREATE USER');
  }

  // ============================================================
  // EDIT USER
  // ============================================================

  static Future<String> editUser({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _post(TeamApiEndpoint.editUser(token), body, label: 'EDIT USER');
  }

  // ============================================================
  // DELETE USER
  // ============================================================

  static Future<String> deleteUser({required String emailId}) {
    return _post(TeamApiEndpoint.deleteUser(emailId), {}, label: 'DELETE USER');
  }

  // ============================================================
  // SHARED POST FOR ALL THREE
  //
  // Jawab: {"Message": "...", "Status": true / false}
  // If Status is false (like "User already exists with this email id")
  // that Message is passed on as the error.
  // ============================================================

  static Future<String> _post(
    String endpoint,
    Map<String, dynamic> body, {
    required String label,
  }) async {
    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production,
        body: body,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('👥 TEAM MANAGEMENT: $label API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final json = jsonDecode(response.body);
      final message = json is Map ? json['Message']?.toString() : null;

      if (json is Map && json['Status'] == false) {
        throw Exception(message ?? 'Something went wrong');
      }

      return message ?? 'Done';
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ TEAM MANAGEMENT: $label API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
