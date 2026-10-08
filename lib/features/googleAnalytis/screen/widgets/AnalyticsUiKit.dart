// lib/features/googleAnalytis/screen/widgets/analytics_ui_kit.dart
//
// Geo + Audience cards ke shared pieces.

import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const kSeriesColors = [
  Color(0xFF6366F1), // indigo
  Color(0xFF06B6D4), // cyan
  Color(0xFFF59E0B), // amber
  Color(0xFFEF4444), // red
  Color(0xFF10B981), // green
  Color(0xFFEC4899), // pink
  Color(0xFF8B5CF6), // purple
  Color(0xFF84CC16), // lime
];

Color seriesColor(int i) => kSeriesColors[i % kSeriesColors.length];

Color darker(Color c, [double t = 0.22]) => Color.lerp(c, Colors.black, t)!;

const kUnknownColor = Color(0xFF6B7280);

Color deviceColor(String name, int i) {
  switch (name.toLowerCase()) {
    case 'desktop':
      return const Color(0xFF2F7BEB);
    case 'mobile':
      return const Color(0xFF10B981);
    case 'tablet':
      return const Color(0xFFF59E0B);
    case 'smart tv':
      return const Color(0xFF8B5CF6);
    default:
      return seriesColor(i);
  }
}

IconData deviceIcon(String name) {
  switch (name.toLowerCase()) {
    case 'desktop':
      return Icons.desktop_windows_outlined;
    case 'mobile':
      return Icons.smartphone_outlined;
    case 'tablet':
      return Icons.tablet_mac_outlined;
    case 'smart tv':
      return Icons.tv_outlined;
    default:
      return Icons.devices_other_outlined;
  }
}

/// Section ka bada heading + subtitle
class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final AnalyticsLayout layout;
  final List<Color> accent;

  const SectionHeading({
    super.key,
    required this.title,
    required this.layout,
    this.subtitle,
    this.accent = const [Color(0xFF3B82F6), Color(0xFFA855F7)],
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: subtitle == null ? 20 : 38,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: accent,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: c.text,
                  fontSize: layout.isPhone ? 17 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(color: c.subText, fontSize: layout.bodyFont),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Card shell: top gradient line + halka tint
class AnalyticsShell extends StatelessWidget {
  final String title;
  final Color accent;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final AnalyticsLayout layout;
  final bool colorTitle;

  const AnalyticsShell({
    super.key,
    required this.title,
    required this.accent,
    required this.child,
    required this.layout,
    this.icon,
    this.trailing,
    this.colorTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final pad = layout.isPhone ? 14.0 : 20.0;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.radius),
        border: Border.all(color: c.border),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.35],
          colors: [
            Color.alphaBlend(
              accent.withValues(alpha: c.isDark ? 0.07 : 0.04),
              c.card,
            ),
            c.card,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, pad - 3, pad, pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 15, color: accent),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: colorTitle ? accent : c.text,
                          fontSize: layout.isPhone ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                SizedBox(height: layout.isPhone ? 14 : 18),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Count-up percent
class AnimatedPercentText extends StatelessWidget {
  final double percent;
  final TextStyle style;
  final Duration duration;

  const AnimatedPercentText(
    this.percent, {
    super.key,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text('${v.toStringAsFixed(1)}%', style: style),
    );
  }
}

/// 0 se fill hone wala gradient bar, active par glow
class GlowBar extends StatelessWidget {
  final double ratio; // 0..1
  final Color color;
  final bool active;
  final double height;
  final int index; // stagger ke liye

  const GlowBar({
    super.key,
    required this.ratio,
    required this.color,
    this.active = false,
    this.height = 8,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
      duration: Duration(milliseconds: 700 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: active ? height + 2 : height,
        decoration: BoxDecoration(
          color: c.text.withValues(alpha: c.isDark ? 0.07 : 0.06),
          borderRadius: BorderRadius.circular(height),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          heightFactor: 1,
          child: Container(
            constraints: const BoxConstraints(minWidth: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [darker(color, 0.15), color]),
              borderRadius: BorderRadius.circular(height),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Card ke andar loading: shimmer rows (label + value + bar)
Widget analyticsLoader({int rows = 4}) => AnalyticsShimmer(rows: rows);

/// Shimmer placeholder. [blockHeight] do to rows ki jagah ek bada block
/// (chart ke liye) banta hai.
class AnalyticsShimmer extends StatelessWidget {
  final int rows;
  final double? blockHeight;

  const AnalyticsShimmer({super.key, this.rows = 4, this.blockHeight});

  static const _labelWidths = [120.0, 90.0, 140.0, 100.0, 110.0];

  Widget _bar({double? width, double height = 10, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);

    return Shimmer.fromColors(
      baseColor: c.border,
      highlightColor: Color.lerp(c.border, Colors.white, c.isDark ? 0.12 : 0.7)!,
      child: blockHeight != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 120, height: 12),
                const SizedBox(height: 14),
                _bar(width: double.infinity, height: blockHeight!, radius: 10),
              ],
            )
          : Column(
              children: [
                for (int i = 0; i < rows; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == rows - 1 ? 0 : 18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _bar(width: _labelWidths[i % _labelWidths.length]),
                            const Spacer(),
                            _bar(width: 44),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _bar(width: double.infinity, height: 8),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Poora card shimmer (metric tabs / line chart ki jagah)
class AnalyticsShimmerCard extends StatelessWidget {
  final double height;
  final AnalyticsLayout layout;

  const AnalyticsShimmerCard({
    super.key,
    required this.height,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isPhone ? 14 : 20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(layout.radius),
        border: Border.all(color: c.border),
      ),
      child: AnalyticsShimmer(blockHeight: height),
    );
  }
}

Widget analyticsEmpty(AnalyticsPalette c, [String msg = 'No data']) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Text(msg, style: TextStyle(color: c.subText))),
    );

/// Hover/tap state wala mixin — har card me same logic
mixin HoverSelect<T extends StatefulWidget, K> on State<T> {
  K? selectedKey;
  K? hoverKey;
  K? get activeKey => hoverKey ?? selectedKey;

  void setHover(K? k) {
    if (hoverKey == k) return;
    setState(() => hoverKey = k);
  }

  void toggleSelect(K k) =>
      setState(() => selectedKey = selectedKey == k ? null : k);

  void resetHoverSelect() {
    selectedKey = null;
    hoverKey = null;
  }
}