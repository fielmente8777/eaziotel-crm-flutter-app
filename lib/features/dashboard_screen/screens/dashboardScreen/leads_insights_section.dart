// lib/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/leads_insights_section.dart
//
// Usage (koi param nahi):
//   const SliverToBoxAdapter(child: LeadsInsightsSection()),
//
// Data: DashboardController.analyticsResponse -> result.docs
//   sourceBreakdown  -> "Source distribution"
//   statusBreakdown  -> "Stages breakdown"

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ===================================================================
// DATA HELPERS
// ===================================================================

class _Slice {
  final String key;
  final String label;
  final int count;
  final Color color;
  final IconData? icon;

  const _Slice({
    required this.key,
    required this.label,
    required this.count,
    required this.color,
    this.icon,
  });
}

const _fallback = [
  Color(0xFF6366F1),
  Color(0xFF06B6D4),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
  Color(0xFF8B5CF6),
  Color(0xFF84CC16),
  Color(0xFF14B8A6),
  Color(0xFFF97316),
];

const _grey = Color(0xFF6B7280);

Color _darker(Color c, [double t = 0.2]) => Color.lerp(c, Colors.black, t)!;

String _titleCase(String s) => s
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

String _pct(int part, int total, {int digits = 0}) =>
    total == 0 ? '0%' : '${(part / total * 100).toStringAsFixed(digits)}%';

// ---------- Sources ----------
_Slice _sourceSlice(String? rawId, int count, int i) {
  final id = (rawId ?? '').trim().toLowerCase();
  switch (id) {
    case 'webform':
      return _Slice(
        key: id,
        label: 'Webform',
        count: count,
        color: const Color(0xFF3B82F6),
        icon: Icons.language,
      );
    case 'whatsapp':
      return _Slice(
        key: id,
        label: 'WhatsApp',
        count: count,
        color: const Color(0xFF22C55E),
        icon: Icons.chat_outlined,
      );
    case 'eazbot':
      return _Slice(
        key: id,
        label: 'Eazbot',
        count: count,
        color: const Color(0xFFF97316),
        icon: Icons.smart_toy_outlined,
      );
    case '':
      return _Slice(
        key: '__none',
        label: 'Unknown',
        count: count,
        color: _grey,
        icon: Icons.help_outline,
      );
    default:
      return _Slice(
        key: id,
        label: _titleCase(id),
        count: count,
        color: _fallback[i % _fallback.length],
        icon: Icons.input,
      );
  }
}

// ---------- Stages ----------
Color _stageColor(String id, int i) {
  switch (id) {
    case 'open':
      return const Color.fromARGB(255, 183, 184, 202);
    case 'hot':
      return const Color(0xFFEF4444);
    case 'potential':
      return const Color(0xFF3B82F6);
    case 'follow up':
      return const Color(0xFFF59E0B);
    case 'quotation provided':
      return const Color(0xFF06B6D4);
    case 'converted':
      return const Color(0xFF22C55E);
    case 'closure':
      return const Color(0xFF10B981);
    case 'lost':
      return const Color(0xFFF43F5E);
    case 'out of budget':
      return const Color(0xFFA855F7);
    case 'turn away':
      return const Color(0xFFEC4899);
    case 'not qualified':
      return const Color(0xFF94A3B8);
    case '':
      return _grey;
    default:
      return _fallback[i % _fallback.length];
  }
}

enum _Group { active, won, lost, none }

_Group _groupOf(String id) {
  switch (id) {
    case 'converted':
    case 'closure':
      return _Group.won;
    case 'lost':
    case 'out of budget':
    case 'turn away':
    case 'not qualified':
      return _Group.lost;
    case '':
      return _Group.none;
    default:
      return _Group.active; // open, hot, potential, follow up, quotation...
  }
}

const _groupMeta = {
  _Group.active: ('Active pipeline', Color(0xFF6366F1), Icons.trending_up),
  _Group.won: ('Won', Color(0xFF22C55E), Icons.emoji_events_outlined),
  _Group.lost: ('Lost', Color(0xFFF43F5E), Icons.block_outlined),
  _Group.none: ('No status', _grey, Icons.help_outline),
};

// ===================================================================
// SECTION (no params)
// ===================================================================

class LeadsInsightsSection extends StatelessWidget {
  const LeadsInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final docs = controller.analyticsResponse.value?.result?.docs;
      final loading = controller.analyticsResponse.value == null;

      // ---------- sources ----------
      final rawSources = docs?.sourceBreakdown ?? const [];
      final sources = <_Slice>[
        for (int i = 0; i < rawSources.length; i++)
          if ((rawSources[i].count ?? 0) > 0)
            _sourceSlice(rawSources[i].id, rawSources[i].count ?? 0, i),
      ]..sort((a, b) => b.count.compareTo(a.count));

