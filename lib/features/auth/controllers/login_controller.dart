import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_error_handler.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/auth/services/gooogleAuth/google_auth_service.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/session_cleaner.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final RxBool showPassword = false.obs;
  /// Sirf "Sign In" (email / password) button ka loader
  final isLoading = false.obs;

  /// Sirf "Continue with Google" button ka loader
  final isGoogleLoading = false.obs;

  /// Koi bhi login chal raha ho to dono button band
  bool get isBusy => isLoading.value || isGoogleLoading.value;

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<bool> login() async {
    final email = emailController.text.trim();

    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || isBusy) {
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

        // Pichhle user ke bache hue controller hatao -> dashboard naya data laye
        SessionCleaner.deleteControllers();

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
    if (isBusy) {
      return false;
    }

    isGoogleLoading.value = true;

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

          SessionCleaner.deleteControllers();

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
      isGoogleLoading.value = false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logoutUser(BuildContext context) async {
    try {
      debugPrint('🚪 LOGGING OUT');

      // Saare controller, SharedPreferences (token, hotel id ...) aur
      // download hui recordings saaf karo
      await SessionCleaner.clearAll();

      // Google logout
      try {
        await GoogleAuthService.signOut();
      } catch (e) {
        debugPrint('Google logout error: $e');
      }

      if (!context.mounted) {
        return;
      }

      // '/login' naam ka route app me nahi hai, isliye seedha screen kholo
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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
