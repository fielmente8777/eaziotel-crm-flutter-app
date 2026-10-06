import 'dart:math' as math;

import 'package:eazotel/utils/res/t_breakpoints.dart';
 import 'package:flutter/material.dart';

enum TScreenSize { phone, tablet, desktop }

class TResponsive {
  /// Is widget ko milne wali width
  final double width;
  const TResponsive(this.width);

  /// Poori screen ki width (MediaQuery se)
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

  /// Screen ke hisaab se value choose karo.
  /// tablet / desktop na do to pichli size ki value use hoti hai.
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

  /// Bade screen par content stretch na ho
  double get contentWidth => math.min(width, TBreakpoints.maxContentWidth);
}

/// context.responsive se kahin bhi use karein
extension TResponsiveContext on BuildContext {
  TResponsive get responsive => TResponsive.of(this);
}