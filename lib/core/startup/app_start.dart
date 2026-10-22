// ============================================================
// APP START
//
// Which screen shows when the app opens:
//   token saved -> Dashboard
//   otherwise   -> Login
//
// Before this there was a separate Flutter splash screen that added an
// extra page and navigation. Now the phone's native splash (logo) stays
// while this check runs, then the right screen opens directly.
// ============================================================

import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashbord_botum_nav.dart';
import 'package:flutter/material.dart';

class AppStart {
  AppStart._();

  static Future<Widget> firstScreen() async {
    final hasToken = await TokenStorage.hasAccessToken();

    return hasToken ? const DashboardBottomNav() : const LoginScreen();
  }

  /// Remove all old screens and open the start screen (like "Try Again")
  static Future<void> restart(BuildContext context) async {
    final screen = await firstScreen();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}
