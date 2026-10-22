import 'package:eazotel/features/googleAnalytis/models/featuresModels/analytics_metric.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class AnalyticsPalette {
  final bool isDark;
  AnalyticsPalette._(this.isDark);

  factory AnalyticsPalette.of(BuildContext context) =>
      AnalyticsPalette._(Theme.of(context).brightness == Brightness.dark);

  Color get card => isDark ? TAppColors.darkCard : TAppColors.lightCard;
  Color get border => isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
  Color get text => isDark ? TAppColors.darkText : TAppColors.lightText;
  Color get subText => text.withValues(alpha: 0.6);
  Color get grid => border.withValues(alpha: isDark ? 0.7 : 1);
  Color get tooltipBg => isDark ? const Color(0xFF2A2D36) : const Color(0xFF1F2937);




  /// Color by channel name (the colors from the screenshot)
Color channelColorFor(String name) {
  switch (name.toLowerCase()) {
    case 'direct':
      return isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
    case 'organic search':
      return isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
    case 'organic social':
      return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
    case 'paid search':
      return isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
    case 'referral':
      return isDark ? const Color(0xFF8B5CF6) : const Color(0xFF7C3AED);
    case 'ai assistant':
      return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    case 'cross-network':
      return isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    case 'paid other':
      return isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    case 'unassigned':
      return isDark ? const Color(0xFFB4B4BB) : const Color(0xFF8A8A93);
    default:
      return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  }
}

  /// Each metric's own attractive color
  Color accent(AnalyticsMetric m) {
    switch (m) {
      case AnalyticsMetric.activeUsers:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB); // blue
      case AnalyticsMetric.newUsers:
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED); // purple
      case AnalyticsMetric.sessions:
        return isDark ? const Color(0xFF34D399) : const Color(0xFF059669); // green
      case AnalyticsMetric.pageViews:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706); // amber
      case AnalyticsMetric.events:
        return isDark ? const Color(0xFFF472B6) : const Color(0xFFDB2777); // pink
      case AnalyticsMetric.avgDuration:
        return isDark ? const Color(0xFF22D3EE) : const Color(0xFF0891B2); // cyan
    }
  }
}