import 'dart:math' as math;

import 'package:eazotel/features/googleAnalytis/controller/analytisController.dart';
import 'package:eazotel/features/googleAnalytis/models/featuresModels/analytics_metric.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
 import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AnalyticsLineChart extends StatelessWidget {
  const AnalyticsLineChart({super.key});

  DateTime _dateOf(dynamic p) {
    return p.date is DateTime ? p.date : DateTime.parse(p.date.toString());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalytisController>();

    return TResponsiveBuilder(
      builder: (context, r) {
        final layout = AnalyticsLayout(r);

        return Obx(() {
          final points = controller.analyticsData.value?.chartData ?? [];

          final metric = controller.selectedMetric.value;

          final rangeLabel = controller.selectedRange.value.label;

          final c = AnalyticsPalette.of(context);

          final accent = c.accent(metric);

          final pad = layout.isPhone ? 14.0 : 20.0;

          return Container(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, pad - 4),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(layout.radius + 4),
              border: Border.all(color: c.border),
              boxShadow: c.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // HEADER
                // ------------------------------------------------
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        metric.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.subText,
                          fontSize: layout.isPhone ? 11 : 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rangeLabel,
                        style: TextStyle(
                          color: accent,
                          fontSize: layout.isPhone ? 10.5 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: layout.isPhone ? 4 : 8),

                // ------------------------------------------------
                // TOTAL
                // ------------------------------------------------
                Text(
                  metric.format(metric.total(points)),
                  style: TextStyle(
                    color: c.text,
                    fontSize: layout.totalSize,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),

                SizedBox(height: layout.isPhone ? 14 : 22),

                // ------------------------------------------------
                // CHART
                // ------------------------------------------------
                SizedBox(
                  height: layout.chartHeight,
                  child: points.isEmpty
                      ? Center(
                          child: Text(
                            'No data',
                            style: TextStyle(color: c.subText),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, box) {
                            return _buildChart(
                              c: c,
                              accent: accent,
                              chartWidth: box.maxWidth,
                              points: points,
                              metric: metric,
                              layout: layout,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildChart({
    required AnalyticsPalette c,
    required Color accent,
    required double chartWidth,
    required List points,
    required AnalyticsMetric metric,
    required AnalyticsLayout layout,
  }) {
    // ------------------------------------------------------------
    // SPOTS
    // ------------------------------------------------------------

    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), metric.valueOf(points[i])),
    ];

    // ------------------------------------------------------------
    // MAX VALUE
    // ------------------------------------------------------------

    final maxValue = spots.map((s) => s.y).reduce(math.max);

    final maxY = _niceMax(maxValue);

    final yInterval = maxY / 4;

    // ------------------------------------------------------------
    // X LABEL CALCULATION
    // ------------------------------------------------------------

    final maxLabels =
        ((chartWidth - layout.yAxisReserved) / layout.xLabelSpacing)
            .floor()
            .clamp(2, 14);

    final xInterval = (points.length / maxLabels)
        .ceil()
        .clamp(1, 1000)
        .toDouble();

    final single = points.length == 1;

    final axisStyle = TextStyle(color: c.subText, fontSize: layout.axisFont);

    // ------------------------------------------------------------
    // LINE CHART
    // ------------------------------------------------------------

    return LineChart(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,

      LineChartData(
        minX: 0,

        maxX: math.max(1, points.length - 1).toDouble(),

        minY: 0,

        maxY: maxY,

        // --------------------------------------------------------
        // BORDER
        // --------------------------------------------------------
        borderData: FlBorderData(show: false),

        // --------------------------------------------------------
        // GRID
        // --------------------------------------------------------
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) {
            return FlLine(color: c.grid, strokeWidth: 1, dashArray: [4, 4]);
          },
        ),

        // --------------------------------------------------------
        // TITLES
        // --------------------------------------------------------
        titlesData: FlTitlesData(
          // TOP
          topTitles: const AxisTitles(),

          // RIGHT
          rightTitles: const AxisTitles(),

          // ------------------------------------------------------
          // LEFT
          // ------------------------------------------------------
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: layout.yAxisReserved,
              interval: yInterval,

              getTitlesWidget: (value, meta) {
                return Text(metric.format(value), style: axisStyle);
              },
            ),
          ),

          // ------------------------------------------------------
          // BOTTOM
          // ------------------------------------------------------
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: xInterval,

              getTitlesWidget: (value, meta) {
                final i = value.toInt();

                if (i < 0 || i >= points.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM d').format(_dateOf(points[i])),
                    style: axisStyle,
                  ),
                );
              },
            ),
          ),
        ),

        // --------------------------------------------------------
        // TOUCH
        // --------------------------------------------------------
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,

          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => c.tooltipBg,

            fitInsideHorizontally: true,

            fitInsideVertically: true,

            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            getTooltipItems: (touched) {
              return touched.map((s) {
                final index = s.x.toInt();

                final date = DateFormat(
                  'EEE, MMM d',
                ).format(_dateOf(points[index]));

                return LineTooltipItem(
                  '$date\n',

                  const TextStyle(color: Colors.white70, fontSize: 11),

                  children: [
                    TextSpan(
                      text: metric.format(s.y),

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.isPhone ? 14 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),

          // ------------------------------------------------------
          // TOUCHED SPOT
          // ------------------------------------------------------
          getTouchedSpotIndicator: (barData, indexes) {
            return indexes
                .map(
                  (_) => TouchedSpotIndicatorData(
                    FlLine(
                      color: accent.withValues(alpha: 0.5),
                      strokeWidth: 1.5,
                      dashArray: [4, 4],
                    ),

                    FlDotData(
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: layout.isPhone ? 5 : 6,
                          color: accent,
                          strokeWidth: 3,
                          strokeColor: c.card,
                        );
                      },
                    ),
                  ),
                )
                .toList();
          },
        ),

        // --------------------------------------------------------
        // LINE
        // --------------------------------------------------------
        lineBarsData: [
          LineChartBarData(
            spots: spots,

            isCurved: true,

            curveSmoothness: 0.28,

            preventCurveOverShooting: true,

            color: accent,

            barWidth: layout.isPhone ? 2.5 : 3,

            isStrokeCapRound: true,

            dotData: FlDotData(show: single),

            // ----------------------------------------------------
            // AREA
            // ----------------------------------------------------
            belowBarData: BarAreaData(
              show: true,

              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: [
                  accent.withValues(alpha: c.isDark ? 0.30 : 0.22),

                  accent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  // NICE MAX
  // --------------------------------------------------------------

  double _niceMax(double value) {
    if (value <= 0) {
      return 4;
    }

    final padded = value * 1.15;

    final magnitude = math.pow(10, padded.floor().toString().length - 1);

    final step = magnitude / 2;

    return ((padded / step).ceil() * step).toDouble();
  }
}
