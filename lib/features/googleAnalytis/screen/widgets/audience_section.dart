// lib/features/googleAnalytis/screen/widgets/audience_section.dart

 import 'package:eazotel/features/googleAnalytis/models/audienceModle.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/AnalyticsUiKit.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
 import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Users by device + Users by country (audience API)
class AudienceSection extends StatelessWidget {
  final AudienceModel? data;
  final AnalyticsLayout layout;
  final bool isLoading;

  const AudienceSection({
    super.key,
    required this.data,
    required this.layout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final device = _UsersByDeviceCard(
      devices: data?.devices ?? const [],
      layout: layout,
      isLoading: isLoading,
    );
    final country = _UsersByCountryCard(
      countries: data?.countries ?? const [],
      layout: layout,
      isLoading: isLoading,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Audience',
          subtitle: 'Who is visiting',
          layout: layout,
          accent: const [Color(0xFF2F7BEB), Color(0xFF10B981)],
        ),
        SizedBox(height: layout.isPhone ? 12 : 16),
        LayoutBuilder(
          builder: (context, box) {
            final gap = layout.gap + 4;
            if (box.maxWidth >= 860) {
              Widget col(Widget w) => Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 400),
                      child: w,
                    ),
                  );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [col(device), SizedBox(width: gap), col(country)],
              );
            }
            return Column(
              children: [device, SizedBox(height: gap), country],
            );
          },
        ),
      ],
    );
  }
}

// ===================================================================
// USERS BY DEVICE
// ===================================================================

class _UsersByDeviceCard extends StatefulWidget {
  final List<AudienceDevice> devices;
  final AnalyticsLayout layout;
  final bool isLoading;

  const _UsersByDeviceCard({
    required this.devices,
    required this.layout,
    required this.isLoading,
  });

  @override
  State<_UsersByDeviceCard> createState() => _UsersByDeviceCardState();
}

