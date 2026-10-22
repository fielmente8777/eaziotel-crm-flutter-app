// lib/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/callAnalytis.dart
//
// UI only. Model: models/callAnalytisResponceModel.dart
//
// Usage (no params):
//   const SliverToBoxAdapter(child: CallAnalyticsSection()),
//
// Needs in DashboardController:
//   callAnalytics, isCallAnalyticsLoading, callRangeDays, changeCallRange()

import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/callAnalytisResponceModel.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ###################################################################
// HELPERS
// ###################################################################

final _num = NumberFormat.decimalPattern();

/// 44.94 → "44.9s", 166 → "2m 46s", 11189 → "3h 6m"
String _fmtDuration(double seconds) {
  final s = seconds.round();
  if (seconds < 60) {
    return seconds == seconds.roundToDouble()
        ? '${s}s'
        : '${seconds.toStringAsFixed(1)}s';
  }
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m ${sec}s';
}

String _titleCase(String s) => s
    .replaceAll(RegExp(r'[-_]'), ' ')
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

String _relative(DateTime? d) {
  if (d == null) return '—';
  final diff = DateTime.now().difference(d.toLocal());
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return DateFormat('d MMM').format(d.toLocal());
}

/// "09225261746" → "092252 61746"
String _fmtPhone(String p) {
  final digits = p.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('0')) {
    return '0${digits.substring(1, 6)} ${digits.substring(6)}';
  }
  if (digits.length == 10) {
    return '${digits.substring(0, 5)} ${digits.substring(5)}';
  }
  return p;
}

Color _statusColor(String k, int i) {
  switch (k.toLowerCase()) {
    case 'completed':
      return const Color(0xFF22C55E);
    case 'client-hangup':
      return const Color(0xFF3B82F6);
    case 'call-attempt':
      return const Color(0xFFF59E0B);
    case 'failed':
      return const Color(0xFFEF4444);
    case 'no-answer':
      return const Color(0xFFA855F7);
    case 'busy':
      return const Color(0xFFEC4899);
    case 'incomplete':
      return const Color(0xFFF97316);
    case 'canceled':
    case 'cancelled':
      return const Color(0xFF94A3B8);
    case '':
      return const Color(0xFF6B7280);
    default:
      return _palette[i % _palette.length];
  }
}

Color _directionColor(String k, int i) {
  switch (k.toLowerCase()) {
    case 'incoming':
      return const Color(0xFF0EA5E9);
    case 'inbound':
      return const Color(0xFFF97316);
    case 'outbound-api':
    case 'outbound':
    case 'outgoing':
      return const Color(0xFF16A34A);
    default:
      return _palette[i % _palette.length];
  }
}

IconData _directionIcon(String k) {
  final s = k.toLowerCase();
  if (s.contains('out')) return Icons.call_made_rounded;
  return Icons.call_received_rounded;
}

const _palette = [
  Color(0xFF6366F1),
  Color(0xFF06B6D4),
  Color(0xFF84CC16),
  Color(0xFFF43F5E),
  Color(0xFF8B5CF6),
  Color(0xFF14B8A6),
];

const _rangeOptions = <int, String>{
  1: 'Today',
  7: 'Last 7 days',
  30: 'Last 30 days',
  90: 'Last 90 days',
};

// ###################################################################
// SECTION (no params)
// ###################################################################

class CallAnalyticsSection extends StatelessWidget {
  const CallAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final loading = controller.isCallAnalyticsLoading.value;
      final doc = controller.callAnalytics.value?.doc;
      final range = controller.callRangeDays.value;

      return LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final pad = w >= 700 ? 20.0 : 16.0;
          const gap = 14.0;

