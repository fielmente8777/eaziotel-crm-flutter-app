import 'package:flutter/material.dart';
import 'app_colors.dart';

class TBottomSheetTheme {
  TBottomSheetTheme._();

  static const lightBottomSheetTheme =
      BottomSheetThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: Colors.white,
    showDragHandle: true,
  );

  static const darkBottomSheetTheme =
      BottomSheetThemeData(
    backgroundColor: TAppColors.darkCard,
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: TAppColors.darkCard,
    showDragHandle: true,
  );
}