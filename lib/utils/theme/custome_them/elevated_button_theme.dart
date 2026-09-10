


import 'package:flutter/material.dart';
import 'app_colors.dart';

class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static final lightElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: TAppColors.primary,
      foregroundColor: Colors.white,

      elevation: 2,

      minimumSize: const Size(double.infinity, 48),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),

      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final darkElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: TAppColors.primary,
      foregroundColor: Colors.white,

      elevation: 0,

      minimumSize: const Size(double.infinity, 48),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),

      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}