// ============================================================
// ADS CHARTS  (fl_chart)
//
//   TwoLineChart        : do line (Clicks + Conversions, Cost + Conv. Value)
//   FunnelBars          : Impressions -> Clicks -> Conversions
//   DeviceDonut         : device ke hisaab se clicks
//   ImpressionShareRing : Search Impression Share ka gol meter
// ============================================================

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../models/google_ads_device_response.dart';
import 'ads_common.dart';

class ChartLine {
  const ChartLine({
    required this.name,
    required this.color,
    required this.values,
  });

  final String name;
  final Color color;
  final List<double> values;
}

class TwoLineChart extends StatelessWidget {
  const TwoLineChart({
    super.key,
    required this.labels,
    required this.lines,
    this.money = false,
    this.filled = false,
  });

  /// Neeche ki taareekh ("10-05")
  final List<String> labels;
  final List<ChartLine> lines;
  final bool money;

  /// Line ke neeche halka rang (Engagement Trend jaisa)
  final bool filled;

  String _fmt(double v) =>
      money ? AdsFormat.moneyCompact(v) : AdsFormat.compact(v);

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final axis = TextStyle(color: p.subText, fontSize: 10.5);
    final count = labels.length;

    // Neeche ~6 taareekh, zyada nahi
    final step = math.max(1, (count / 6).ceil()).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: LineChart(
            LineChartData(
              minY: 0,
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
                    reservedSize: 44,
                    getTitlesWidget: (v, meta) => Text(_fmt(v), style: axis),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: step,
                    reservedSize: 24,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= count) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(labels[i], style: axis),
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
                        '${lines[s.barIndex].name}: '
                        '${money ? AdsFormat.money(s.y) : AdsFormat.number(s.y)}',
                        TextStyle(
                          color: lines[s.barIndex].color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                for (final line in lines)
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < line.values.length; i++)
                        FlSpot(i.toDouble(), line.values[i]),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: line.color,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: count == 1),
                    belowBarData: BarAreaData(
                      show: filled,
                      color: line.color.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Legend(items: [for (final l in lines) (l.name, l.color)]),
      ],
    );
  }
}

class FunnelBars extends StatelessWidget {
  const FunnelBars({super.key, required this.steps});

  /// (naam, ginti, rang)
  final List<(String, double, Color)> steps;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final top = steps.fold<double>(0, (m, s) => math.max(m, s.$2));

    return Column(
      children: [
        for (final (name, value, color) in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(color: p.subText, fontSize: 12),
                      ),
                    ),
                    Text(
                      AdsFormat.compact(value),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: top == 0 ? 0 : value / top,
                    minHeight: 10,
                    color: color,
                    backgroundColor: p.inner,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class DeviceDonut extends StatelessWidget {
  const DeviceDonut({super.key, required this.slices});

  final List<GoogleAdsDevice> slices;

  static const List<Color> palette = [
    Color(0xFF3B6FE0),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
  ];

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final total = slices.fold<double>(0, (s, d) => s + d.clicks);

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 52,
              sections: [
                for (var i = 0; i < slices.length; i++)
                  PieChartSectionData(
                    value: slices[i].clicks,
                    color: palette[i % palette.length],
                    radius: 28,
                    title: total == 0
                        ? ''
                        : '${(slices[i].clicks * 100 / total).round()}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Legend(
          items: [
            for (var i = 0; i < slices.length; i++)
              (
                '${slices[i].name} (${AdsFormat.compact(slices[i].clicks)})',
                palette[i % palette.length],
              ),
          ],
        ),
        Text('Clicks', style: TextStyle(color: p.subText, fontSize: 11)),
      ],
    );
  }
}

class ImpressionShareRing extends StatelessWidget {
  const ImpressionShareRing({
    super.key,
    required this.share,
    required this.approx,
  });

  /// 0..1
  final double share;
  final bool approx;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final value = share.clamp(0.0, 1.0);

    return SizedBox(
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: 62,
              sections: [
                PieChartSectionData(
                  value: value,
                  color: const Color(0xFF0891B2),
                  radius: 18,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 1 - value,
                  color: p.inner,
                  radius: 18,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AdsFormat.percent(share),
                style: TextStyle(
                  color: p.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                approx ? 'weighted avg (approx)' : 'of available impressions',
                style: TextStyle(color: p.subText, fontSize: 10.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});

  final List<(String, Color)> items;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Wrap(
      spacing: 14,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        for (final (name, color) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 5),
              Text(name, style: TextStyle(color: p.subText, fontSize: 11.5)),
            ],
          ),
      ],
    );
  }
}
