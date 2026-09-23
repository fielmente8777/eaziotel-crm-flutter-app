import 'package:eazotel/core/api/apiexception/api_error_screen.dart';
import 'package:flutter/material.dart';

class ApiErrorHandler {
  ApiErrorHandler._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _isShowing = false;

  // Show exception screen
  static void handle(dynamic exception) {
    if (_isShowing) {
      return;
    }

    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      debugPrint('❌ Navigator is NULL');
      return;
    }

    _isShowing = true;

    debugPrint('🚨 Opening API Error Screen');

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ExceptionScreen(message: exception.toString()),
      ),
      (route) => false,
    );
  }

  // Reset error screen state
  static void reset() {
    _isShowing = false;
  }
}
