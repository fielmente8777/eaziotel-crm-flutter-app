// lib/features/googleAnalytis/screen/widgets/device_tech_section.dart

import 'package:eazotel/features/googleAnalytis/models/deviceModle.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/AnalyticsUiKit.dart' show analyticsLoader;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ===================================================================
// COLORS
// ===================================================================

const _fallback = [
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
  Color(0xFF8B5CF6),
  Color(0xFF06B6D4),
  Color(0xFFEF4444),
  Color(0xFF84CC16),
];

Color _deviceColor(String name, int i) {
  switch (name.toLowerCase()) {
    case 'desktop':
      return const Color(0xFF2F7BEB);
    case 'mobile':
      return const Color(0xFF10B981);
    case 'tablet':
      return const Color(0xFFF59E0B);
    case 'smart tv':
      return const Color(0xFF8B5CF6);
    default:
      return _fallback[i % _fallback.length];
  }
}

IconData _deviceIcon(String name) {
  switch (name.toLowerCase()) {
    case 'desktop':
      return Icons.desktop_windows_outlined;
    case 'mobile':
      return Icons.smartphone_outlined;
    case 'tablet':
      return Icons.tablet_mac_outlined;
    case 'smart tv':
      return Icons.tv_outlined;
    default:
      return Icons.devices_other_outlined;
  }
}

Color _browserColor(String name, int i) {
  switch (name.toLowerCase()) {
    case 'chrome':
      return const Color(0xFF6366F1);
    case 'edge':
      return const Color(0xFF06B6D4);
    case 'safari':
    case 'safari (in-app)':
      return const Color(0xFFF59E0B);
    case 'firefox':
      return const Color(0xFFF97316);
    case 'samsung internet':
      return const Color(0xFF8B5CF6);
    case 'opera':
      return const Color(0xFFEF4444);
    case 'android webview':
      return const Color(0xFF10B981);
    default:
      return _fallback[i % _fallback.length];
  }
}

Color _osColor(String name, int i) {
  switch (name.toLowerCase()) {
    case 'windows':
      return const Color(0xFFEF4444);
    case 'linux':
      return const Color(0xFF10B981);
    case 'android':
      return const Color(0xFFEC4899);
    case 'macintosh':
    case 'mac os x':
      return const Color(0xFF8B5CF6);
    case 'ios':
      return const Color(0xFF3B82F6);
    case 'chrome os':
      return const Color(0xFFF59E0B);
    default:
      return _fallback[i % _fallback.length];
  }
}

Color _darker(Color c, [double t = 0.22]) => Color.lerp(c, Colors.black, t)!;

/// Count-up percent text
Widget _animatedPercent(
  double pct, {
  required TextStyle style,
  Duration duration = const Duration(milliseconds: 800),
}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: pct),
    duration: duration,
    curve: Curves.easeOutCubic,
    builder: (_, v, __) => Text('${v.toStringAsFixed(1)}%', style: style),
  );
}

// ===================================================================
// SECTION
// ===================================================================

class DeviceTechSection extends StatelessWidget {
  final DevicesModel? data;
  final AnalyticsLayout layout;
  final bool isLoading;

  const DeviceTechSection({
    super.key,
    required this.data,
    required this.layout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);

    final device = DeviceCategoryCard(
      devices: data?.devices ?? const [],
      layout: layout,
      isLoading: isLoading,
    );
    final browsers = RankedBarsCard(
      title: 'Top Browsers',
      titleColor: const Color(0xFF3B82F6),
      icon: Icons.public,
      items: data?.browsers ?? const [],
      colorFor: _browserColor,
      layout: layout,
      isLoading: isLoading,
    );
    final os = RankedBarsCard(
      title: 'Operating Systems',
      titleColor: const Color(0xFFA855F7),
      icon: Icons.memory_outlined,
      items: data?.operatingSystems ?? const [],
      colorFor: _osColor,
      layout: layout,
      isLoading: isLoading,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3B82F6), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Device & Tech',
              style: TextStyle(
                color: c.text,
                fontSize: layout.isPhone ? 17 : 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: layout.isPhone ? 12 : 16),
        LayoutBuilder(
          builder: (context, box) {
            final gap = layout.gap + 4;
            final w = box.maxWidth;

            // Desktop: 3 barabar columns
            if (w >= 960) {
              Widget col(Widget child) => Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 420),
                  child: child,
                ),
              );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  col(device),
                  SizedBox(width: gap),
                  col(browsers),
                  SizedBox(width: gap),
                  col(os),
                ],
              );
            }

            // Tablet: device full width, neeche 2 columns
            if (w >= 600) {
              return Column(
                children: [
                  device,
                  SizedBox(height: gap),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: browsers),
                      SizedBox(width: gap),
                      Expanded(child: os),
                    ],
                  ),
                ],
              );
            }

            // Phone: stacked
            return Column(
              children: [
                device,
                SizedBox(height: gap),
                browsers,
                SizedBox(height: gap),
                os,
              ],
            );
          },
        ),
      ],
    );
  }
}

