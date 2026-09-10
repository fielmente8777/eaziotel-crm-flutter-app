

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:eazotel/utils/theme/custome_them/appbar_theme.dart';
import 'package:eazotel/utils/theme/custome_them/bottom_sheet_theme.dart';
import 'package:eazotel/utils/theme/custome_them/elevated_button_theme.dart';
import 'package:eazotel/utils/theme/custome_them/input_decoration.dart';
import 'package:eazotel/utils/theme/custome_them/text_theme.dart';
import 'package:flutter/material.dart';

class TAppTheme {
  TAppTheme._();

  // =====================================================
  // LIGHT THEME
  // =====================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.light,

    fontFamily: 'Poppins',

    colorScheme: ColorScheme.fromSeed(
      seedColor: TAppColors.primary,
      brightness: Brightness.light,
    ),

    primaryColor: TAppColors.primary,

    scaffoldBackgroundColor: TAppColors.lightBackground,

    textTheme: TTextTheme.lightTextTheme,

    appBarTheme:
        TAppBarTheme.lightAppBarTheme,

    elevatedButtonTheme:
        TElevatedButtonTheme.lightElevatedButtonTheme,

    inputDecorationTheme:
        TInputDecorationTheme
            .lightInputDecorationTheme,

    bottomSheetTheme:
        TBottomSheetTheme.lightBottomSheetTheme,
    cardTheme: CardThemeData(
      color: TAppColors.lightCard,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
    ),

    dividerTheme: const DividerThemeData(
      color: TAppColors.lightBorder,
      thickness: 1,
    ),

    iconTheme: const IconThemeData(color: TAppColors.lightText),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: TAppColors.primary,
      foregroundColor: Colors.white,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: TAppColors.primary,
      labelStyle: const TextStyle(fontSize: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );

  // =====================================================
  // DARK THEME
  // =====================================================

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    fontFamily: 'Poppins',

    colorScheme: ColorScheme.fromSeed(
      seedColor: TAppColors.primary,
      brightness: Brightness.dark,
    ),

    primaryColor: TAppColors.primary,

    // IMPORTANT
    scaffoldBackgroundColor: TAppColors.darkBackground,

    textTheme: TTextTheme.darkTextTheme,

    appBarTheme: TAppBarTheme.darkAppBarTheme,

    elevatedButtonTheme:
        TElevatedButtonTheme.darkElevatedButtonTheme,

    inputDecorationTheme:
        TInputDecorationTheme
            .darkInputDecorationTheme,

    bottomSheetTheme:
        TBottomSheetTheme.darkBottomSheetTheme,
    cardTheme: CardThemeData(
      color: TAppColors.darkCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
    ),

    dividerTheme: const DividerThemeData(
      color: TAppColors.darkBorder,
      thickness: 1,
    ),

    iconTheme: const IconThemeData(color: TAppColors.darkText),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: TAppColors.primary,
      foregroundColor: Colors.white,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: TAppColors.darkCard,
      selectedColor: TAppColors.primary,
      labelStyle: const TextStyle(fontSize: 11, color: TAppColors.darkText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}
