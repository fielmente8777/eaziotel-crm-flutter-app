import 'package:flutter/material.dart';
import 'app_colors.dart';

class TInputDecorationTheme {
  TInputDecorationTheme._();

  // ================= LIGHT =================

  static final lightInputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 13,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
        color: TAppColors.lightBorder,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
        color: TAppColors.lightBorder,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
        color: TAppColors.primary,
        width: 1.3,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
        color: TAppColors.error,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
        color: TAppColors.error,
      ),
    ),

    hintStyle: const TextStyle(
      color: TAppColors.lightSecondaryText,
      fontSize: 12,
    ),

    labelStyle: const TextStyle(
      color: TAppColors.lightSecondaryText,
      fontSize: 12,
    ),
  );

  // ================= DARK =================

  static final darkInputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: TAppColors.darkCard,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 13,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
        color: TAppColors.darkBorder,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
        color: TAppColors.darkBorder,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
        color: TAppColors.primary,
        width: 1.3,
      ),
    ),

    hintStyle: const TextStyle(
      color: TAppColors.darkSecondaryText,
      fontSize: 12,
    ),

    labelStyle: const TextStyle(
      color: TAppColors.darkSecondaryText,
      fontSize: 12,
    ),
  );
}