// ============================================================
// SMART INSIGHT CARD
// One suggestion at a time. Dots / "Next" below, or swipe with a finger.
// ============================================================

import 'package:flutter/material.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../models/seo_insight.dart';
import 'seo_common.dart';

class SeoInsightCard extends StatefulWidget {
  const SeoInsightCard({super.key, required this.insights});

  final List<SeoInsight> insights;

  @override
  State<SeoInsightCard> createState() => _SeoInsightCardState();
}

class _SeoInsightCardState extends State<SeoInsightCard> {
  int _index = 0;

  @override
  void didUpdateWidget(SeoInsightCard old) {
    super.didUpdateWidget(old);
    if (old.insights.length != widget.insights.length) _index = 0;
  }

  void _go(int i) {
    final n = widget.insights.length;
    setState(() => _index = (i + n) % n);
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final list = widget.insights;
    if (list.isEmpty) return const SizedBox.shrink();

    final insight = list[_index.clamp(0, list.length - 1)];
    final look = _look(insight);

    return GestureDetector(
      // Swipe: left = agla, right = pichhla
      onHorizontalDragEnd: list.length < 2
          ? null
          : (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -150) _go(_index + 1);
              if (v > 150) _go(_index - 1);
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: look.color.withValues(alpha: .35)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              look.color.withValues(alpha: p.isDark ? .16 : .09),
              p.card,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(.05, 0),
                    end: Offset.zero,
                  ).animate(a),
                  child: child,
                ),
              ),
              child: Row(
                key: ValueKey(_index),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SeoHeaderIcon(
                    icon: look.icon,
                    colors: [look.color, SeoColors.teal],
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SeoTag(
                          text: look.chip.toUpperCase(),
                          color: look.color,
                          icon: Icons.auto_awesome,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          look.title,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _body(insight, p),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (list.length > 1) ...[
              const SizedBox(height: 12),
              Divider(color: p.border, height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < list.length; i++)
                    GestureDetector(
                      onTap: () => _go(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _index ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _index ? look.color : p.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: look.color),
                    onPressed: () => _go(_index + 1),
                    icon: const Text('Next'),
                    label: const Icon(Icons.arrow_forward, size: 16),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _body(SeoInsight insight, SettingPalette p) {
    final k = insight.keyword;
    final base = TextStyle(color: p.subText, fontSize: 13, height: 1.45);
    final bold = TextStyle(color: p.text, fontWeight: FontWeight.w700);

    final spans = switch (insight.type) {
      SeoInsightType.mapsGap => [
        TextSpan(text: '"${k.keyword}"', style: bold),
        const TextSpan(text: ' gets about '),
        TextSpan(text: SeoFormat.number(k.searchVolume), style: bold),
        const TextSpan(
          text: " searches/month locally, but you're not in the 3-pack.",
        ),
      ],
      SeoInsightType.almostThere => [
        const TextSpan(text: 'You rank '),
        TextSpan(text: SeoFormat.rank(k.liveOrganicRank), style: bold),
        const TextSpan(text: ' organically for '),
        TextSpan(text: '"${k.keyword}"', style: bold),
        const TextSpan(
          text: '. A few quality links could move you into the top spots.',
        ),
      ],
      SeoInsightType.defend => [
        const TextSpan(text: 'You hold '),
        TextSpan(text: SeoFormat.rank(k.liveGmbRank), style: bold),
        const TextSpan(text: ' on Maps for '),
        TextSpan(text: '"${k.keyword}"', style: bold),
        const TextSpan(text: '. Keep reviews flowing.'),
      ],
    };

    return Text.rich(TextSpan(style: base, children: spans));
  }

  ({IconData icon, String chip, String title, Color color}) _look(
    SeoInsight insight,
  ) => switch (insight.type) {
    SeoInsightType.mapsGap => (
      icon: Icons.location_searching,
      chip: 'Local opportunity',
      title: "You're missing the Map Pack",
      color: SeoColors.emerald,
    ),
    SeoInsightType.almostThere => (
      icon: Icons.rocket_launch_outlined,
      chip: 'Almost there',
      title: 'One push from the top 3',
      color: SeoColors.teal,
    ),
    SeoInsightType.defend => (
      icon: Icons.shield_outlined,
      chip: 'Defend',
      title: 'Protect your Map Pack spot',
      color: SeoColors.amber,
    ),
  };
}