class _UsersByDeviceCardState extends State<_UsersByDeviceCard>
    with HoverSelect<_UsersByDeviceCard, int> {
  static const _accent = Color(0xFF2F7BEB);
  final _fmt = NumberFormat.decimalPattern();

  @override
  void didUpdateWidget(covariant _UsersByDeviceCard old) {
    super.didUpdateWidget(old);
    if (old.devices != widget.devices) resetHoverSelect();
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final devices = widget.devices;
    final total = devices.fold<int>(0, (s, d) => s + d.value);

    return AnalyticsShell(
      title: 'Users by device',
      accent: _accent,
      icon: Icons.devices_outlined,
      colorTitle: false,
      layout: widget.layout,
      child: widget.isLoading
          ? analyticsLoader()
          : total == 0
              ? analyticsEmpty(c)
              : LayoutBuilder(
                  builder: (context, box) {
                    final size =
                        (box.maxWidth * 0.62).clamp(170.0, 240.0).toDouble();
                    return Column(
                      children: [
                        const SizedBox(height: 6),
                        Center(child: _donut(c, size, total)),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (int i = 0; i < devices.length; i++)
                              _chip(c, i, devices[i], total),
                          ],
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _donut(AnalyticsPalette c, double size, int total) {
    final devices = widget.devices;
    final active = activeKey;
    final base = size * 0.15;
    final grow = size * 0.19;
    final hole = size * 0.33;

    final activeColor =
        active == null ? _accent : deviceColor(devices[active].name, active);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: c.isDark ? 0.25 : 0.15),
                  blurRadius: 44,
                  spreadRadius: -8,
                ),
              ],
            ),
          ),
          PieChart(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 4,
              centerSpaceRadius: hole,
              borderData: FlBorderData(show: false),
              sections: [
                for (int i = 0; i < devices.length; i++)
                  PieChartSectionData(
                    value: devices[i].value.toDouble(),
                    radius: active == i ? grow : base,
                    showTitle: false,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        deviceColor(devices[i].name, i),
                        darker(deviceColor(devices[i].name, i)),
                      ]
                          .map((col) => col.withValues(
                                alpha: active == null || active == i ? 1 : 0.28,
                              ))
                          .toList(),
                    ),
                  ),
              ],
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final idx = response?.touchedSection?.touchedSectionIndex;
                  final valid = idx != null && idx >= 0 ? idx : null;
                  if (event is FlTapUpEvent) {
                    valid == null
                        ? setState(() => selectedKey = null)
                        : toggleSelect(valid);
                  } else if (event is FlPointerHoverEvent) {
                    setHover(valid);
                  } else if (event is FlPointerExitEvent) {
                    setHover(null);
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
                  duration: const Duration(milliseconds: 220),
                  child: active == null
                      ? Column(
                          key: const ValueKey('total'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: total.toDouble()),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => Text(
                                _fmt.format(v.round()),
                                style: TextStyle(
                                  color: c.text,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            Text(
                              'USERS',
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
                          key: ValueKey('d$active'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(deviceIcon(devices[active].name),
                                size: 20, color: activeColor),
                            Text(
                              '${(devices[active].value / total * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: activeColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            Text(
                              '${_fmt.format(devices[active].value)} ${devices[active].name}',
                              style: TextStyle(
                                color: c.subText,
                                fontSize: 11,
                              ),
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

  Widget _chip(AnalyticsPalette c, int i, AudienceDevice d, int total) {
    final color = deviceColor(d.name, i);
    final isActive = activeKey == i;
    final dimmed = activeKey != null && !isActive;
    final pct = d.value / total * 100;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setHover(i),
      onExit: (_) => setHover(null),
      child: GestureDetector(
        onTap: () => toggleSelect(i),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.5 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            transform: Matrix4.translationValues(0, isActive ? -2 : 0, 0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isActive ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: color.withValues(alpha: isActive ? 0.6 : 0.2),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(deviceIcon(d.name), size: 15, color: color),
                const SizedBox(width: 7),
                Text(
                  d.name,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedPercentText(
                  pct,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

// ===================================================================
// USERS BY COUNTRY
// ===================================================================

class _UsersByCountryCard extends StatefulWidget {
  final List<AudienceCountry> countries;
  final AnalyticsLayout layout;
  final bool isLoading;

  const _UsersByCountryCard({
    required this.countries,
    required this.layout,
    required this.isLoading,
  });

  @override
  State<_UsersByCountryCard> createState() => _UsersByCountryCardState();
}

class _UsersByCountryCardState extends State<_UsersByCountryCard>
    with HoverSelect<_UsersByCountryCard, String> {
  static const _accent = Color(0xFF6366F1);
  static const _collapsed = 6;
  bool _expanded = false;
  final _fmt = NumberFormat.decimalPattern();

  @override
  void didUpdateWidget(covariant _UsersByCountryCard old) {
    super.didUpdateWidget(old);
    if (old.countries != widget.countries) resetHoverSelect();
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final items = [...widget.countries]
      ..sort((a, b) => b.users.compareTo(a.users));
    final total = items.fold<int>(0, (s, e) => s + e.users);
    final maxV = items.isEmpty ? 0 : items.first.users;
    final visible = items.length > _collapsed && !_expanded
        ? items.take(_collapsed).toList()
        : items;

    return AnalyticsShell(
      title: 'Users by country',
      accent: _accent,
      icon: Icons.public,
      colorTitle: false,
      layout: widget.layout,
      child: widget.isLoading
          ? analyticsLoader()
          : total == 0
              ? analyticsEmpty(c)
              : Column(
                  children: [
                    for (int i = 0; i < visible.length; i++)
                      _row(c, i, visible[i], total, maxV),
                    if (items.length > _collapsed)
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _expanded = !_expanded),
                        icon: Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: _accent,
                        ),
                        label: Text(
                          _expanded ? 'Show less' : 'Show all ${items.length}',
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _row(
    AnalyticsPalette c,
    int i,
    AudienceCountry it,
    int total,
    int maxV,
  ) {
    final color = seriesColor(i);
    final isActive = activeKey == it.name;
    final dimmed = activeKey != null && !isActive;
    final pct = it.users / total * 100;

    return MouseRegion(
      key: ValueKey(it.name),
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setHover(it.name),
      onExit: (_) => setHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => toggleSelect(it.name),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.45 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Column(
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 10 : 8,
                      height: isActive ? 10 : 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        it.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.text,
                          fontSize: widget.layout.bodyFont + 2.5,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: SizeTransition(
                          sizeFactor: a,
                          axis: Axis.horizontal,
                          child: child,
                        ),
                      ),
                      child: isActive
                          ? Container(
                              key: const ValueKey('pct'),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${pct.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('none')),
                    ),
                    Text(
                      _fmt.format(it.users),
                      style: TextStyle(
                        color: color,
                        fontSize: widget.layout.bodyFont + 3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                // Screenshot jaisa: top country full bar, baaki uske relative
                GlowBar(
                  ratio: maxV == 0 ? 0 : it.users / maxV,
                  color: color,
                  active: isActive,
                  index: i,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}