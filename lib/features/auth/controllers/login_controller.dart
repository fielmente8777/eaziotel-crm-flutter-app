import 'dart:convert';

import 'package:eazotel/core/api/api_clint.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

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

        // Your API returns "Token"
        final token = data['Token'];

        final status = data['Status'];

        debugPrint('API STATUS: $status');
        debugPrint('TOKEN: $token');

        if (status == true && token != null && token.toString().isNotEmpty) {
          // Save token
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

  Future<void> logout() async {
    await TokenStorage.clearTokens();

    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}
