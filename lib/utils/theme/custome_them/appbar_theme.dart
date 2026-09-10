

import 'package:flutter/material.dart';
import 'app_colors.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: TAppColors.lightBackground,
    foregroundColor: TAppColors.lightText,
    surfaceTintColor: Colors.transparent,

    iconTheme: IconThemeData(
      color: TAppColors.lightText,
      size: 20,
    ),

    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TAppColors.lightText,
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: TAppColors.darkBackground,
    foregroundColor: TAppColors.darkText,
    surfaceTintColor: Colors.transparent,

    iconTheme: IconThemeData(
      color: TAppColors.darkText,
      size: 20,
    ),

    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TAppColors.darkText,
    ),
  );
}