import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'selected_theme';

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);

    ThemeMode mode;

    switch (savedTheme) {
      case 'light':
        mode = ThemeMode.light;
        break;

      case 'dark':
        mode = ThemeMode.dark;
        break;

      case 'system':
      default:
        mode = ThemeMode.system;
        break;
    }

    themeMode.value = mode;

    // Apply saved theme
    Get.changeThemeMode(mode);
  }

  Future<void> changeTheme(ThemeMode mode) async {
    themeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();

    String themeValue;

    switch (mode) {
      case ThemeMode.light:
        themeValue = 'light';
        break;

      case ThemeMode.dark:
        themeValue = 'dark';
        break;

      case ThemeMode.system:
        themeValue = 'system';
        break;
    }

    await prefs.setString(_themeKey, themeValue);

    Get.changeThemeMode(mode);
  }

  bool get isSystem => themeMode.value == ThemeMode.system;

  bool get isLight => themeMode.value == ThemeMode.light;

  bool get isDark => themeMode.value == ThemeMode.dark;
}