// ============================================================
// WHATSAPP UI  (WhatsApp feature ke saare screen ek jaisa dikhein)
//
//   WaPalette               : card, border, text, chat wallpaper ke rang
//   WaAvatar                : naam ka pehla akshar, naam ke hisaab se rang
//   WaStatus                : conversation status ka rang
//   WaConversationShimmer   : chat list load ho rahi ho tab (gol loader nahi)
//   WaChatShimmer           : chat ke messages load ho rahe hon tab
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WaPalette {
  WaPalette(BuildContext context)
    : isDark = Theme.of(context).brightness == Brightness.dark;

  final bool isDark;

  /// WhatsApp ka hara rang (tab, badge, button)
  static const Color green = Color(0xFF00A884);
  static const Color greenDark = Color(0xFF008069);

  Color get accent => isDark ? const Color(0xFF25D366) : greenDark;

  Color get card => isDark ? TAppColors.darkCard : TAppColors.lightCard;
  Color get inner =>
      isDark ? TAppColors.darkBackground : TAppColors.lightBackground;
  Color get border => isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
  Color get text => isDark ? TAppColors.darkText : TAppColors.lightText;
  Color get subText =>
      isDark ? TAppColors.darkSecondaryText : TAppColors.lightSecondaryText;

  /// Chat ke peeche ka rang (WhatsApp jaisa)
  Color get wallpaper =>
      isDark ? const Color(0xFF0B141A) : const Color(0xFFEFEAE2);

  /// Halka rang wala background (chip / icon box)
  Color tint(Color c) => c.withValues(alpha: isDark ? .18 : .12);

  /// Rangeen background par us rang ka text: dark me thoda halka karo
  Color onTint(Color c) => isDark ? Color.lerp(c, Colors.white, .35)! : c;
}

/// Conversation ka status (active / inactive / converted ...)
class WaStatus {
  WaStatus._();

  static Color color(String status) {
    final s = status.toLowerCase();
    if (s.contains('convert')) return const Color(0xFF8B5CF6);
    if (s.contains('inactive') || s.contains('close')) {
      return const Color(0xFF64748B);
    }
    if (s.contains('active') || s.contains('open')) {
      return const Color(0xFF16A34A);
    }
    if (s.contains('hot')) return const Color(0xFFEF4444);
    return const Color(0xFF0EA5E9);
  }
}

class WaAvatar extends StatelessWidget {
  const WaAvatar({
    super.key,
    required this.name,
    this.size = 50,
    this.onBrand = false,
  });

  final String name;
  final double size;

  /// Hare / rangeen header par (halka safed background)
  final bool onBrand;

  static const _colors = [
    Color(0xFF00A884),
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
  ];

  static Color colorFor(String name) {
    if (name.isEmpty) return _colors.first;
    final hash = name.codeUnits.fold<int>(0, (s, c) => s + c);
    return _colors[hash % _colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final clean = name.trim();
    // Naam me akshar ho to pehla akshar, warna (sirf number) person icon
    final hasLetter =
        clean.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(clean[0]);
    final color = colorFor(clean);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onBrand ? Colors.white.withValues(alpha: .2) : null,
        gradient: onBrand
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: .72)],
              ),
      ),
      child: hasLetter
          ? Text(
              clean[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * .4,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(Icons.person_rounded, color: Colors.white, size: size * .5),
    );
  }
}

// ============================================================
// SHIMMER
// ============================================================

class _WaShimmer extends StatelessWidget {
  const _WaShimmer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: child,
    );
  }
}

Widget _box(
  BuildContext context, {
  double? width,
  required double height,
  double radius = 8,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: WaPalette(context).card,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Chat list loading. [withHeader] = true to search + tabs bhi (pehli baar)
class WaConversationShimmer extends StatelessWidget {
  const WaConversationShimmer({super.key, this.withHeader = false});

  final bool withHeader;

  @override
  Widget build(BuildContext context) {
    return _WaShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        children: [
          if (withHeader) ...[
            const SizedBox(height: 12),
            _box(context, width: 140, height: 24),
            const SizedBox(height: 18),
            _box(context, height: 48, radius: 14),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _box(context, height: 40, radius: 12)),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
          for (var i = 0; i < 7; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: WaPalette(context).card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: WaPalette(context).border,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FractionallySizedBox(
                            widthFactor: i.isEven ? .55 : .4,
                            child: _shade(context, 14),
                          ),
                          const SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: i.isEven ? .85 : .7,
                            child: _shade(context, 11),
                          ),
                          const SizedBox(height: 8),
                          _shade(context, 18, width: 70, radius: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shade(
    BuildContext context,
    double height, {
    double? width,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: WaPalette(context).border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Chat ke messages loading: left / right bubbles
class WaChatShimmer extends StatelessWidget {
  const WaChatShimmer({super.key});

  static const _bubbles = [
    (false, .62, 44.0),
    (true, .5, 38.0),
    (false, .45, 38.0),
    (true, .7, 58.0),
    (false, .55, 44.0),
    (true, .4, 38.0),
    (false, .68, 58.0),
    (true, .52, 44.0),
  ];

  @override
  Widget build(BuildContext context) {
    return _WaShimmer(
      child: ListView(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        children: [
          for (final (mine, width, height) in _bubbles)
            Align(
              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: width,
                child: Container(
                  height: height,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: WaPalette(context).card,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(mine ? 14 : 4),
                      bottomRight: Radius.circular(mine ? 4 : 14),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
