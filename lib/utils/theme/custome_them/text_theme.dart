import 'package:flutter/material.dart';
import 'app_colors.dart';

class TTextTheme {
  TTextTheme._();

  // ================= LIGHT =================

  static const lightTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: TAppColors.lightText,
    ),

    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: TAppColors.lightText,
    ),

    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: TAppColors.lightText,
    ),

    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TAppColors.lightText,
    ),

    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TAppColors.lightText,
    ),

    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: TAppColors.lightText,
    ),

    bodyLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: TAppColors.lightText,
    ),

    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: TAppColors.lightText,
    ),

    bodySmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: TAppColors.lightSecondaryText,
    ),

    labelLarge: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: TAppColors.lightText,
    ),

    labelMedium: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: TAppColors.lightSecondaryText,
    ),
  );

  // ================= DARK =================

  static const darkTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: TAppColors.darkText,
    ),

    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: TAppColors.darkText,
    ),

    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: TAppColors.darkText,
    ),

    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TAppColors.darkText,
    ),

    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TAppColors.darkText,
    ),

    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: TAppColors.darkText,
    ),

    bodyLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: TAppColors.darkText,
    ),

    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: TAppColors.darkText,
    ),

    bodySmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: TAppColors.darkSecondaryText,
    ),

    labelLarge: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: TAppColors.darkText,
    ),

    labelMedium: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: TAppColors.darkSecondaryText,
    ),
  );
}