          Widget body;
          if (loading && doc == null) {
            body = const _LoadingBlock();
          } else if (doc == null) {
            body = const _EmptyBlock();
          } else {
            final status = _CardShell(
              title: 'Calls by Status',
              subtitle: 'How calls ended',
              child: _DonutBreakdown(
                items: doc.statusDistribution,
                colorFor: _statusColor,
                centerLabel: 'CALLS',
                emptyLabel: 'Unknown',
              ),
            );
            final direction = _CardShell(
              title: 'Calls by Direction',
              subtitle: 'Incoming vs outgoing',
              child: _DonutBreakdown(
                items: doc.directionDistribution,
                colorFor: _directionColor,
                iconFor: _directionIcon,
                centerLabel: 'CALLS',
                emptyLabel: 'Unknown',
              ),
            );

            body = AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: loading ? 0.5 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KpiGrid(summary: doc.summary, width: w - pad * 2),
                  const SizedBox(height: gap),
                  _CardShell(
                    title: 'Call Trend',
                    subtitle: 'Daily total, successful and missed calls',
                    child: _TrendChart(points: doc.trend),
                  ),
                  const SizedBox(height: gap),
                  if (w >= 900)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: status),
                        const SizedBox(width: gap),
                        Expanded(child: direction),
                      ],
                    )
                  else ...[
                    status,
                    const SizedBox(height: gap),
                    direction,
                  ],
                  const SizedBox(height: gap),
                  _CardShell(
                    title: 'Top Callers',
                    subtitle: 'Tap a number to copy it',
                    child: _TopCallers(callers: doc.topCallers),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  range: range,
                  loading: loading,
                  onRange: controller.changeCallRange,
                ),
                const SizedBox(height: 14),
                body,
              ],
            ),
          );
        },
      );
    });
  }
}

// ###################################################################
// HEADER
// ###################################################################

class _Header extends StatelessWidget {
  final int range;
  final bool loading;
  final ValueChanged<int> onRange;

  const _Header({
    required this.range,
    required this.loading,
    required this.onRange,
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    const accent = Color(0xFF3B82F6);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Call Analytics',
                    style: TextStyle(
                      color: c.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (loading) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Monitor call performance and trends',
                style: TextStyle(color: c.subText, fontSize: 12.5),
              ),
            ],
          ),
        ),
        PopupMenuButton<int>(
          tooltip: 'Date range',
          color: c.card,
          elevation: 8,
          offset: const Offset(0, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: c.border),
          ),
          onSelected: onRange,
          itemBuilder: (_) => [
            for (final e in _rangeOptions.entries)
              PopupMenuItem<int>(
                value: e.key,
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          color: e.key == range ? accent : c.text,
                          fontSize: 13,
                          fontWeight: e.key == range
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (e.key == range)
                      const Icon(Icons.check, size: 16, color: accent),
                  ],
                ),
              ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Text(
                  _rangeOptions[range] ?? 'Last $range days',
                  style: TextStyle(
                    color: c.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 18, color: c.subText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ###################################################################
// CARD SHELL
// ###################################################################

class _CardShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const _CardShell({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final phone = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(phone ? 14 : 20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
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
                        color: c.text,
                        fontSize: phone ? 15 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(color: c.subText, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: phone ? 14 : 18),
          child,
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone_disabled_outlined, color: c.subText, size: 28),
          const SizedBox(height: 8),
          Text(
            'No call data for this period',
            style: TextStyle(color: c.subText),
          ),
        ],
      ),
    );
  }
}

// ###################################################################
// KPI GRID
// ###################################################################

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final CallMetric? metric;
  final bool goodWhenUp;
  final String Function(double)? fmtPrev;
  final double? rate; // 0..100 → mini bar

  const _KpiData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.metric,
    this.goodWhenUp = true,
    this.fmtPrev,
    this.rate,
  });
}

class _KpiGrid extends StatelessWidget {
  final CallSummary summary;
  final double width;

  const _KpiGrid({required this.summary, required this.width});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    String n(double v) => _num.format(v.round());

    final items = <_KpiData>[
      _KpiData(
        label: 'Total Calls',
        value: n(s.totalCalls.value),
        icon: Icons.call_outlined,
        color: const Color(0xFF3B82F6),
        metric: s.totalCalls,
        fmtPrev: n,
      ),
      _KpiData(
        label: 'Successful Calls',
        value: n(s.successfulCalls.value),
        icon: Icons.phone_callback_outlined,
        color: const Color(0xFF22C55E),
        metric: s.successfulCalls,
        fmtPrev: n,
      ),
      _KpiData(
        label: 'Missed Calls',
        value: n(s.missedCalls.value),
        icon: Icons.phone_missed_outlined,
        color: const Color(0xFFEF4444),
        metric: s.missedCalls,
        goodWhenUp: false,
        fmtPrev: n,
      ),
      _KpiData(
        label: 'Follow Ups',
        value: n(s.followUps.value),
        icon: Icons.event_note_outlined,
        color: const Color(0xFFF97316),
        metric: s.followUps,
        fmtPrev: n,
      ),
      _KpiData(
        label: 'Talk Time',
        value: _fmtDuration(s.totalTalkTime.value),
        icon: Icons.timer_outlined,
        color: const Color(0xFFA855F7),
        metric: s.totalTalkTime,
        fmtPrev: _fmtDuration,
      ),
      _KpiData(
        label: 'Average Duration',
        value: _fmtDuration(s.averageDuration.value),
        icon: Icons.schedule_rounded,
        color: const Color(0xFF6366F1),
        metric: s.averageDuration,
        fmtPrev: _fmtDuration,
      ),
      _KpiData(
        label: 'Success Rate',
        value: '${s.successRate.toStringAsFixed(1)}%',
        icon: Icons.verified_outlined,
        color: const Color(0xFF10B981),
        rate: s.successRate,
      ),
      _KpiData(
        label: 'Missed Rate',
        value: '${s.missedRate.toStringAsFixed(1)}%',
        icon: Icons.phone_disabled_outlined,
        color: const Color(0xFFF43F5E),
        rate: s.missedRate,
      ),
    ];

