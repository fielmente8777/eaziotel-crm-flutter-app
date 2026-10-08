// lib/features/googleAnalytis/screen/widgets/top_events_card.dart

 import 'package:eazotel/features/googleAnalytis/models/Conversions%20model.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/AnalyticsUiKit.dart' show analyticsLoader;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _EventMode { count, users }

class TopEventsCard extends StatefulWidget {
  final List<EventItem> events;
  final AnalyticsLayout layout;
  final bool isLoading;

  const TopEventsCard({
    super.key,
    required this.events,
    required this.layout,
    this.isLoading = false,
  });

  @override
  State<TopEventsCard> createState() => _TopEventsCardState();
}

class _TopEventsCardState extends State<TopEventsCard> {
  static const _orange = Color(0xFFFF8A00);

  _EventMode _mode = _EventMode.count;
  String? _selected; // tap (mobile)
  String? _hover; // hover (desktop)

  String? get _active => _hover ?? _selected;

  final _fmt = NumberFormat.decimalPattern();

  @override
  void didUpdateWidget(covariant TopEventsCard old) {
    super.didUpdateWidget(old);
    if (old.events != widget.events) {
      _selected = null;
      _hover = null;
    }
  }

  int _valueOf(EventItem e) =>
      _mode == _EventMode.count ? e.eventCount : e.users;

  void _setHover(String? n) {
    if (_hover == n) return;
    setState(() => _hover = n);
  }

  void _toggle(String n) =>
      setState(() => _selected = _selected == n ? null : n);

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final l = widget.layout;

    final events = [...widget.events]
      ..sort((a, b) => _valueOf(b).compareTo(_valueOf(a)));
    final maxV = events.isEmpty ? 0 : _valueOf(events.first);
    final totalCount = events.fold<int>(0, (s, e) => s + e.eventCount);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(l.isPhone ? 14 : 22),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(l.radius),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(c),
          SizedBox(height: l.isPhone ? 14 : 20),
          if (widget.isLoading)
            analyticsLoader()
          else if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No events', style: TextStyle(color: c.subText)),
              ),
            )
          else
            for (int i = 0; i < events.length; i++)
              _row(c, i, events[i], maxV, totalCount),
        ],
      ),
    );
  }

  // ======================= HEADER =======================
  Widget _header(AnalyticsPalette c) {
    final l = widget.layout;
    return Row(
      children: [
        Container(
          width: l.isPhone ? 36 : 44,
          height: l.isPhone ? 36 : 44,
          decoration: BoxDecoration(
            color: c.isDark
                ? const Color(0xFFFFF4E8)
                : _orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.bolt_outlined,
              color: _orange, size: l.isPhone ? 18 : 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Events',
                style: TextStyle(
                  color: c.text,
                  fontSize: l.isPhone ? 15 : 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _mode == _EventMode.count
                    ? 'Most triggered events'
                    : 'Events by unique users',
                style: TextStyle(color: c.subText, fontSize: l.bodyFont),
              ),
            ],
          ),
        ),
        _modeToggle(c),
      ],
    );
  }

  Widget _modeToggle(AnalyticsPalette c) {
    Widget seg(_EventMode m, String label) {
      final sel = _mode == m;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _mode = m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: sel ? _orange.withValues(alpha: 0.16) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: sel ? _orange : c.subText,
                fontSize: 11.5,
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
          seg(_EventMode.count, 'Count'),
          seg(_EventMode.users, 'Users'),
        ],
      ),
    );
  }

  // ======================= ROW =======================
  Widget _row(
    AnalyticsPalette c,
    int i,
    EventItem e,
    int maxV,
    int totalCount,
  ) {
    final active = _active;
    final isActive = active == e.eventName;
    final dimmed = active != null && !isActive;
    final ratio = maxV == 0 ? 0.0 : _valueOf(e) / maxV;

    final nameColor = isActive
        ? _orange
        : (c.isDark ? const Color(0xFF8AA4D6) : const Color(0xFF3B5B9A));

    return MouseRegion(
      key: ValueKey(e.eventName),
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(e.eventName),
      onExit: (_) => _setHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggle(e.eventName),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.45 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_iconFor(e.eventName),
                        size: 15, color: nameColor.withValues(alpha: 0.85)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.eventName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: nameColor,
                          fontSize: widget.layout.bodyFont + 2,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _fmt.format(_valueOf(e)),
                        key: ValueKey('${e.eventName}-$_mode'),
                        style: TextStyle(
                          color: c.text.withValues(alpha: 0.85),
                          fontSize: widget.layout.bodyFont + 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                _bar(c, ratio, i, isActive),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: isActive
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _pill(c, Icons.bolt, 'Events',
                                  _fmt.format(e.eventCount)),
                              _pill(c, Icons.people_outline, 'Users',
                                  _fmt.format(e.users)),
                              _pill(c, Icons.repeat, 'Per user',
                                  e.perUser.toStringAsFixed(1)),
                              _pill(
                                c,
                                Icons.pie_chart_outline,
                                'Share',
                                totalCount == 0
                                    ? '0%'
                                    : '${(e.eventCount / totalCount * 100).toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Load par 0 se fill hota hai, toggle par smoothly naye ratio tak jaata hai
  Widget _bar(AnalyticsPalette c, double ratio, int i, bool isActive) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
      duration: Duration(milliseconds: 650 + i * 90),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isActive ? 10 : 8,
        decoration: BoxDecoration(
          color: c.isDark
              ? Colors.white.withValues(alpha: 0.92)
              : const Color(0xFFEDEFF3),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          heightFactor: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7A00), Color(0xFFFFA23A)],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _orange.withValues(alpha: 0.45),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(AnalyticsPalette c, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: c.isDark ? 0.10 : 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _orange),
          const SizedBox(width: 5),
          Text('$label ',
              style: TextStyle(color: c.subText, fontSize: 11.5)),
          Text(value,
              style: TextStyle(
                  color: c.text, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'page_view':
        return Icons.visibility_outlined;
      case 'session_start':
        return Icons.play_circle_outline;
      case 'scroll':
        return Icons.swap_vert;
      case 'first_visit':
        return Icons.person_add_alt_1_outlined;
      case 'user_engagement':
        return Icons.touch_app_outlined;
      case 'click':
        return Icons.ads_click;
      case 'form_submit':
      case 'form_start':
      case 'generate_lead':
        return Icons.assignment_outlined;
      case 'file_download':
        return Icons.download_outlined;
      case 'video_start':
      case 'video_progress':
      case 'video_complete':
        return Icons.play_arrow_outlined;
      default:
        return Icons.bolt_outlined;
    }
  }
}