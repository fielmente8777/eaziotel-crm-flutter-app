// ============================================================
// LEADS STYLE  (Leads feature ke saare screen ek jaisa dikhein)
//
//   LeadsPalette   : card, border, text ke rang (light / dark)
//   LeadsStyle     : source / stage ka rang + icon, avatar ka rang
//   LeadsShimmer   : loading ke time card jaise bhoore dabbe
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LeadsPalette {
  LeadsPalette(BuildContext context)
    : isDark = Theme.of(context).brightness == Brightness.dark;

  final bool isDark;

  Color get card => isDark ? TAppColors.darkCard : TAppColors.lightCard;
  Color get inner =>
      isDark ? TAppColors.darkBackground : TAppColors.lightBackground;
  Color get border => isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
  Color get text => isDark ? TAppColors.darkText : TAppColors.lightText;
  Color get subText =>
      isDark ? TAppColors.darkSecondaryText : TAppColors.lightSecondaryText;

  /// Dark me thoda chamakdar indigo (bottom nav jaisa), light me brand primary
  Color get primary => isDark ? const Color(0xFF6366F1) : TAppColors.primary;

  /// Primary rang ka text / icon (dark me lavender taaki saaf padha jaye)
  Color get accent => isDark ? const Color(0xFFA5B4FC) : TAppColors.primary;

  /// Brand gradient (chuna hua tab, filter button)
  List<Color> get brandGradient => isDark
      ? const [Color(0xFF6366F1), Color(0xFF8B5CF6)]
      : const [Color(0xFF4F46E5), Color(0xFF7C3AED)];

  /// Halka rang wala background (chip / icon box)
  Color tint(Color c) => c.withValues(alpha: isDark ? .18 : .10);

  /// Chip ki halki border
  Color tintBorder(Color c) => c.withValues(alpha: isDark ? .40 : .25);

  /// Rangeen background par us rang ka text: dark me thoda halka karo
  Color onTint(Color c) => isDark ? Color.lerp(c, Colors.white, .35)! : c;
}

class LeadsStyle {
  LeadsStyle._();

  /// Lead kahan se aaya (eazbot, webform ...)
  static ({Color color, IconData icon}) source(String source) {
    switch (source.toLowerCase()) {
      case 'eazbot':
        return (color: const Color(0xFF6366F1), icon: Icons.smart_toy_outlined);
      case 'webform':
        return (color: const Color(0xFF0EA5E9), icon: Icons.web_outlined);
      case 'whatsapp':
        return (color: const Color(0xFF22C55E), icon: Icons.chat_outlined);
      case 'facebook':
      case 'meta':
        return (color: const Color(0xFF1877F2), icon: Icons.facebook);
      case 'google':
        return (
          color: const Color(0xFFEA4335),
          icon: Icons.g_mobiledata_rounded,
        );
      case 'visitors':
        return (
          color: const Color(0xFFF59E0B),
          icon: Icons.person_pin_circle_outlined,
        );
      default:
        return (color: const Color(0xFF64748B), icon: Icons.public);
    }
  }

  /// Lead ka stage / status
  static Color stage(String stage) {
    final s = stage.toLowerCase();
    if (s.contains('convert')) return const Color(0xFF16A34A);
    if (s.contains('hot')) return const Color(0xFFEF4444);
    if (s.contains('contact')) return const Color(0xFF0EA5E9);
    if (s.contains('quotation')) return const Color(0xFF8B5CF6);
    if (s.contains('budget')) return const Color(0xFF64748B);
    if (s.contains('later')) return const Color(0xFFF59E0B);
    if (s.contains('open')) return const Color(0xFF6366F1);
    return const Color(0xFF64748B);
  }

  /// Har tab ka apna rang: All | Contact | Converted | Hot
  static const tabColors = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF16A34A),
    Color(0xFFEF4444),
  ];

  static const _avatarColors = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
  ];

  /// Naam ke hisaab se hamesha ek hi rang
  static Color avatar(String name) {
    if (name.isEmpty) return _avatarColors.first;
    final hash = name.codeUnits.fold<int>(0, (s, c) => s + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  static String capitalize(String v) =>
      v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);
}

/// Loading: card jaise bhoore dabbe (gol ghoomne wala loader nahi)
class LeadsShimmer extends StatelessWidget {
  const LeadsShimmer({super.key, this.count = 6, this.padding});

  final int count;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final p = LeadsPalette(context);

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: count,
        itemBuilder: (_, _) => Container(
          height: 96,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