    final cols = width >= 1500
        ? 8
        : width >= 900
        ? 4
        : 2;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 124,
      ),
      itemBuilder: (_, i) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 350 + i * 60),
        curve: Curves.easeOutCubic,
        builder: (_, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: child,
          ),
        ),
        child: _KpiCard(data: items[i]),
      ),
    );
  }
}

class _KpiCard extends StatefulWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hover = false;
  bool _showPrev = false; // mobile tap toggle

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final d = widget.data;
    final active = _hover || _showPrev;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => setState(() => _showPrev = !_showPrev),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? d.color.withValues(alpha: 0.55) : c.border,
            ),
            boxShadow: [
              BoxShadow(
                color: active
                    ? d.color.withValues(alpha: c.isDark ? 0.18 : 0.14)
                    : Colors.black.withValues(alpha: c.isDark ? 0 : 0.04),
                blurRadius: active ? 16 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      d.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.subText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: active ? d.color : d.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      d.icon,
                      size: 17,
                      color: active ? Colors.white : d.color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  d.value,
                  maxLines: 1,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _footer(c, d, active),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer(AnalyticsPalette c, _KpiData d, bool active) {
    // Rate cards → mini bar
    if (d.rate != null) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: (d.rate! / 100).clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 5,
            backgroundColor: d.color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(d.color),
          ),
        ),
      );
    }

    final m = d.metric ?? CallMetric.empty;
    final neutral = m.trend == 'neutral' || m.change == 0;
    final up = m.trend == 'up' || m.change > 0;
    final good = neutral ? null : (up == d.goodWhenUp);
    final color = good == null
        ? c.subText
        : good
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    final icon = neutral
        ? Icons.remove_rounded
        : up
        ? Icons.north_east_rounded
        : Icons.south_east_rounded;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: active
          ? Text(
              'Prev: ${d.fmtPrev?.call(m.previous) ?? m.previous.toString()}',
              key: const ValueKey('prev'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.text,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            )
          : Row(
              key: const ValueKey('change'),
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 3),
                Text(
                  '${m.change.abs().toStringAsFixed(m.change.abs() >= 100 ? 0 : 2)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'vs previous period',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.subText, fontSize: 10.5),
                  ),
                ),
              ],
            ),
    );
  }
}

// ###################################################################
// TREND CHART
// ###################################################################

class _Series {
  final String label;
  final Color color;
  final int Function(CallTrendPoint) value;
  const _Series(this.label, this.color, this.value);
}

final _series = [
  _Series('Total', const Color(0xFF3B82F6), (p) => p.totalCalls),
  _Series('Successful', const Color(0xFF22C55E), (p) => p.successfulCalls),
  _Series('Missed', const Color(0xFFEF4444), (p) => p.missedCalls),
];

class _TrendChart extends StatefulWidget {
  final List<CallTrendPoint> points;
  const _TrendChart({required this.points});

