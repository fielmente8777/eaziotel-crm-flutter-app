// ============================================================
// ADS COMMON
//
// Google Ads screen ke chhote widget + formatter:
//   AdsFormat  : ₹1,234.50 / 12.3K / 4.56%
//   AdsPanel   : title + subtitle wala dabba
//   KpiCard    : bada number + pichhle range se badlav %
//   MiniStat   : chhota number
//   EmptyMini  : "data nahi" ka dabba
//   AdsShimmer : loading ke time bhoore dabbe
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';

class AdsFormat {
  AdsFormat._();

  static final NumberFormat _number = NumberFormat.decimalPattern('en_IN');
  static final NumberFormat _compact = NumberFormat.compact(locale: 'en_IN');

  static String number(double v) => _number.format(v.round());
  static String compact(double v) => _compact.format(v);
  static String money(double v) =>
      '₹${NumberFormat('#,##,##0.00', 'en_IN').format(v)}';
  static String moneyCompact(double v) => '₹${_compact.format(v)}';

  /// 0.0456 -> "4.56%"
  static String percent(double v) => '${(v * 100).toStringAsFixed(2)}%';

  static String decimal(double v) => v.toStringAsFixed(2);
}

class AdsPanel extends StatelessWidget {
  const AdsPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.badge,
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(color: p.subText, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TAppColors.success.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: TAppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.change,
    this.hint,
    this.lowerIsBetter = false,
  });

  final String label;
  final String value;
  final Color color;

  /// 0.12 = +12% (null = mat dikhao)
  final double? change;
  final String? hint;

  /// Cost jaisa: kam hona achha hai (hara)
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final delta = change;
    final good = delta == null
        ? true
        : (lowerIsBetter ? delta <= 0 : delta >= 0);

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: p.subText,
                        fontSize: 10.5,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (delta != null)
                      Row(
                        children: [
                          Icon(
                            delta >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 12,
                            color: good ? TAppColors.success : TAppColors.error,
                          ),
                          Text(
                            '${(delta.abs() * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: good
                                  ? TAppColors.success
                                  : TAppColors.error,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else if (hint != null)
                      Text(
                        hint!,
                        style: TextStyle(color: p.subText, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: p.subText, fontSize: 11.5)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color ?? p.text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyMini extends StatelessWidget {
  const EmptyMini({super.key, required this.text, this.height = 150});

  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: p.subText, fontSize: 12.5),
      ),
    );
  }
}

/// Grid me barabar chaudai ke dabbe (phone 2, tablet 3, window [wide])
class AdsGrid extends StatelessWidget {
  const AdsGrid({
    super.key,
    required this.columns,
    required this.children,
    this.gap = 10,
  });

  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = (box.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class AdsShimmer extends StatelessWidget {
  const AdsShimmer({super.key, required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget block(double h) => Container(
      height: h,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: Column(
        children: [
          AdsGrid(
            columns: columns,
            children: List.generate(6, (_) => block(90)),
          ),
          const SizedBox(height: 12),
          block(260),
          const SizedBox(height: 12),
          block(220),
        ],
      ),
    );
  }
}