      // ---------- stages ----------
      final rawStages = docs?.statusBreakdown ?? const [];
      final stageIds = <String>[];
      final stages = <_Slice>[];
      for (int i = 0; i < rawStages.length; i++) {
        final count = rawStages[i].count ?? 0;
        if (count <= 0) continue;
        final id = (rawStages[i].id ?? '').trim().toLowerCase();
        stageIds.add(id);
        stages.add(
          _Slice(
            key: id.isEmpty ? '__none' : id,
            label: id.isEmpty ? 'No status' : _titleCase(id),
            count: count,
            color: _stageColor(id, i),
          ),
        );
      }

      // groups (Active / Won / Lost / No status)
      final groupCounts = <_Group, int>{};
      for (int i = 0; i < stages.length; i++) {
        final g = _groupOf(stageIds[i]);
        groupCounts[g] = (groupCounts[g] ?? 0) + stages[i].count;
      }
      final groups = [
        for (final g in _Group.values)
          if ((groupCounts[g] ?? 0) > 0)
            _Slice(
              key: g.name,
              label: _groupMeta[g]!.$1,
              count: groupCounts[g]!,
              color: _groupMeta[g]!.$2,
              icon: _groupMeta[g]!.$3,
            ),
      ];
      stages.sort((a, b) => b.count.compareTo(a.count));

      final won = groupCounts[_Group.won] ?? 0;
      final lost = groupCounts[_Group.lost] ?? 0;

      final sourceCard = _SourceDistributionCard(
        sources: sources,
        loading: loading,
      );
      final stageCard = _StagesBreakdownCard(
        stages: stages,
        groups: groups,
        winRate: (won + lost) == 0 ? null : won / (won + lost) * 100,
        loading: loading,
      );

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 440),
                      child: sourceCard,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 6,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 440),
                      child: stageCard,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [sourceCard, const SizedBox(height: 12), stageCard],
            );
          },
        ),
      );
    });
  }
}

// ===================================================================
// SHARED CARD SHELL
// ===================================================================

class _Card extends StatelessWidget {
  final String overline;
  final String title;
  final Color accent;
  final Widget? trailing;
  final Widget child;

  const _Card({
    required this.overline,
    required this.title,
    required this.accent,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final phone = MediaQuery.sizeOf(context).width < 600;
    final pad = phone ? 16.0 : 24.0;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.4],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overline,
                            style: TextStyle(
                              color: c.subText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: TextStyle(
                              color: c.text,
                              fontSize: phone ? 18 : 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                SizedBox(height: phone ? 16 : 22),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _loader() => const Padding(
  padding: EdgeInsets.symmetric(vertical: 48),
  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
);

Widget _empty(AnalyticsPalette c, String msg) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 40),
  child: Center(
    child: Column(
      children: [
        Icon(Icons.insights_outlined, color: c.subText, size: 28),
        const SizedBox(height: 8),
        Text(msg, style: TextStyle(color: c.subText)),
      ],
    ),
  ),
);

Widget _segmented<T>({
  required AnalyticsPalette c,
  required Color accent,
  required T value,
  required Map<T, String> options,
  required ValueChanged<T> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: c.text.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: c.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in options.entries)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: value == e.key
                      ? accent.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: value == e.key ? accent : c.subText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// ===================================================================
// SOURCE DISTRIBUTION
// ===================================================================

class _SourceDistributionCard extends StatefulWidget {
  final List<_Slice> sources;
  final bool loading;

  const _SourceDistributionCard({required this.sources, required this.loading});

  @override
  State<_SourceDistributionCard> createState() =>
      _SourceDistributionCardState();
}

class _SourceDistributionCardState extends State<_SourceDistributionCard> {
  static const _accent = Color(0xFF3B82F6);

  String? _hover;
  String? _selected;
  String? get _active => _hover ?? _selected;

  void _setHover(String? k) {
    if (_hover == k) return;
    setState(() => _hover = k);
  }

  void _toggle(String k) =>
      setState(() => _selected = _selected == k ? null : k);

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final sources = widget.sources;
    final total = sources.fold<int>(0, (s, e) => s + e.count);

    return _Card(
      overline: 'OVERVIEW',
      title: 'Source distribution',
      accent: _accent,
      trailing: total == 0 ? null : _totalChip(c, total),
      child: widget.loading
          ? _loader()
          : total == 0
          ? _empty(c, 'No leads yet')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _strip(c, total),
                const SizedBox(height: 18),
                for (int i = 0; i < sources.length; i++)
                  _row(c, i, sources[i], total),
                const SizedBox(height: 14),
                _insight(c, sources.first, total),
              ],
            ),
    );
  }

