import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/LoginScreen': (context) => const LoginScreen(),
    // '/DashboardScreen': (context) => const DashboardBottomNav(),
  };
}
