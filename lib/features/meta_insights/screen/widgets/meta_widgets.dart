// ============================================================
// META INSIGHTS WIDGETS
//
//   MetaFormat       : 12,345 / 12.3K
//   MetaStatCard     : bada number + ▲ 12% / ▼ 4%
//   MetaLineChart    : Reach / Engagements (roz ka)
//   MetaPostCard     : top post (photo, caption, reactions, comments,
//                      reach, engagement)
// ============================================================

import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../models/meta_overview_response.dart';

class MetaFormat {
  MetaFormat._();

  static final _number = NumberFormat.decimalPattern('en_IN');
  static final _compact = NumberFormat.compact(locale: 'en_IN');

  static String number(double v) => _number.format(v.round());
  static String compact(double v) => _compact.format(v);
  static String day(DateTime? d) =>
      d == null ? '' : DateFormat('d MMM').format(d);
  static String dateTime(DateTime? d) =>
      d == null ? '' : DateFormat('d MMM yyyy, h:mm a').format(d);
}

/// Card ka rang (web ke chart rang jaise)
const metaColors = {
  'followers': Color(0xFF1877F2),
  'newFollowers': Color(0xFF10B981),
  'reach': Color(0xFF8B5CF6),
  'impressions': Color(0xFFF59E0B),
  'videoViews': Color(0xFFEC4899),
};

class MetaStatCard extends StatelessWidget {
  const MetaStatCard({super.key, required this.card});

  final MetaCard card;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final color = metaColors[card.key] ?? p.primary;
    final up = card.trend == 'up';
    final down = card.trend == 'down';
    final trendColor = up
        ? const Color(0xFF16A34A)
        : down
        ? const Color(0xFFDC2626)
        : p.subText;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  card.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.subText,
                    fontSize: 10.5,
                    letterSpacing: .5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Tooltip(
            message: MetaFormat.number(card.value),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                card.value >= 100000
                    ? MetaFormat.compact(card.value)
                    : MetaFormat.number(card.value),
                style: TextStyle(
                  color: p.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (card.growth != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: trendColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    up
                        ? Icons.arrow_upward_rounded
                        : down
                        ? Icons.arrow_downward_rounded
                        : Icons.remove_rounded,
                    size: 13,
                    color: trendColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${card.growth!.abs().toStringAsFixed(card.growth!.abs() < 10 ? 1 : 0)}%',
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Text('—', style: TextStyle(color: p.subText, fontSize: 12)),
        ],
      ),
    );
  }
}

class MetaLineChart extends StatelessWidget {
  const MetaLineChart({
    super.key,
    required this.title,
    required this.points,
    required this.color,
  });

  final String title;
  final List<MetaDayPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final axis = TextStyle(color: p.subText, fontSize: 10.5);
    final total = points.fold<double>(0, (s, e) => s + e.value);
    final maxY = points.isEmpty
        ? 1.0
        : points.map((e) => e.value).reduce(math.max);
    final step = math.max(1, (points.length / 6).ceil()).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Per day',
                      style: TextStyle(color: p.subText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                MetaFormat.compact(total),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'No data for this period.',
                      style: TextStyle(color: p.subText),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY <= 0 ? 1 : maxY * 1.15,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: p.border,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, meta) =>
                                Text(MetaFormat.compact(v), style: axis),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: step,
                            reservedSize: 22,
                            getTitlesWidget: (v, meta) {
                              final i = v.toInt();
                              if (v != i.toDouble() ||
                                  i < 0 ||
                                  i >= points.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  MetaFormat.day(points[i].day),
                                  style: axis,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => Colors.black87,
                          fitInsideHorizontally: true,
                          getTooltipItems: (spots) => [
                            for (final s in spots)
                              LineTooltipItem(
                                '${MetaFormat.day(points[s.x.toInt()].day)}\n'
                                '$title: ${MetaFormat.number(s.y)}',
                                TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < points.length; i++)
                              FlSpot(i.toDouble(), points[i].value),
                          ],
                          isCurved: true,
                          preventCurveOverShooting: true,
                          color: color,
                          barWidth: 2.5,
                          dotData: FlDotData(show: points.length <= 2),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withValues(alpha: .25),
                                color.withValues(alpha: 0),
                              ],
                            ),
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
}

class MetaPostCard extends StatelessWidget {
  const MetaPostCard({super.key, required this.post, this.onTap, this.rank});

  final MetaPost post;
  final VoidCallback? onTap;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget metric(IconData icon, Color color, double value, String label) =>
        Expanded(
          child: Tooltip(
            message: label,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    MetaFormat.compact(value),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: p.inner,
                      child: post.picture.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: post.picture,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Icon(
                                Icons.image_not_supported_outlined,
                                color: p.subText,
                              ),
                            )
                          : Icon(
                              Icons.image_not_supported_outlined,
                              color: p.subText,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.message.isEmpty ? 'No caption' : post.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MetaFormat.dateTime(post.created),
                          style: TextStyle(color: p.subText, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  if (rank != null)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1877F2).withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Color(0xFF1877F2),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: p.inner,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    metric(
                      Icons.favorite_rounded,
                      Colors.red,
                      post.reactions,
                      'Reactions',
                    ),
                    metric(
                      Icons.mode_comment_outlined,
                      p.subText,
                      post.comments,
                      'Comments',
                    ),
                    metric(
                      Icons.visibility_outlined,
                      const Color(0xFF8B5CF6),
                      post.reach,
                      'Reach',
                    ),
                    metric(
                      Icons.bolt_rounded,
                      const Color(0xFFF59E0B),
                      post.engagement,
                      'Engagement',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