  @override
  State<_TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<_TrendChart> {
  final Set<int> _hidden = {};

  double _niceMax(double v) {
    if (v <= 0) return 4;
    final padded = v * 1.15;
    final mag = math.pow(10, padded.floor().toString().length - 1).toDouble();
    final step = mag / 2;
    return (padded / step).ceil() * step;
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final pts = widget.points;
    final phone = MediaQuery.sizeOf(context).width < 600;

    final totals = [
      for (final s in _series) pts.fold<int>(0, (sum, p) => sum + s.value(p)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend toggles
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < _series.length; i++)
              _legendChip(c, i, totals[i]),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: phone ? 220 : 300,
          child: pts.isEmpty
              ? Center(
                  child: Text('No data', style: TextStyle(color: c.subText)),
                )
              : _hidden.length == _series.length
              ? Center(
                  child: Text(
                    'Select a series to show',
                    style: TextStyle(color: c.subText),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, box) => _chart(c, box.maxWidth, phone),
                ),
        ),
      ],
    );
  }

  Widget _legendChip(AnalyticsPalette c, int i, int total) {
    final s = _series[i];
    final on = !_hidden.contains(i);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => on ? _hidden.add(i) : _hidden.remove(i)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: on ? s.color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: on ? s.color.withValues(alpha: 0.5) : c.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: on ? s.color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: s.color, width: 1.5),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                s.label,
                style: TextStyle(
                  color: on ? c.text : c.subText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: on ? null : TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _num.format(total),
                style: TextStyle(
                  color: on ? s.color : c.subText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chart(AnalyticsPalette c, double width, bool phone) {
    final pts = widget.points;
    final visible = [
      for (int i = 0; i < _series.length; i++)
        if (!_hidden.contains(i)) i,
    ];

    var maxV = 0;
    for (final i in visible) {
      for (final p in pts) {
        maxV = math.max(maxV, _series[i].value(p));
      }
    }
    final maxY = _niceMax(maxV.toDouble());
    final yInterval = maxY / 4;

    final yReserved = phone ? 30.0 : 40.0;
    final maxLabels = ((width - yReserved) / (phone ? 56 : 84)).floor().clamp(
      2,
      14,
    );
    final xInterval = (pts.length / maxLabels).ceil().clamp(1, 1000).toDouble();

    final axis = TextStyle(color: c.subText, fontSize: phone ? 9.5 : 11);

    return LineChart(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      LineChartData(
        minX: 0,
        maxX: math.max(1, pts.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: c.grid, strokeWidth: 1, dashArray: [4, 4]),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: yReserved,
              interval: yInterval,
              getTitlesWidget: (v, _) =>
                  Text(v.round().toString(), style: axis),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: xInterval,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= pts.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM d').format(pts[i].date),
                    style: axis,
                  ),
                );
              },
            ),
          ),
        ),
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
            getTooltipItems: (spots) {
              return [
                for (int k = 0; k < spots.length; k++)
                  LineTooltipItem(
                    k == 0
                        ? '${DateFormat('EEE, MMM d').format(pts[spots[k].x.toInt()].date)}\n'
                        : '',
                    const TextStyle(color: Colors.white70, fontSize: 11),
                    children: [
                      TextSpan(
                        text: '${_series[visible[spots[k].barIndex]].label}: ',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: spots[k].y.round().toString(),
                        style: TextStyle(
                          color: _series[visible[spots[k].barIndex]].color,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ];
            },
          ),
          getTouchedSpotIndicator: (bar, indexes) => indexes
              .map(
                (_) => TouchedSpotIndicatorData(
                  FlLine(
                    color: c.subText.withValues(alpha: 0.4),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  FlDotData(
                    getDotPainter: (spot, _, b, __) => FlDotCirclePainter(
                      radius: 5,
                      color: b.color ?? Colors.blue,
                      strokeWidth: 2.5,
                      strokeColor: c.card,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        lineBarsData: [
          for (final i in visible)
            LineChartBarData(
              spots: [
                for (int k = 0; k < pts.length; k++)
                  FlSpot(k.toDouble(), _series[i].value(pts[k]).toDouble()),
              ],
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              color: _series[i].color,
              barWidth: i == 0 ? 3 : 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: pts.length == 1),
              belowBarData: BarAreaData(
                show: i == 0, // gradient only under Total
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _series[i].color.withValues(alpha: c.isDark ? 0.25 : 0.18),
                    _series[i].color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ###################################################################
// DONUT BREAKDOWN (status / direction)
// ###################################################################

class _DonutBreakdown extends StatefulWidget {
  final List<CallCount> items;
  final Color Function(String key, int index) colorFor;
  final IconData Function(String key)? iconFor;
  final String centerLabel;
  final String emptyLabel;

  const _DonutBreakdown({
    required this.items,
    required this.colorFor,
    required this.centerLabel,
    required this.emptyLabel,
    this.iconFor,
  });

  @override
  State<_DonutBreakdown> createState() => _DonutBreakdownState();
}

class _DonutBreakdownState extends State<_DonutBreakdown> {
  int? _hover;
  int? _selected;
  int? get _active => _hover ?? _selected;

  void _setHover(int? i) {
    if (_hover == i) return;
    setState(() => _hover = i);
  }

  void _toggle(int i) => setState(() => _selected = _selected == i ? null : i);

  @override
  void didUpdateWidget(covariant _DonutBreakdown old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      _hover = null;
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final items = [...widget.items.where((e) => e.count > 0)]
      ..sort((a, b) => b.count.compareTo(a.count));
    final total = items.fold<int>(0, (s, e) => s + e.count);

    if (total == 0) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text('No data', style: TextStyle(color: c.subText)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 460;
        final size = wide
            ? (box.maxWidth * 0.42).clamp(170.0, 220.0).toDouble()
            : (box.maxWidth * 0.66).clamp(170.0, 220.0).toDouble();

        final donut = _donut(c, items, total, size);
        final legend = Column(
          children: [
            for (int i = 0; i < items.length; i++)
              _legendRow(c, i, items[i], total),
          ],
        );

        return wide
            ? Row(
                children: [
                  donut,
                  const SizedBox(width: 22),
                  Expanded(child: legend),
                ],
              )
            : Column(
                children: [
                  Center(child: donut),
                  const SizedBox(height: 16),
                  legend,
                ],
              );
      },
    );
  }

  String _label(CallCount e) =>
      e.key.isEmpty ? widget.emptyLabel : _titleCase(e.key);

  Widget _donut(
    AnalyticsPalette c,
    List<CallCount> items,
    int total,
    double size,
  ) {
    final active = _active;
    final base = size * 0.15;
    final grow = size * 0.19;
    final hole = size * 0.31;
    final activeColor = active == null
        ? null
        : widget.colorFor(items[active].key, active);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (activeColor != null)
            Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: c.isDark ? 0.3 : 0.18),
                    blurRadius: 40,
                    spreadRadius: -8,
                  ),
                ],
              ),
            ),
          PieChart(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2.5,
              centerSpaceRadius: hole,
              borderData: FlBorderData(show: false),
              sections: [
                for (int i = 0; i < items.length; i++)
                  PieChartSectionData(
                    value: items[i].count.toDouble(),
                    radius: active == i ? grow : base,
                    showTitle: false,
                    color: widget
                        .colorFor(items[i].key, i)
                        .withValues(
                          alpha: active == null || active == i ? 1 : 0.25,
                        ),
                  ),
              ],
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final idx = response?.touchedSection?.touchedSectionIndex;
                  final valid = idx != null && idx >= 0 ? idx : null;
                  if (event is FlTapUpEvent) {
                    valid == null
                        ? setState(() => _selected = null)
                        : _toggle(valid);
                  } else if (event is FlPointerHoverEvent) {
                    _setHover(valid);
                  } else if (event is FlPointerExitEvent) {
                    _setHover(null);
                  }
                },
              ),
            ),
          ),
          IgnorePointer(
            child: SizedBox(
              width: hole * 1.6,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: active == null
                      ? Column(
                          key: const ValueKey('total'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _num.format(total),
                              style: TextStyle(
                                color: c.text,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              widget.centerLabel,
                              style: TextStyle(
                                color: c.subText,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          key: ValueKey('a$active'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(items[active].count / total * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: activeColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              _label(items[active]),
                              style: TextStyle(
                                color: c.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${_num.format(items[active].count)} calls',
                              style: TextStyle(color: c.subText, fontSize: 11),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(AnalyticsPalette c, int i, CallCount e, int total) {
    final color = widget.colorFor(e.key, i);
    final isActive = _active == i;
    final dimmed = _active != null && !isActive;
    final ratio = e.count / total;
    final unknown = e.key.isEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(i),
      onExit: (_) => _setHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggle(i),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: dimmed ? 0.4 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(vertical: 2),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive
                  ? color.withValues(alpha: c.isDark ? 0.1 : 0.07)
                  : Colors.transparent,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: Duration(milliseconds: 600 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: isActive ? 0.22 : 0.10),
                              color.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      if (widget.iconFor != null)
                        Icon(widget.iconFor!(e.key), size: 15, color: color)
                      else
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _label(e),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unknown ? c.subText : c.text,
                            fontSize: 13,
                            fontStyle: unknown
                                ? FontStyle.italic
                                : FontStyle.normal,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _num.format(e.count),
                        style: TextStyle(
                          color: c.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        width: 46,
                        child: Text(
                          '${(ratio * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: isActive ? color : c.subText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ###################################################################
// TOP CALLERS
// ###################################################################

class _TopCallers extends StatefulWidget {
  final List<TopCaller> callers;
  const _TopCallers({required this.callers});

  @override
  State<_TopCallers> createState() => _TopCallersState();
}

class _TopCallersState extends State<_TopCallers> {
  static const _accent = Color(0xFF3B82F6);
  int? _hover;
  bool _expanded = false;

  Future<void> _copy(TopCaller t) async {
    await Clipboard.setData(ClipboardData(text: t.phoneNumber));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text('Copied ${_fmtPhone(t.phoneNumber)}'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final list = widget.callers;
    if (list.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text('No callers', style: TextStyle(color: c.subText)),
        ),
      );
    }

    final maxCalls = list.map((e) => e.totalCalls).reduce(math.max);
    final shown = _expanded ? list : list.take(5).toList();

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 640;
        return Column(
          children: [
            if (wide) _tableHeader(c),
            for (int i = 0; i < shown.length; i++)
              wide
                  ? _wideRow(c, i, shown[i], maxCalls)
                  : _compactRow(c, i, shown[i], maxCalls),
            if (list.length > 5)
              TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: _accent,
                ),
                label: Text(
                  _expanded ? 'Show less' : 'Show all ${list.length}',
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _tableHeader(AnalyticsPalette c) {
    final s = TextStyle(
      color: c.subText,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );
    Widget cell(String t, double w) => SizedBox(
      width: w,
      child: Text(t, textAlign: TextAlign.right, style: s),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Row(
        children: [
          const SizedBox(width: 38),
          Expanded(child: Text('CALLER', style: s)),
          SizedBox(width: 160, child: Text('CALLS', style: s)),
          cell('TALK TIME', 90),
          cell('AVG', 80),
          cell('LAST CALL', 90),
        ],
      ),
    );
  }

  Widget _rank(int i, bool active) {
    final colors = [
      const Color(0xFFF59E0B),
      const Color(0xFF94A3B8),
      const Color(0xFFB45309),
    ];
    final color = i < 3 ? colors[i] : _accent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? color : color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${i + 1}',
        style: TextStyle(
          color: active ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _callsBar(AnalyticsPalette c, int i, TopCaller t, int maxCalls) {
    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: maxCalls == 0 ? 0 : t.totalCalls / maxCalls,
            ),
            duration: Duration(milliseconds: 600 + i * 70),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: c.text.withValues(alpha: 0.07),
                valueColor: const AlwaysStoppedAnimation(_accent),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '${t.totalCalls}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: c.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _phone(AnalyticsPalette c, TopCaller t, bool active) => Row(
    children: [
      Flexible(
        child: Text(
          _fmtPhone(t.phoneNumber),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: c.text,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
      const SizedBox(width: 6),
      AnimatedOpacity(
        opacity: active ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: Icon(Icons.copy_rounded, size: 13, color: c.subText),
      ),
    ],
  );

  Widget _rowShell(int i, TopCaller t, Widget child) {
    final c = AnalyticsPalette.of(context);
    final active = _hover == i;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = i),
      onExit: (_) => setState(() => _hover = null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _copy(t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? _accent.withValues(alpha: c.isDark ? 0.08 : 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _wideRow(AnalyticsPalette c, int i, TopCaller t, int maxCalls) {
    final active = _hover == i;
    final cell = TextStyle(color: c.text, fontSize: 13);

    return _rowShell(
      i,
      t,
      Row(
        children: [
          _rank(i, active),
          const SizedBox(width: 10),
          Expanded(child: _phone(c, t, active)),
          SizedBox(width: 160, child: _callsBar(c, i, t, maxCalls)),
          SizedBox(
            width: 90,
            child: Text(
              _fmtDuration(t.totalTalkTime.toDouble()),
              textAlign: TextAlign.right,
              style: cell,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              _fmtDuration(t.averageDuration),
              textAlign: TextAlign.right,
              style: cell,
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              _relative(t.lastCall),
              textAlign: TextAlign.right,
              style: TextStyle(color: c.subText, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactRow(AnalyticsPalette c, int i, TopCaller t, int maxCalls) {
    final active = _hover == i;
    return _rowShell(
      i,
      t,
      Row(
        children: [
          _rank(i, active),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _phone(c, t, true)),
                    Text(
                      _relative(t.lastCall),
                      style: TextStyle(color: c.subText, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _callsBar(c, i, t, maxCalls),
                const SizedBox(height: 4),
                Text(
                  'Talk ${_fmtDuration(t.totalTalkTime.toDouble())}  ·  '
                  'Avg ${_fmtDuration(t.averageDuration)}',
                  style: TextStyle(color: c.subText, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
