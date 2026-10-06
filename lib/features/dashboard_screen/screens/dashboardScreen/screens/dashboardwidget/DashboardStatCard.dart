import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

/// Clean stat card:
///  ┌──────────────────────────┐
///  │ Total Leads          (●) │  title + icon
///  │ 62                       │  big value
///  │ [ Top source · Webform ] │  pill  (ya progress bar)
///  └──────────────────────────┘
class DashboardStatCard extends StatefulWidget {
  final String value;
  final String title;
  final String bottomText;
  final IconData icon;

  final Color accentColor;
  final Color iconColor;
  final Color? valueColor;

  /// 0..1 — diya ho to pill ki jagah progress bar
  final double? progress;

  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.value,
    required this.title,
    required this.bottomText,
    required this.icon,
    required this.accentColor,
    required this.iconColor,
    this.valueColor,
    this.progress,
    this.onTap,
  });

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Obx(() {
      if (dashboardController.isAnalyticsLoading.value) {
        return _shimmerCard(context);
      }
      return _card(context);
    });
  }

  Widget _card(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = widget.accentColor;

    final cardColor =
        theme.cardTheme.color ??
        (isDark ? TAppColors.darkCard : TAppColors.lightCard);
    final borderColor = isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
    final subText = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;
    final valueColor =
        widget.valueColor ??
        theme.textTheme.titleLarge?.color ??
        (isDark ? Colors.white : Colors.black);

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hover ? accent.withValues(alpha: 0.5) : borderColor,
              ),
              boxShadow: [
                if (!isDark || _hover)
                  BoxShadow(
                    color: _hover
                        ? accent.withValues(alpha: isDark ? 0.15 : 0.12)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: _hover ? 16 : 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- TITLE + ICON ----------
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: subText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 17,
                        color: widget.iconColor,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ---------- VALUE ----------
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _CountUpText(
                    value: widget.value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      letterSpacing: -0.5,
                      color: valueColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ---------- FOOTER ----------
                widget.progress != null
                    ? _progressFooter(accent, subText)
                    : _pill(accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.bottomText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }

  Widget _progressFooter(Color accent, Color subText) {
    final p = widget.progress!.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: p),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 5,
              backgroundColor: accent.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.bottomText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: subText,
          ),
        ),
      ],
    );
  }

  Widget _shimmerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? TAppColors.darkCard : TAppColors.lightBorder,
      highlightColor: isDark ? TAppColors.darkBorder : TAppColors.lightCard,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(height: 11, width: 80, color: Colors.white),
                const Spacer(),
                Container(
                  height: 32,
                  width: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(height: 26, width: 60, color: Colors.white),
            const SizedBox(height: 12),
            Container(height: 18, width: 110, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// "62", "3.2%", "1,250" — number count-up
class _CountUpText extends StatelessWidget {
  final String value;
  final TextStyle style;

  const _CountUpText({required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    final m = RegExp(r'^([^\d-]*)(-?[\d,]*\.?\d+)(.*)$').firstMatch(value);
    final target = m == null
        ? null
        : double.tryParse(m.group(2)!.replaceAll(',', ''));
    if (m == null || target == null) {
      return Text(value, maxLines: 1, style: style);
    }

    final numStr = m.group(2)!.replaceAll(',', '');
    final decimals = numStr.contains('.') ? numStr.split('.').last.length : 0;

    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0, end: target),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(
        '${m.group(1)}${v.toStringAsFixed(decimals)}${m.group(3)}',
        maxLines: 1,
        style: style,
      ),
    );
  }
}
