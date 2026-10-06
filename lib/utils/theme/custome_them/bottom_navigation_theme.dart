import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class TBottomNavigationTheme {
  TBottomNavigationTheme._();

  // =====================================================
  // LIGHT BOTTOM NAVIGATION
  // Selected: primary | Unselected: black
  // =====================================================

  static const BottomNavigationBarThemeData lightBottomNavigationTheme =
      BottomNavigationBarThemeData(
        backgroundColor: TAppColors.lightBackground,

        selectedItemColor: TAppColors.primary,

        unselectedItemColor: Colors.black,

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

        selectedIconTheme: IconThemeData(size: 26, color: TAppColors.primary),

        unselectedIconTheme: IconThemeData(size: 26, color: Colors.black),

        type: BottomNavigationBarType.fixed,

        elevation: 0,

        showSelectedLabels: true,

        showUnselectedLabels: true,
      );

  // =====================================================
  // DARK BOTTOM NAVIGATION
  // Selected: primary | Unselected: white
  // =====================================================

  static const BottomNavigationBarThemeData darkBottomNavigationTheme =
      BottomNavigationBarThemeData(
        backgroundColor: TAppColors.darkBackground,

        selectedItemColor: TAppColors.primary,

        unselectedItemColor: Colors.white,

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

        selectedIconTheme: IconThemeData(size: 26, color: TAppColors.primary),

        unselectedIconTheme: IconThemeData(size: 26, color: Colors.white),

        type: BottomNavigationBarType.fixed,

        elevation: 0,

        showSelectedLabels: true,

        showUnselectedLabels: true,
      );
}
