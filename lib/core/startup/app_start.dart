// ============================================================
// APP START
//
// App khulte hi kaunsi screen dikhe:
//   token saved hai -> Dashboard
//   warna           -> Login
//
// Isse pehle alag Flutter splash screen thi jo ek extra page aur
// navigation karti thi. Ab phone ka native splash (logo) tab tak
// dikhta hai jab tak ye check ho raha hai, phir seedhi sahi screen.
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

  /// Saari purani screens hata kar shuru wali screen kholo (jaise "Try Again")
  static Future<void> restart(BuildContext context) async {
    final screen = await firstScreen();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}
