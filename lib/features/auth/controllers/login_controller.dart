import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/google_auth_service.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  // ============================================================
  // EMAIL / PASSWORD LOGIN
  // ============================================================

  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

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

      debugPrint('LOGIN STATUS: ${response.statusCode}');

      debugPrint('LOGIN RESPONSE: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final token = data['Token'];
        final status = data['Status'];

        debugPrint('API STATUS: $status');

        if (status == true && token != null && token.toString().isNotEmpty) {
          await TokenStorage.saveTokens(accessToken: token.toString());

          debugPrint('TOKEN SAVED SUCCESSFULLY');

          return true;
        }

        debugPrint('TOKEN NOT FOUND');

        return false;
      }

      debugPrint('LOGIN FAILED: ${response.body}');

      return false;
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

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
      debugPrint('🔵 Starting Google Login...');

      final account = await GoogleAuthService.signIn();

      if (account == null) {
        debugPrint('⚠️ Google Login Cancelled');

        return false;
      }

      debugPrint('👤 Google Email: ${account.email}');

      final authentication = await account.authentication;

      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        debugPrint('❌ Google ID Token is null');

        return false;
      }

      debugPrint('🔑 Google ID Token received');

      final response = await ApiClient.googleAuth(idToken);

      debugPrint(
        '📡 GOOGLE API STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        '📦 GOOGLE API RESPONSE: '
        '${response.body}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        debugPrint('✅ Google Backend Login Successful');

        final token =
            data['Token'] ??
            data['token'] ??
            data['accessToken'] ??
            data['access_token'];

        if (token != null && token.toString().isNotEmpty) {
          await TokenStorage.saveTokens(accessToken: token.toString());

          debugPrint('💾 BACKEND TOKEN SAVED');
        } else {
          debugPrint('⚠️ No backend token found');
        }

        return true;
      }

      debugPrint('❌ GOOGLE LOGIN FAILED');

      return false;
    } catch (e) {
      debugPrint('❌ GOOGLE LOGIN ERROR: $e');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  Future<void> logoutUser(BuildContext context) async {
    try {
      debugPrint('🚪 Logging out...');

      // 1. Clear DashboardController
      if (Get.isRegistered<DashboardController>()) {
        Get.delete<DashboardController>(force: true);
        debugPrint('🧹 DashboardController deleted');
      }

      // 2. Clear LocationController
      if (Get.isRegistered<LocationController>()) {
        Get.delete<LocationController>(force: true);
        debugPrint('🧹 LocationController deleted');
      }

      // 3. Clear BottomNavController
      if (Get.isRegistered<BottomNavController>()) {
        Get.delete<BottomNavController>(force: true);
        debugPrint('🧹 BottomNavController deleted');
      }

      // ============================================================
      // CLEAR DASHBOARD CONTROLLER
      // ============================================================

      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();

        dashboardController.clearDashboardData();

        Get.delete<DashboardController>(force: true);

        debugPrint('🧹 DashboardController deleted');
      }

      // ============================================================
      // CLEAR TOKEN
      // ============================================================

      await TokenStorage.clearTokens();

      // ============================================================
      // GOOGLE LOGOUT
      // ============================================================

      try {
        await GoogleAuthService.signOut();

        debugPrint('✅ Google Sign Out Successful');
      } catch (e) {
        debugPrint('⚠️ Google Sign Out Error: $e');
      }

      debugPrint('✅ LOGOUT SUCCESSFUL');

      // ============================================================
      // LOGIN SCREEN
      // ============================================================

      if (!context.mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      debugPrint('❌ LOGOUT ERROR: $e');

      // Always clear token
      await TokenStorage.clearTokens();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  } // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}
