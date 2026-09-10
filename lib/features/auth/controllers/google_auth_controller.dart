import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/google_auth_service.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthController extends GetxController {
  final isLoading = false.obs;

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<bool> loginWithGoogle() async {
    if (isLoading.value) return false;

    isLoading.value = true;

    try {
      debugPrint('🔵 GOOGLE LOGIN STARTED');

      // ----------------------------------------------------------
      // 1. Google Sign In
      // ----------------------------------------------------------

      final account = await GoogleAuthService.signIn();

      if (account == null) {
        debugPrint('⚠️ GOOGLE LOGIN CANCELLED');

        return false;
      }

      debugPrint('👤 GOOGLE USER: ${account.email}');

      // ----------------------------------------------------------
      // 2. Get Google Authentication
      // ----------------------------------------------------------

      final authentication = await account.authentication;

      // ----------------------------------------------------------
      // 3. Get Google ID Token
      // ----------------------------------------------------------

      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        debugPrint('❌ GOOGLE ID TOKEN NOT FOUND');

        return false;
      }

      debugPrint('🔑 GOOGLE ID TOKEN RECEIVED');

      // ----------------------------------------------------------
      // 4. Send Google ID Token to Backend
      // ----------------------------------------------------------

      final response = await ApiClient.googleAuth(idToken);

      debugPrint(
        '📡 GOOGLE API STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        '📦 GOOGLE API RESPONSE: '
        '${response.body}',
      );

      // ----------------------------------------------------------
      // 5. Check Backend Response
      // ----------------------------------------------------------

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        debugPrint('✅ GOOGLE BACKEND LOGIN SUCCESS');

        debugPrint('📦 DATA: $data');

        // --------------------------------------------------------
        // 6. Get Backend Token
        // --------------------------------------------------------

        final token =
            data['Token'] ??
            data['token'] ??
            data['accessToken'] ??
            data['access_token'];

        if (token != null && token.toString().isNotEmpty) {
          await TokenStorage.saveTokens(accessToken: token.toString());

          debugPrint('💾 BACKEND TOKEN SAVED SUCCESSFULLY');
        } else {
          debugPrint('⚠️ BACKEND TOKEN NOT FOUND');
        }

        return true;
      }

      debugPrint('❌ GOOGLE BACKEND LOGIN FAILED');

      return false;
    } catch (e) {
      debugPrint('❌ GOOGLE LOGIN ERROR: $e');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GOOGLE LOGOUT
  // ============================================================

  Future<void> logout() async {
    debugPrint('🚪 LOGOUT STARTED');

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.clear();

      debugPrint('🗑️ ALL SHARED PREFERENCES CLEARED');
    } catch (e) {
      debugPrint('❌ LOGOUT ERROR: $e');
    }

    debugPrint('✅ LOGOUT FUNCTION COMPLETE');
  }
}
