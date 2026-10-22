// ============================================================
// SEO CHARTS  (fl_chart)
//
//   SeoRankChart : rank trend. For rank, lower = better, so
//                  the chart is upside down: #1 on top, #20 at the bottom.
//                  (inside we plot -rank, the label shows +rank)
// ============================================================

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';

class SeoRankPoint {
  const SeoRankPoint(this.label, this.rank);

  /// "10-05"
  final String label;
  final double rank;
}

class SeoRankChart extends StatelessWidget {
  const SeoRankChart({
    super.key,
    required this.points,
    required this.color,
    this.height = 220,
    this.compact = false,
    this.name = 'Avg Rank',
  });

  final List<SeoRankPoint> points;
  final Color color;
  final double height;

  /// Small chart (keyword detail): fewer labels
  final bool compact;
  final String name;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final axis = TextStyle(color: p.subText, fontSize: compact ? 9.5 : 10.5);
    final count = points.length;

    final ranks = points.map((e) => e.rank);
    final best = ranks.reduce(math.min);
    final worst = ranks.reduce(math.max);

    // A little space above and below (nothing above #1)
    final maxY = -math.max(0.5, best - 1.0);
    final minY = -(worst + 1);

    final step = math.max(1, (count / (compact ? 4 : 6)).ceil()).toDouble();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: p.border, strokeWidth: 1, dashArray: [4, 4]),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: compact ? 30 : 38,
                getTitlesWidget: (v, meta) {
                  // Whole numbers only
                  if (v != v.roundToDouble()) return const SizedBox.shrink();
                  return Text('#${(-v).round()}', style: axis);
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: step,
                reservedSize: 22,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (v != i.toDouble() || i < 0 || i >= count) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(points[i].label, style: axis),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${points[s.x.toInt()].label}\n'
                    '$name #${(-s.y).toStringAsFixed(1)}',
                    TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < count; i++)
                  FlSpot(i.toDouble(), -points[i].rank),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: color,
              barWidth: compact ? 2 : 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: count <= 2),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: .30),
                    color.withValues(alpha: 0),
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