// ===================================================================
// SHARED SHELL (top par gradient accent line)
// ===================================================================

class _Shell extends StatelessWidget {
  final String title;
  final Color accent;
  final Color? titleColor;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final AnalyticsLayout layout;

  const _Shell({
    required this.title,
    required this.accent,
    required this.child,
    required this.layout,
    this.titleColor,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final tc = titleColor ?? c.text;
    final pad = layout.isPhone ? 14.0 : 20.0;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(layout.radius),
        border: Border.all(color: c.border),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.35],
          colors: [
            Color.alphaBlend(
              accent.withValues(alpha: c.isDark ? 0.07 : 0.04),
              c.card,
            ),
            c.card,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, pad - 3, pad, pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 15, color: accent),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: tc,
                          fontSize: layout.isPhone ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                SizedBox(height: layout.isPhone ? 14 : 18),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _loader() => analyticsLoader();

Widget _empty(AnalyticsPalette c) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 32),
  child: Center(
    child: Text('No data', style: TextStyle(color: c.subText)),
  ),
);

// ===================================================================
// DEVICE CATEGORY (percent donut + pills)
// ===================================================================

enum _DeviceMode { users, sessions }

class DeviceCategoryCard extends StatefulWidget {
  final List<DeviceItem> devices;
  final AnalyticsLayout layout;
  final bool isLoading;

  const DeviceCategoryCard({
    super.key,
    required this.devices,
    required this.layout,
    this.isLoading = false,
  });

  @override
  State<DeviceCategoryCard> createState() => _DeviceCategoryCardState();
}

class _DeviceCategoryCardState extends State<DeviceCategoryCard> {
  static const _accent = Color(0xFF2F7BEB);

  _DeviceMode _mode = _DeviceMode.users;
  int? _selected;
  int? _hover;
  int? get _active => _hover ?? _selected;

  final _fmt = NumberFormat.decimalPattern();

  @override
  void didUpdateWidget(covariant DeviceCategoryCard old) {
    super.didUpdateWidget(old);
    if (old.devices != widget.devices) {
      _selected = null;
      _hover = null;
    }
  }

  int _v(DeviceItem d) => _mode == _DeviceMode.users ? d.value : d.sessions;

  void _setHover(int? i) {
    if (_hover == i) return;
    setState(() => _hover = i);
  }

  void _toggle(int i) => setState(() => _selected = _selected == i ? null : i);

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final devices = widget.devices;
    final total = devices.fold<int>(0, (s, d) => s + _v(d));

    return _Shell(
      title: 'Device Category',
      accent: _accent,
      icon: Icons.devices_outlined,
      layout: widget.layout,
      trailing: devices.isEmpty ? null : _modeToggle(c),
      child: widget.isLoading
          ? _loader()
          : (devices.isEmpty || total == 0)
          ? _empty(c)
          : LayoutBuilder(
              builder: (context, box) {
                final size = (box.maxWidth * 0.62).clamp(160.0, 220.0);
                return Column(
                  children: [
                    Center(child: _donut(c, size.toDouble(), total)),
                    const SizedBox(height: 20),
                    for (int i = 0; i < devices.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _pill(c, i, devices[i], total),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _modeToggle(AnalyticsPalette c) {
    Widget seg(_DeviceMode m, String label) {
      final sel = _mode == m;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _mode = m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: sel ? _accent.withValues(alpha: 0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: sel ? _accent : c.subText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.text.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg(_DeviceMode.users, 'Users'),
          seg(_DeviceMode.sessions, 'Sessions'),
        ],
      ),
    );
  }

  Widget _donut(AnalyticsPalette c, double size, int total) {
    final devices = widget.devices;
    final active = _active;

    final base = size * 0.20;
    final grow = size * 0.245;
    final hole = size * 0.26;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow ring peeche
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      (active == null
                              ? _accent
                              : _deviceColor(devices[active].name, active))
                          .withValues(alpha: c.isDark ? 0.22 : 0.14),
                  blurRadius: 40,
                  spreadRadius: -6,
                ),
              ],
            ),
          ),
          PieChart(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 3,
              centerSpaceRadius: hole,
              borderData: FlBorderData(show: false),
              sections: [
                for (int i = 0; i < devices.length; i++)
                  _section(c, i, devices[i], total, active, base, grow),
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
          IgnorePointer(child: _center(c, total, hole * 2)),
        ],
      ),
    );
  }

