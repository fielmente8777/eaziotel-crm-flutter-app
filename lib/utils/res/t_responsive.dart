import 'dart:math' as math;

import 'package:eazotel/utils/res/t_breakpoints.dart';
 import 'package:flutter/material.dart';

enum TScreenSize { phone, tablet, desktop }

class TResponsive {
  /// The width this widget gets
  final double width;
  const TResponsive(this.width);

  /// The full screen width (from MediaQuery)
  factory TResponsive.of(BuildContext context) =>
      TResponsive(MediaQuery.sizeOf(context).width);

  TScreenSize get size => width < TBreakpoints.tablet
      ? TScreenSize.phone
      : width < TBreakpoints.desktop
          ? TScreenSize.tablet
          : TScreenSize.desktop;

  bool get isPhone => size == TScreenSize.phone;
  bool get isTablet => size == TScreenSize.tablet;
  bool get isDesktop => size == TScreenSize.desktop;

  /// Pick a value based on the screen.
  /// If tablet / desktop are not given, the previous size's value is used.
  T value<T>({required T phone, T? tablet, T? desktop}) {
    switch (size) {
      case TScreenSize.desktop:
        return desktop ?? tablet ?? phone;
      case TScreenSize.tablet:
        return tablet ?? phone;
      case TScreenSize.phone:
        return phone;
    }
  }

  // ---------- App-wide common values ----------
  double get pagePadding => value(phone: 12.0, tablet: 20.0, desktop: 24.0);
  double get gap => value(phone: 8.0, tablet: 12.0);
  double get radius => value(phone: 14.0, tablet: 18.0);

  /// Do not stretch content on big screens
  double get contentWidth => math.min(width, TBreakpoints.maxContentWidth);
}

/// Use it anywhere with context.responsive
extension TResponsiveContext on BuildContext {
  TResponsive get responsive => TResponsive.of(this);
}