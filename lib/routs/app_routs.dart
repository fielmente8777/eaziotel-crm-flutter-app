import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashbord_botum_nav.dart';
 import 'package:flutter/material.dart';

import 'package:eazotel/features/splash_screen/screens/splash_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/LoginScreen': (context) => const LoginScreen(),
    // '/DashboardScreen': (context) => const DashboardBottomNav(),
  };
}