  PieChartSectionData _section(
    AnalyticsPalette c,
    int i,
    DeviceItem d,
    int total,
    int? active,
    double base,
    double grow,
  ) {
    final color = _deviceColor(d.name, i);
    final on = active == null || active == i;
    final pct = total == 0 ? 0.0 : _v(d) / total * 100;

    return PieChartSectionData(
      value: _v(d).toDouble(),
      radius: active == i ? grow : base,
      // Slice par percent — chhote slice (<7%) par nahi, wahan pill kaafi hai
      showTitle: pct >= 7,
      title: '${pct.toStringAsFixed(pct >= 10 ? 0 : 1)}%',
      titlePositionPercentageOffset: 0.55,
      titleStyle: TextStyle(
        color: Colors.white.withValues(alpha: on ? 1 : 0.5),
        fontSize: active == i ? 13 : 11.5,
        fontWeight: FontWeight.w800,
        shadows: const [Shadow(color: Colors.black38, blurRadius: 4)],
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: on ? 1 : 0.28),
          _darker(color).withValues(alpha: on ? 1 : 0.28),
        ],
      ),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: active == i ? 0.6 : 0.15),
        width: active == i ? 1.5 : 1,
      ),
    );
  }

  Widget _center(AnalyticsPalette c, int total, double d) {
    final i = _active;
    final dev = (i != null && i < widget.devices.length)
        ? widget.devices[i]
        : null;
    final color = dev == null ? c.text : _deviceColor(dev.name, i!);

    // Default: sabse bada device ka % dikhao
    final top = widget.devices.isEmpty
        ? null
        : widget.devices.reduce((a, b) => _v(a) >= _v(b) ? a : b);
    final topIdx = top == null ? 0 : widget.devices.indexOf(top);
    final showDev = dev ?? top;
    final showColor = dev == null && top != null
        ? _deviceColor(top.name, topIdx)
        : color;
    final pct = (showDev == null || total == 0)
        ? 0.0
        : _v(showDev) / total * 100;

    return SizedBox(
      width: d * 0.82,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Column(
            key: ValueKey('$i-$_mode'),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDev != null)
                Icon(_deviceIcon(showDev.name), size: 18, color: showColor),
              const SizedBox(height: 2),
              _animatedPercent(
                pct,
                duration: const Duration(milliseconds: 600),
                style: TextStyle(
                  color: showColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                showDev?.name ?? '',
                style: TextStyle(color: c.subText, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(AnalyticsPalette c, int i, DeviceItem d, int total) {
    final color = _deviceColor(d.name, i);
    final isActive = _active == i;
    final dimmed = _active != null && !isActive;
    final pct = total == 0 ? 0.0 : _v(d) / total * 100;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(i),
      onExit: (_) => _setHover(null),
      child: GestureDetector(
        onTap: () => _toggle(i),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.5 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isActive ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: color.withValues(alpha: isActive ? 0.6 : 0.18),
              ),
            ),
            child: Stack(
              children: [
                // Pill ke andar percent fill
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct / 100),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.22),
                              color.withValues(alpha: 0.06),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(_deviceIcon(d.name), size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: widget.layout.bodyFont + 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _animatedPercent(
                        pct,
                        style: TextStyle(
                          color: c.text,
                          fontSize: widget.layout.bodyFont + 3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${_fmt.format(_v(d))})',
                        style: TextStyle(
                          color: c.subText,
                          fontSize: widget.layout.bodyFont,
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

// ===================================================================
// RANKED BARS (Browsers / OS) — sab percent me
// ===================================================================

class RankedBarsCard extends StatefulWidget {
  final String title;
  final Color titleColor;
  final IconData icon;
  final List<NameValue> items;
  final Color Function(String name, int index) colorFor;
  final AnalyticsLayout layout;
  final bool isLoading;

  /// Itne se zyada ho to "Show all" aata hai
  final int collapsedCount;

  const RankedBarsCard({
    super.key,
    required this.title,
    required this.titleColor,
    required this.icon,
    required this.items,
    required this.colorFor,
    required this.layout,
    this.isLoading = false,
    this.collapsedCount = 6,
  });

  @override
  State<RankedBarsCard> createState() => _RankedBarsCardState();
}

class _RankedBarsCardState extends State<RankedBarsCard> {
  String? _selected;
  String? _hover;
  String? get _active => _hover ?? _selected;
  bool _expanded = false;

  final _fmt = NumberFormat.decimalPattern();

  @override
  void didUpdateWidget(covariant RankedBarsCard old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      _selected = null;
      _hover = null;
    }
  }

  void _setHover(String? n) {
    if (_hover == n) return;
    setState(() => _hover = n);
  }

  void _toggle(String n) =>
      setState(() => _selected = _selected == n ? null : n);

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final items = [...widget.items]..sort((a, b) => b.value.compareTo(a.value));
    final total = items.fold<int>(0, (s, e) => s + e.value);

    final canCollapse = items.length > widget.collapsedCount;
    final visible = canCollapse && !_expanded
        ? items.take(widget.collapsedCount).toList()
        : items;

    return _Shell(
      title: widget.title,
      titleColor: widget.titleColor,
      accent: widget.titleColor,
      icon: widget.icon,
      layout: widget.layout,
      trailing: items.isEmpty || widget.isLoading
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.text.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_fmt.format(total)} users',
                style: TextStyle(
                  color: c.subText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      child: widget.isLoading
          ? _loader()
          : (items.isEmpty || total == 0)
          ? _empty(c)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _distributionStrip(c, items, total),
                const SizedBox(height: 16),
                for (int i = 0; i < visible.length; i++)
                  _row(c, i, visible[i], total),
                if (canCollapse)
                  Center(
                    child: TextButton.icon(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: widget.titleColor,
                      ),
                      label: Text(
                        _expanded ? 'Show less' : 'Show all ${items.length}',
                        style: TextStyle(
                          color: widget.titleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  /// 100% stacked strip — har segment ek item ka share
  Widget _distributionStrip(
    AnalyticsPalette c,
    List<NameValue> items,
    int total,
  ) {
    final active = _active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, t, child) => ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: t,
              child: child,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    if (items[i].value > 0)
                      Flexible(
                        flex: items[i].value,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => _setHover(items[i].name),
                          onExit: (_) => _setHover(null),
                          child: GestureDetector(
                            onTap: () => _toggle(items[i].name),
                            child: Tooltip(
                              message:
                                  '${items[i].name} · ${(items[i].value / total * 100).toStringAsFixed(1)}%',
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                  right: i == items.length - 1 ? 0 : 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors:
                                        [
                                              widget.colorFor(items[i].name, i),
                                              _darker(
                                                widget.colorFor(
                                                  items[i].name,
                                                  i,
                                                ),
                                              ),
                                            ]
                                            .map(
                                              (col) => col.withValues(
                                                alpha:
                                                    active == null ||
                                                        active == items[i].name
                                                    ? 1
                                                    : 0.25,
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('0%', style: TextStyle(color: c.subText, fontSize: 10)),
            const Spacer(),
            Text('100%', style: TextStyle(color: c.subText, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _row(AnalyticsPalette c, int i, NameValue it, int total) {
    final color = widget.colorFor(it.name, i);
    final isActive = _active == it.name;
    final dimmed = _active != null && !isActive;
    final share = total == 0 ? 0.0 : it.value / total * 100;

    return MouseRegion(
      key: ValueKey(it.name),
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(it.name),
      onExit: (_) => _setHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggle(it.name),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.45 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: c.isDark ? 0.08 : 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Rank badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? color : color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
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
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    // Active par count dikhao
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
                              key: const ValueKey('count'),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_fmt.format(it.value)} of ${_fmt.format(total)}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('none')),
                    ),
                    _animatedPercent(
                      share,
                      duration: Duration(milliseconds: 700 + i * 90),
                      style: TextStyle(
                        color: color,
                        fontSize: widget.layout.bodyFont + 3.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                // Bar = share of 100%
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (share / 100).clamp(0.0, 1.0)),
                  duration: Duration(milliseconds: 700 + i * 90),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: isActive ? 10 : 8,
                    decoration: BoxDecoration(
                      color: c.text.withValues(alpha: c.isDark ? 0.07 : 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: v,
                      heightFactor: 1,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_darker(color, 0.1), color],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
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
