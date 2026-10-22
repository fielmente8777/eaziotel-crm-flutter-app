import 'dart:math' as math;

import 'package:eazotel/features/googleAnalytis/models/traffic_sources_model.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/AnalyticsUiKit.dart' show analyticsLoader;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrafficChannelsCard extends StatefulWidget {
  final List<TrafficChannel> channels;
  final AnalyticsLayout layout;
  final bool isLoading;

  const TrafficChannelsCard({
    super.key,
    required this.channels,
    required this.layout,
    this.isLoading = false,
  });

  @override
  State<TrafficChannelsCard> createState() => _TrafficChannelsCardState();
}

class _TrafficChannelsCardState extends State<TrafficChannelsCard> {
  
  int? _selected; // from a tap
  int? _hover; // from mouse hover (desktop)

  int? get _active => _hover ?? _selected;

  final _fmt = NumberFormat.decimalPattern();

  @override
  void didUpdateWidget(covariant TrafficChannelsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // New data arrived (date range changed) -> reset the selection
    if (oldWidget.channels != widget.channels) {
      _selected = null;
      _hover = null;
    }
  }

  void _toggle(int i) => setState(() => _selected = _selected == i ? null : i);

  void _setHover(int? i) {
    if (_hover == i) return;
    setState(() => _hover = i);
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final channels = widget.channels;
    final total = channels.fold<int>(0, (s, e) => s + e.sessions);

    return AnalyticsCard(
      title: 'By channel',
      trailing: '${_fmt.format(total)} sessions',
      layout: widget.layout,
      child: widget.isLoading
          ? analyticsLoader()
          : total == 0
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No data', style: TextStyle(color: c.subText)),
              ),
            )
          : LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth;
                final stacked = w < 300;

                final size = stacked
                    ? math.min(w, 220.0)
                    : (w * 0.5).clamp(130.0, 220.0).toDouble();

                final donut = _donut(c, size, total);
                final legend = _legend(c);

                if (stacked) {
                  return Column(
                    children: [
                      Center(child: donut),
                      const SizedBox(height: 16),
                      legend,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    donut,
                    const SizedBox(width: 16),
                    Expanded(child: legend),
                  ],
                );
              },
            ),
    );
  }

  // ======================= DONUT =======================
  Widget _donut(AnalyticsPalette c, double size, int total) {
    final channels = widget.channels;
    final active = _active;

    final baseRadius = size * 0.17;
    final activeRadius = size * 0.20;
    final hole = size * 0.30;

    final sections = <PieChartSectionData>[
      for (int i = 0; i < channels.length; i++)
        PieChartSectionData(
          value: channels[i].sessions.toDouble(),
          color: c
              .channelColorFor(channels[i].channel)
              .withValues(alpha: active == null || active == i ? 1 : 0.35),
          radius: active == i ? activeRadius : baseRadius,
          showTitle: false,
          borderSide: BorderSide(color: c.card, width: 1.5),
        ),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            PieChartData(
              sections: sections,
              centerSpaceRadius: hole,
              sectionsSpace: 1.5,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final idx = response?.touchedSection?.touchedSectionIndex;
                  final valid = idx != null && idx >= 0 ? idx : null;

                  if (event is FlTapUpEvent) {
                    if (valid == null) {
                      setState(() => _selected = null);
                    } else {
                      _toggle(valid);
                    }
                  } else if (event is FlPointerHoverEvent) {
                    _setHover(valid);
                  } else if (event is FlPointerExitEvent) {
                    _setHover(null);
                  }
                },
              ),
            ),
          ),
          _center(c, total, hole * 2),
        ],
      ),
    );
  }

  /// Text in the middle of the donut
  Widget _center(AnalyticsPalette c, int total, double holeDiameter) {
    final i = _active;
    final ch = (i != null && i < widget.channels.length)
        ? widget.channels[i]
        : null;

    final label = ch?.channel ?? 'Sessions';
    final value = _fmt.format(ch?.sessions ?? total);
    final percent = ch == null
        ? null
        : '${(ch.sessions / total * 100).toStringAsFixed(1)}%';
    final color = ch == null ? c.text : c.channelColorFor(ch.channel);

    return IgnorePointer(
      child: SizedBox(
        width: holeDiameter * 0.82,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                style: TextStyle(color: c.subText, fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              if (percent != null)
                Text(percent, style: TextStyle(color: c.subText, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  // ======================= LEGEND =======================
  Widget _legend(AnalyticsPalette c) {
    final channels = widget.channels;
    final active = _active;

    // Alphabetical order, like the screenshot
    final order = List<int>.generate(channels.length, (i) => i)
      ..sort((a, b) => channels[a].channel.compareTo(channels[b].channel));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final i in order)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => _setHover(i),
            onExit: (_) => _setHover(null),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggle(i),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: active == null || active == i ? 1 : 0.45,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: c.channelColorFor(channels[i].channel),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          channels[i].channel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active == i
                                ? c.channelColorFor(channels[i].channel)
                                : c.text,
                            fontSize: widget.layout.bodyFont - 0.5,
                            fontWeight: active == i
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _fmt.format(channels[i].sessions),
                        style: TextStyle(
                          color: c.subText,
                          fontSize: widget.layout.bodyFont - 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final AnalyticsLayout layout;
  final Widget child;

  const AnalyticsCard({
    super.key,
    required this.title,
    this.trailing,
    required this.layout,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AnalyticsPalette.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isPhone ? 14 : 18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(layout.radius),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.subText,
                    fontSize: layout.bodyFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              if (trailing != null)
                Text(
                  trailing!,
                  style: TextStyle(
                    color: colors.subText,
                    fontSize: layout.bodyFont - 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          SizedBox(height: layout.isPhone ? 14 : 18),

          child,
        ],
      ),
    );
  }
}
