import 'dart:convert';

 
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  Future<bool> login() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email address',
      );

      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter password',
      );

      return false;
    }

    isLoading.value = true;

    try {
      final response = await ApiClient.post(
        AuthApiEndpoint.login,
        authenticated: false,
        body: {
          'register': 'false',
          'emailId': emailController.text.trim(),
          'userName': '',
          'accesskey': passwordController.text.trim(),
        },
      );

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN RESPONSE: ${response.body}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        final accessToken =
            data['accessToken'] ??
            data['access_token'] ??
            data['token'];

        final refreshToken =
            data['refreshToken'] ??
            data['refresh_token'];

        if (accessToken == null ||
            accessToken.toString().isEmpty) {
          Get.snackbar(
            'Login Error',
            'Access token not found',
          );

          return false;
        }

        await TokenStorage.saveTokens(
          accessToken: accessToken.toString(),
          refreshToken: refreshToken?.toString(),
        );

        Get.snackbar(
          'Success',
          'Login successful',
        );

        return true;
      }

      String message = 'Login failed';

      try {
        final data = jsonDecode(response.body);

        message =
            data['message']?.toString() ??
            data['error']?.toString() ??
            message;
      } catch (_) {}

      Get.snackbar(
        'Login Failed',
        message,
      );

      return false;
    } catch (e) {
      print('LOGIN ERROR: $e');

      Get.snackbar(
        'Error',
        e.toString(),
      );

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