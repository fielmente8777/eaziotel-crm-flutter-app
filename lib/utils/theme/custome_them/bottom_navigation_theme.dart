import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class TBottomNavigationTheme {
  TBottomNavigationTheme._();

  // =====================================================
  // LIGHT BOTTOM NAVIGATION
  // =====================================================

  static const BottomNavigationBarThemeData lightBottomNavigationTheme =
      BottomNavigationBarThemeData(
        backgroundColor: TAppColors.lightBackground,

        selectedItemColor: TAppColors.primary,

        unselectedItemColor: TAppColors.lightText,

        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        selectedIconTheme: IconThemeData(size: 26),

        unselectedIconTheme: IconThemeData(size: 26),
        type: BottomNavigationBarType.fixed,

        elevation: 0,

        showSelectedLabels: true,

        showUnselectedLabels: true,
      );

  // =====================================================
  // DARK BOTTOM NAVIGATION
  // =====================================================

  static const BottomNavigationBarThemeData darkBottomNavigationTheme =
      BottomNavigationBarThemeData(
        backgroundColor: TAppColors.darkBackground,

        selectedItemColor: TAppColors.primary,

        unselectedItemColor: TAppColors.darkText,

        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        selectedIconTheme: IconThemeData(size: 26),

        unselectedIconTheme: IconThemeData(size: 26),

        type: BottomNavigationBarType.fixed,

        elevation: 0,

        showSelectedLabels: true,

        showUnselectedLabels: true,
      );
}
