import 'package:eazotel/utils/res/t_responsive.dart';

/// Analytics-only sizes. Breakpoints come from the global TResponsive.
class AnalyticsLayout {
  final TResponsive r;

  const AnalyticsLayout(this.r);

  // ---------- Global ----------
  double get width => r.contentWidth;
  bool get isPhone => r.isPhone;
  bool get isTablet => r.isTablet;
  bool get isDesktop => r.isDesktop;
  double get pagePadding => r.pagePadding;
  double get gap => r.gap;
  double get radius => r.radius;

  // ---------- Common Text ----------
  double get bodyFont => r.value(phone: 11.0, tablet: 12.0, desktop: 13.0);

  // ---------- Tabs ----------
  double get tabHeight => r.value(phone: 70.0, tablet: 84.0, desktop: 92.0);

  double get tabValueSize => r.value(phone: 17.0, tablet: 20.0, desktop: 24.0);

  double get tabLabelSize => r.value(phone: 9.0, tablet: 10.5, desktop: 11.0);

  double get tabIconSize => r.value(phone: 12.0, tablet: 15.0, desktop: 16.0);

  int get tabColumns => r.value(phone: 2, tablet: 3, desktop: 6);

  // ---------- Chart ----------
  double get chartHeight =>
      r.value(phone: 200.0, tablet: 290.0, desktop: 360.0);

  double get totalSize => r.value(phone: 24.0, tablet: 28.0, desktop: 32.0);

  double get axisFont => r.value(phone: 9.5, tablet: 11.0, desktop: 12.0);

  double get yAxisReserved => r.value(phone: 34.0, tablet: 44.0, desktop: 48.0);

  double get xLabelSpacing => r.value(phone: 58.0, tablet: 84.0, desktop: 90.0);
}
