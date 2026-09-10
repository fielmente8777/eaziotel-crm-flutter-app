import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/google_auth_service.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final isLoading = false.obs;

  // ============================================================
  // EMAIL / PASSWORD LOGIN
  // ============================================================

  Future<bool> login() async {
    final email =
        emailController.text.trim();

    final password =
        passwordController.text.trim();

    if (email.isEmpty) {
      return false;
    }

    if (password.isEmpty) {
      return false;
    }

    isLoading.value = true;

    try {
      final response = await ApiClient.post(
        AuthApiEndpoint.login,
        authenticated: false,
        body: {
          'register': 'false',
          'emailId': email,
          'userName': '',
          'accesskey': password,
        },
      );

      debugPrint(
        'LOGIN STATUS: ${response.statusCode}',
      );

      debugPrint(
        'LOGIN RESPONSE: ${response.body}',
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        final token = data['Token'];

        final status = data['Status'];

        debugPrint(
          'API STATUS: $status',
        );

        debugPrint(
          'TOKEN: $token',
        );

        if (status == true &&
            token != null &&
            token.toString().isNotEmpty) {
          await TokenStorage.saveTokens(
            accessToken:
                token.toString(),
          );

          debugPrint(
            'TOKEN SAVED SUCCESSFULLY',
          );

          return true;
        }

        debugPrint(
          'TOKEN NOT FOUND',
        );

        return false;
      }

      debugPrint(
        'LOGIN FAILED: ${response.body}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'LOGIN ERROR: $e',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<bool> loginWithGoogle() async {
    isLoading.value = true;

    try {
      debugPrint(
        '🔵 Starting Google Login...',
      );

      // 1. Google Sign In
      final account =
          await GoogleAuthService.signIn();

      // User cancelled login
      if (account == null) {
        debugPrint(
          '⚠️ Google Login Cancelled',
        );

        return false;
      }

      debugPrint(
        '👤 Google Email: ${account.email}',
      );

      // 2. Get Google authentication
      final authentication =
          await account.authentication;

      // 3. Get Google ID token
      final idToken =
          authentication.idToken;

      if (idToken == null ||
          idToken.isEmpty) {
        debugPrint(
          '❌ Google ID Token is null',
        );

        return false;
      }

      debugPrint(
        '🔑 Google ID Token received',
      );

      // 4. Send token to backend
      final response =
          await ApiClient.googleAuth(
        idToken,
      );

      debugPrint(
        '📡 GOOGLE API STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        '📦 GOOGLE API RESPONSE: '
        '${response.body}',
      );

      // 5. Check response
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data =
            jsonDecode(response.body);

        debugPrint(
          '✅ Google Backend Login Successful',
        );

        debugPrint(
          '📦 DATA: $data',
        );

        // ======================================================
        // GET BACKEND TOKEN
        // ======================================================

        final token =
            data['Token'] ??
            data['token'] ??
            data['accessToken'] ??
            data['access_token'];

        if (token != null &&
            token.toString().isNotEmpty) {
          await TokenStorage.saveTokens(
            accessToken:
                token.toString(),
          );

          debugPrint(
            '💾 BACKEND TOKEN SAVED',
          );
        } else {
          debugPrint(
            '⚠️ No backend token found',
          );
        }

        return true;
      }

      debugPrint(
        '❌ GOOGLE LOGIN FAILED',
      );

      return false;
    } catch (e) {
      debugPrint(
        '❌ GOOGLE LOGIN ERROR: $e',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      debugPrint(
        '🚪 Logging out...',
      );

      // Clear application token
      await TokenStorage.clearTokens();

      // Google sign out
      await GoogleAuthService.signOut();

      debugPrint(
        '✅ LOGOUT SUCCESSFUL',
      );

      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint(
        '❌ LOGOUT ERROR: $e',
      );

      // Even if Google logout has an issue,
      // clear local session and go to login.
      await TokenStorage.clearTokens();

      Get.offAllNamed('/login');
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}