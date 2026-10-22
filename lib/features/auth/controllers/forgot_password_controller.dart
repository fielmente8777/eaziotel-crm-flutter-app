// ============================================================
// FORGOT PASSWORD  (web: Login.jsx + ResetPassword.jsx)
//
//   1. email      -> POST /api/v1/auth/forgot-password  (6-digit code by email)
//   2. reset      -> code + new password -> POST /api/v1/auth/reset-password
//   3. done       -> "Password updated" -> back to Sign in
// ============================================================

import 'dart:async';
import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ForgotStep { email, reset, done }

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({String email = ''}) {
    emailController.text = email;
  }

  static const int otpLength = 6;
  static const int resendSeconds = 30;
  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final step = ForgotStep.email.obs;
  final isSending = false.obs;
  final isResetting = false.obs;
  final showPassword = false.obs;

  /// The new password so far (for the live checklist)
  final password = ''.obs;

  /// "Resend in 30s"
  final cooldown = 0.obs;
  Timer? _timer;

  /// field -> error text
  final errors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(
      () => password.value = passwordController.text,
    );
  }

  /// Same rules as the web
  static final List<({String label, bool Function(String) test})> rules = [
    (label: 'At least 8 characters', test: (v) => v.length >= 8),
    (label: 'One letter', test: (v) => RegExp('[A-Za-z]').hasMatch(v)),
    (label: 'One number', test: (v) => RegExp(r'\d').hasMatch(v)),
  ];

  String get email => emailController.text.trim();

  void clearError(String field) {
    if (errors.containsKey(field)) errors.remove(field);
  }

  String? _emailError() {
    if (email.isEmpty) return 'Email is required';
    if (!_emailRe.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  // ============================================================
  // API
  // ============================================================

  /// Get the server's message, otherwise the fallback
  String _message(Object e, String fallback) {
    if (e is ApiException) {
      try {
        final body = jsonDecode(e.responseBody ?? '');
        if (body is Map) {
          final m =
              body['responseMessage'] ?? body['message'] ?? body['error'];
          if (m != null && '$m'.isNotEmpty) return '$m';
        }
      } catch (_) {}
      return e.message;
    }
    return fallback;
  }

  void _toast(String title, String message, {bool error = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
      colorText: Colors.white,
      duration: Duration(seconds: error ? 4 : 3),
    );
  }

  Future<bool> _post(String url, Map<String, dynamic> body, String fail) async {
    try {
      final response = await ApiClient.post(
        url,
        baseUrl: BaseUrl.production2,
        authenticated: false,
        body: body,
      );
      final data = jsonDecode(response.body);
      if (data is Map && data['success'] == true) return true;
      _toast(
        'Error',
        (data is Map ? data['responseMessage']?.toString() : null) ?? fail,
        error: true,
      );
      return false;
    } catch (e) {
      _toast('Error', _message(e, fail), error: true);
      return false;
    }
  }

  // ============================================================
  // 1. SEND THE CODE
  // ============================================================

  Future<void> sendCode({bool resend = false}) async {
    if (isSending.value || (resend && cooldown.value > 0)) return;
    final error = _emailError();
    if (error != null) {
      errors['email'] = error;
      return;
    }

    isSending.value = true;
    final ok = await _post(
      AuthApiEndpoint.forgotPassword,
      {'email': email},
      'There was an error sending the email. Please try again.',
    );
    isSending.value = false;
    if (!ok) return;

    _toast('Code sent', 'Please check your email for the reset code.');
    step.value = ForgotStep.reset;
    _startCooldown();
  }

  /// "Already have a code?" -> go straight to the code step
  void haveCode() {
    errors.clear();
    step.value = ForgotStep.reset;
  }

  void _startCooldown() {
    _timer?.cancel();
    cooldown.value = resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (cooldown.value <= 1) {
        cooldown.value = 0;
        t.cancel();
      } else {
        cooldown.value--;
      }
    });
  }

  // ============================================================
  // 2. NEW PASSWORD
  // ============================================================

  bool _validateReset() {
    final next = <String, String>{};
    final emailError = _emailError();
    if (emailError != null) next['email'] = emailError;

    if (!RegExp('^\\d{$otpLength}\$').hasMatch(otpController.text.trim())) {
      next['otp'] = 'Enter the $otpLength-digit code';
    }

    final pass = passwordController.text;
    if (pass.length < 8) {
      next['password'] = 'Password must be at least 8 characters';
    } else if (!RegExp('[A-Za-z]').hasMatch(pass)) {
      next['password'] = 'Password must contain a letter';
    } else if (!RegExp(r'\d').hasMatch(pass)) {
      next['password'] = 'Password must contain a number';
    }

    if (confirmController.text.isEmpty) {
      next['confirm'] = 'Please confirm your password';
    } else if (confirmController.text != pass) {
      next['confirm'] = 'Passwords do not match';
    }

    errors.assignAll(next);
    return next.isEmpty;
  }

  Future<void> resetPassword() async {
    if (isResetting.value || !_validateReset()) return;

    isResetting.value = true;
    final ok = await _post(AuthApiEndpoint.resetPassword, {
      'email': email,
      'otp': otpController.text.trim(),
      'password': passwordController.text,
    }, 'Could not reset your password. Please try again.');
    isResetting.value = false;

    if (ok) step.value = ForgotStep.done;
  }

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
