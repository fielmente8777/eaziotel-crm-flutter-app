import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

import 'package:eazotel/features/splash_screen/screens/splash_screen.dart';


class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/LoginScreen': (context) => const LoginScreen(),
    // '/home': (context) => const HomeScreen(),
  };
}