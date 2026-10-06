import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashbord_botum_nav.dart';
 import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  
  Future<void> startSplash(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    final hasToken = await TokenStorage.hasAccessToken();

    if (hasToken) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardBottomNav()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
