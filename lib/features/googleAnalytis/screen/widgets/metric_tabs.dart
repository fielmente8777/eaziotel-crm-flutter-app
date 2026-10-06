import 'package:eazotel/features/googleAnalytis/models/featuresModels/analytics_metric.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:flutter/material.dart';

class MetricTabs extends StatelessWidget {
  final List points;
  final AnalyticsMetric selected;
  final ValueChanged<AnalyticsMetric> onSelected;
  final AnalyticsLayout layout;

  const MetricTabs({
    super.key,
    required this.points,
    required this.selected,
    required this.onSelected,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    const metrics = AnalyticsMetric.values;

    // Phone: 2 columns, Tablet: 3, Desktop: 6
    final cols = layout.tabColumns;
    final avail = layout.width - layout.pagePadding * 2;
    final cardW = (avail - layout.gap * (cols - 1)) / cols;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.pagePadding),
      child: Wrap(
        spacing: layout.gap,
        runSpacing: layout.gap,
        children: [for (final m in metrics) _tab(context, m, cardW)],
      ),
    );
  }

  Widget _tab(BuildContext context, AnalyticsMetric metric, double width) {
    final c = AnalyticsPalette.of(context);
    final isSelected = metric == selected;
    final accent = c.accent(metric);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSelected(metric),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: width,
          height: layout.tabHeight,
          padding: EdgeInsets.all(layout.isPhone ? 10 : 14),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: c.isDark ? 0.14 : 0.08)
                : c.card,
            borderRadius: BorderRadius.circular(layout.radius),
            border: Border.all(
              color: isSelected ? accent : c.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(layout.isPhone ? 4 : 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      metric.icon,
                      size: layout.tabIconSize,
                      color: accent,
                    ),
                  ),
                  SizedBox(width: layout.isPhone ? 6 : 8),
                  Expanded(
                    child: Text(
                      metric.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.subText,
                        fontSize: layout.tabLabelSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  metric.format(metric.total(points)),
                  style: TextStyle(
                    color: isSelected ? accent : c.text,
                    fontSize: layout.tabValueSize,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