  Widget _totalChip(AnalyticsPalette c, int total) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: _accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$total leads',
      style: const TextStyle(
        color: _accent,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  /// 100% stacked strip
  Widget _strip(AnalyticsPalette c, int total) {
    final active = _active;
    return TweenAnimationBuilder<double>(
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
              for (int i = 0; i < widget.sources.length; i++)
                Flexible(
                  flex: widget.sources[i].count,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => _setHover(widget.sources[i].key),
                    onExit: (_) => _setHover(null),
                    child: GestureDetector(
                      onTap: () => _toggle(widget.sources[i].key),
                      child: Tooltip(
                        message:
                            '${widget.sources[i].label} · ${_pct(widget.sources[i].count, total, digits: 1)}',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: i == widget.sources.length - 1 ? 0 : 2,
                          ),
                          color: widget.sources[i].color.withValues(
                            alpha:
                                active == null ||
                                    active == widget.sources[i].key
                                ? 1
                                : 0.25,
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
    );
  }

  Widget _row(AnalyticsPalette c, int i, _Slice s, int total) {
    final isActive = _active == s.key;
    final dimmed = _active != null && !isActive;
    final ratio = total == 0 ? 0.0 : s.count / total;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(s.key),
      onExit: (_) => _setHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggle(s.key),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.45 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? s.color.withValues(alpha: c.isDark ? 0.09 : 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? s.color.withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                // Rank badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? s.color : s.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: s.color.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : s.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(s.icon, size: 15, color: s.color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.text,
                                fontSize: 14.5,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: s.count.toDouble()),
                            duration: Duration(milliseconds: 700 + i * 100),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => Text(
                              '${v.round()}',
                              style: TextStyle(
                                color: c.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 40,
                            child: Text(
                              _pct(s.count, total),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: isActive ? s.color : c.subText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio),
                        duration: Duration(milliseconds: 750 + i * 110),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: isActive ? 10 : 8,
                          decoration: BoxDecoration(
                            color: c.text.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: v,
                            heightFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_darker(s.color, 0.15), s.color],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: s.color.withValues(alpha: 0.5),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _insight(AnalyticsPalette c, _Slice top, int total) {
    final s = _active == null
        ? top
        : widget.sources.firstWhere((e) => e.key == _active, orElse: () => top);
    final isTop = s.key == top.key;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey(s.key),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: s.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: s.color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(
              isTop ? Icons.auto_awesome : Icons.insights_outlined,
              size: 18,
              color: s.color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: c.subText,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: s.label,
                      style: TextStyle(
                        color: s.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: isTop ? ' is your top source — ' : ' brings ',
                    ),
                    TextSpan(
                      text: '${s.count} of $total leads',
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' (${_pct(s.count, total, digits: 1)})'),
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

// ===================================================================
// STAGES BREAKDOWN
// ===================================================================

enum _StageView { stages, groups }

class _StagesBreakdownCard extends StatefulWidget {
  final List<_Slice> stages;
  final List<_Slice> groups;
  final double? winRate;
  final bool loading;

  const _StagesBreakdownCard({
    required this.stages,
    required this.groups,
    required this.winRate,
    required this.loading,
  });

  @override
  State<_StagesBreakdownCard> createState() => _StagesBreakdownCardState();
}

class _StagesBreakdownCardState extends State<_StagesBreakdownCard> {
  static const _accent = Color(0xFF6366F1);

  _StageView _view = _StageView.stages;
  String? _hover;
  String? _selected;
  String? get _active => _hover ?? _selected;

  List<_Slice> get _slices =>
      _view == _StageView.stages ? widget.stages : widget.groups;

  void _setHover(String? k) {
    if (_hover == k) return;
    setState(() => _hover = k);
  }

  void _toggle(String k) =>
      setState(() => _selected = _selected == k ? null : k);

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final slices = _slices;
    final total = slices.fold<int>(0, (s, e) => s + e.count);

    return _Card(
      overline: 'PIPELINE',
      title: 'Stages breakdown',
      accent: _accent,
      trailing: total == 0
          ? null
          : _segmented<_StageView>(
              c: c,
              accent: _accent,
              value: _view,
              options: const {
                _StageView.stages: 'Stages',
                _StageView.groups: 'Groups',
              },
              onChanged: (v) => setState(() {
                _view = v;
                _hover = null;
                _selected = null;
              }),
            ),
      child: widget.loading
          ? _loader()
          : total == 0
          ? _empty(c, 'No pipeline data')
          : LayoutBuilder(
              builder: (context, box) {
                final wide = box.maxWidth >= 520;
                final size = wide
                    ? (box.maxWidth * 0.38).clamp(190.0, 250.0).toDouble()
                    : (box.maxWidth * 0.68).clamp(180.0, 240.0).toDouble();

                final donut = _donut(c, slices, total, size);
                final legend = _legend(c, slices, total);

                final body = wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          donut,
                          const SizedBox(width: 24),
                          Expanded(child: legend),
                        ],
                      )
                    : Column(
                        children: [
                          Center(child: donut),
                          const SizedBox(height: 20),
                          legend,
                        ],
                      );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.winRate != null) ...[
                      _winRateChip(c),
                      const SizedBox(height: 14),
                    ],
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: KeyedSubtree(key: ValueKey(_view), child: body),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _winRateChip(AnalyticsPalette c) {
    const green = Color(0xFF22C55E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 14, color: green),
          const SizedBox(width: 6),
          Text(
            'Win rate ${widget.winRate!.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: green,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '  of closed leads',
            style: TextStyle(color: c.subText, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _donut(
    AnalyticsPalette c,
    List<_Slice> slices,
    int total,
    double size,
  ) {
    final active = _active;
    final activeSlice = active == null
        ? null
        : slices.firstWhere((s) => s.key == active, orElse: () => slices.first);

    final base = size * 0.15;
    final grow = size * 0.19;
    final hole = size * 0.31;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size * 0.88,
            height: size * 0.88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (activeSlice?.color ?? _accent).withValues(
                    alpha: c.isDark ? 0.25 : 0.14,
                  ),
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
              sectionsSpace: 3,
              centerSpaceRadius: hole,
              borderData: FlBorderData(show: false),
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                    value: s.count.toDouble(),
                    radius: active == s.key ? grow : base,
                    showTitle: false,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [s.color, _darker(s.color)]
                          .map(
                            (col) => col.withValues(
                              alpha: active == null || active == s.key
                                  ? 1
                                  : 0.25,
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final idx = response?.touchedSection?.touchedSectionIndex;
                  final key = idx != null && idx >= 0 && idx < slices.length
                      ? slices[idx].key
                      : null;
                  if (event is FlTapUpEvent) {
                    key == null
                        ? setState(() => _selected = null)
                        : _toggle(key);
                  } else if (event is FlPointerHoverEvent) {
                    _setHover(key);
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
                  duration: const Duration(milliseconds: 220),
                  child: activeSlice == null
                      ? Column(
                          key: const ValueKey('total'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: total.toDouble()),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => Text(
                                '${v.round()}',
                                style: TextStyle(
                                  color: c.text,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            Text(
                              'TOTAL',
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
                          key: ValueKey(activeSlice.key),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _pct(activeSlice.count, total, digits: 1),
                              style: TextStyle(
                                color: activeSlice.color,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              activeSlice.label,
                              style: TextStyle(
                                color: c.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${activeSlice.count} leads',
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

  Widget _legend(AnalyticsPalette c, List<_Slice> slices, int total) {
    return Column(
      children: [
        for (int i = 0; i < slices.length; i++)
          _legendRow(c, i, slices[i], total),
      ],
    );
  }

  Widget _legendRow(AnalyticsPalette c, int i, _Slice s, int total) {
    final isActive = _active == s.key;
    final dimmed = _active != null && !isActive;
    final ratio = total == 0 ? 0.0 : s.count / total;
    final big = _view == _StageView.groups;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(s.key),
      onExit: (_) => _setHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggle(s.key),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.4 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 2),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive
                  ? s.color.withValues(alpha: c.isDark ? 0.10 : 0.07)
                  : Colors.transparent,
            ),
            child: Stack(
              children: [
                // Row ke peeche share ka halka fill
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: Duration(milliseconds: 700 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              s.color.withValues(alpha: isActive ? 0.22 : 0.10),
                              s.color.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: big ? 12 : 7,
                  ),
                  child: Row(
                    children: [
                      if (s.icon != null)
                        Icon(s.icon, size: 16, color: s.color)
                      else
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 13 : 11,
                          height: isActive ? 13 : 11,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: s.color.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: s.label == 'No status' ? c.subText : c.text,
                            fontSize: big ? 15 : 14,
                            fontStyle: s.label == 'No status'
                                ? FontStyle.italic
                                : FontStyle.normal,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${s.count}',
                        style: TextStyle(
                          color: c.text,
                          fontSize: big ? 16 : 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          _pct(s.count, total),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: isActive ? s.color : c.subText,
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
