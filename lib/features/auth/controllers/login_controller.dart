import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_error_handler.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/auth/services/gooogleAuth/google_auth_service.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final RxBool showPassword = false.obs;
  final isLoading = false.obs;

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<bool> login() async {
    final email = emailController.text.trim();

    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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

      final Map<String, dynamic> data = jsonDecode(response.body);

      final token = data['Token'];
      final status = data['Status'];

      if (status == true && token != null && token.toString().isNotEmpty) {
        await TokenStorage.saveTokens(accessToken: token.toString());

        debugPrint('TOKEN SAVED SUCCESSFULLY');

        // Password manager ko bolo "Save password?" poochhe.
        // Ye field khali karne se PEHLE hona chahiye.
        TextInput.finishAutofillContext(shouldSave: true);

        // Login ho gaya -> email / password field khali kar do
        emailController.clear();
        passwordController.clear();

        return true;
      }

      return false;
    } on ApiException catch (e) {
      debugPrint('LOGIN API ERROR: ${e.message}');

      ApiErrorHandler.handle(e);

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
    if (isLoading.value) {
      return false;
    }

    isLoading.value = true;

    try {
      debugPrint('🔵 GOOGLE LOGIN STARTED');

      final account = await GoogleAuthService.signIn();

      if (account == null) {
        return false;
      }

      debugPrint('👤 GOOGLE USER: ${account.email}');

      final authentication = await account.authentication;

      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        debugPrint('❌ GOOGLE ID TOKEN NOT FOUND');

        return false;
      }

      debugPrint('🔑 GOOGLE ID TOKEN RECEIVED$idToken');

      final response = await ApiClient.googleAuth(idToken);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        final token =
            data['Token'] ??
            data['token'] ??
            data['accessToken'] ??
            data['access_token'];

        if (token != null && token.toString().isNotEmpty) {
          await TokenStorage.saveTokens(accessToken: token.toString());

          debugPrint('💾 BACKEND TOKEN SAVED');

          emailController.clear();
          passwordController.clear();

          return true;
        }
      }

      return false;
    } on ApiException catch (e) {
      debugPrint('GOOGLE API ERROR: ${e.message}');

      ApiErrorHandler.handle(e);

      return false;
    } catch (e) {
      debugPrint('GOOGLE LOGIN ERROR: $e');

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
      debugPrint('🚪 LOGGING OUT');

      // Dashboard
      if (Get.isRegistered<DashboardController>()) {
        final dashboard = Get.find<DashboardController>();

        dashboard.clearDashboardData();

        Get.delete<DashboardController>(force: true);
      }

      // Location
      if (Get.isRegistered<LocationController>()) {
        Get.delete<LocationController>(force: true);
      }

      // Bottom navigation
      if (Get.isRegistered<BottomNavController>()) {
        Get.delete<BottomNavController>(force: true);
      }

      // Clear token
      await TokenStorage.clearTokens();

      // Google logout
      try {
        await GoogleAuthService.signOut();
      } catch (e) {
        debugPrint('Google logout error: $e');
      }

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');

      await TokenStorage.clearTokens();

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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
