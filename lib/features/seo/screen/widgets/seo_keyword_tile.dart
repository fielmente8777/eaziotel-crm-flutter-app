// ============================================================
// SEO KEYWORD TILE
//
//   SeoKeywordHeader : tablet / window par table ki heading
//   SeoKeywordTile   : ek keyword
//       phone  -> card (keyword + rank upar, baaki neeche)
//       wide   -> table ki line
//       Local SEO me tap karne par detail khulti hai
//       (rank trend, next move, competitor)
// ============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../models/seo_intelligence_response.dart';
import 'seo_charts.dart';
import 'seo_common.dart';

/// Local SEO = Maps rank, Website SEO = Google search rank
enum SeoKeywordKind { local, website }

class SeoKeywordHeader extends StatelessWidget {
  const SeoKeywordHeader({super.key, required this.kind});

  final SeoKeywordKind kind;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final style = TextStyle(
      color: p.subText,
      fontSize: 10.5,
      letterSpacing: .6,
      fontWeight: FontWeight.w700,
    );
    final local = kind == SeoKeywordKind.local;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Row(
        children: [
          if (local) const SizedBox(width: 30),
          Expanded(flex: 4, child: Text('KEYWORD', style: style)),
          Expanded(
            flex: 2,
            child: Text(
              local ? 'VOLUME (LOCAL)' : 'SEARCH VOLUME',
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('CPC', textAlign: TextAlign.right, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(
              local ? 'MAPS' : 'POSITION',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(flex: 2, child: Text('DIFFICULTY', style: style)),
          if (local) Expanded(flex: 2, child: Text('ACTION', style: style)),
          const SizedBox(width: 84),
        ],
      ),
    );
  }
}

class SeoKeywordTile extends StatelessWidget {
  const SeoKeywordTile({
    super.key,
    required this.keyword,
    required this.kind,
    required this.wide,
    required this.color,
    required this.refreshCost,
    required this.refreshing,
    required this.busy,
    required this.onRefresh,
    required this.onDelete,
    this.error,
    this.expanded = false,
    this.onToggle,
  });

  final SeoKeyword keyword;
  final SeoKeywordKind kind;
  final bool wide;
  final Color color;
  final int refreshCost;

  /// Is keyword ka refresh chal raha hai
  final bool refreshing;

  /// Koi aur refresh chal raha hai (button band)
  final bool busy;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final String? error;

  final bool expanded;
  final VoidCallback? onToggle;

  bool get _local => kind == SeoKeywordKind.local;

  double? get _rank => _local ? keyword.liveGmbRank : keyword.liveOrganicRank;

  SeoRankTone get _tone =>
      _local ? SeoRankTone.maps(_rank) : SeoRankTone.organic(_rank);

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: expanded ? color.withValues(alpha: .05) : p.inner,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expanded ? color.withValues(alpha: .4) : p.border,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: wide ? _wideRow(p) : _phoneCard(p),
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 14,
                    color: SeoColors.rose,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(
                        color: SeoColors.rose,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: expanded && _local
                ? _KeywordDetail(keyword: keyword, wide: wide)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  // ---------- Tablet / window: table ki line ----------

  Widget _wideRow(SettingPalette p) {
    final number = TextStyle(
      color: p.text,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    );

    return Row(
      children: [
        if (_local) _chevron(p),
        Expanded(
          flex: 4,
          child: Text(
            keyword.keyword,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: p.text, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            SeoFormat.number(keyword.searchVolume),
            textAlign: TextAlign.right,
            style: number,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            SeoFormat.money(keyword.cpc),
            textAlign: TextAlign.right,
            style: number.copyWith(color: p.subText),
          ),
        ),
        Expanded(flex: 2, child: Center(child: _rankChip())),
        Expanded(
          flex: 2,
          child: SeoDifficulty(value: keyword.keywordDifficulty, width: 48),
        ),
        if (_local)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SeoActionBadge(type: keyword.actionBadge),
            ),
          ),
        _actions(p),
      ],
    );
  }

  // ---------- Phone: card ----------

  Widget _phoneCard(SettingPalette p) {
    Widget stat(String label, Widget value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: p.subText, fontSize: 10.5)),
        const SizedBox(height: 3),
        value,
      ],
    );

    final valueStyle = TextStyle(
      color: p.text,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (_local) _chevron(p),
            Expanded(
              child: Text(
                keyword.keyword,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _rankChip(large: true),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Wrap(
                spacing: 18,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  stat(
                    _local ? 'Volume' : 'Search volume',
                    Text(
                      SeoFormat.number(keyword.searchVolume),
                      style: valueStyle,
                    ),
                  ),
                  stat(
                    'CPC',
                    Text(SeoFormat.money(keyword.cpc), style: valueStyle),
                  ),
                  stat(
                    'Difficulty',
                    SeoDifficulty(value: keyword.keywordDifficulty, width: 44),
                  ),
                  if (_local) SeoActionBadge(type: keyword.actionBadge),
                ],
              ),
            ),
            _actions(p),
          ],
        ),
      ],
    );
  }

  Widget _chevron(SettingPalette p) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: AnimatedRotation(
      turns: expanded ? .5 : 0,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        Icons.keyboard_arrow_down,
        color: expanded ? color : p.subText,
      ),
    ),
  );

  Widget _rankChip({bool large = false}) => SeoRankChip(
    rank: _rank,
    tone: _tone,
    large: large,
    icon: _local ? Icons.location_on_outlined : Icons.public,
  );

  Widget _actions(SettingPalette p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Refresh rank ($refreshCost credits)',
          visualDensity: VisualDensity.compact,
          onPressed: busy ? null : onRefresh,
          icon: SeoSpin(
            spinning: refreshing,
            child: Icon(
              Icons.refresh,
              color: busy && !refreshing ? p.border : color,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Stop tracking',
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, color: p.subText),
        ),
      ],
    );
  }
}

// ============================================================
// LOCAL SEO: keyword ki detail
// ============================================================

class _KeywordDetail extends StatelessWidget {
  const _KeywordDetail({required this.keyword, required this.wide});

  final SeoKeyword keyword;
  final bool wide;

  /// Web jaisa: badge ke hisaab se agla kadam
  String get _tip => switch (keyword.actionBadge) {
    'DEFEND' =>
      'Hold position: keep your Google Business Profile fresh — new photos, posts and review replies every week.',
    'OPTIMIZE' =>
      'Tighten on-page targeting and earn 2–3 local citations to climb into the 3-pack.',
    'TARGET' =>
      'Strong opportunity: build a dedicated page and a Google Business Profile service entry for this term.',
    _ => 'Validate intent and volume before investing — low priority for now.',
  };

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final tone = SeoRankTone.maps(keyword.liveGmbRank);
    final history = keyword.rankHistory.length > 14
        ? keyword.rankHistory.sublist(keyword.rankHistory.length - 14)
        : keyword.rankHistory;

    Widget box({required Widget child}) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: child,
    );

    Widget heading(IconData icon, String text, Color color) => Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: p.subText,
            fontSize: 11,
            letterSpacing: .6,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    final rankBox = box(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tone.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on_outlined, color: tone.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAPS / GMB RANK',
                  style: TextStyle(
                    color: p.subText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  SeoFormat.rank(keyword.liveGmbRank),
                  style: TextStyle(
                    color: tone.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          SeoTag(text: tone.label, color: tone.color),
        ],
      ),
    );

    final trendBox = box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading(Icons.show_chart, 'RANK TREND', SeoColors.teal),
          const SizedBox(height: 10),
          if (history.length > 1)
            SeoRankChart(
              compact: true,
              height: 120,
              color: SeoColors.teal,
              name: 'Rank',
              points: [for (final s in history) SeoRankPoint(s.label, s.rank!)],
            )
          else
            SizedBox(
              height: 70,
              child: Center(
                child: Text(
                  'Trend builds as daily snapshots accumulate.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.subText, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );

    final nextBox = box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading(Icons.bolt, 'NEXT MOVE', SeoColors.amber),
          const SizedBox(height: 8),
          Text(
            _tip,
            style: TextStyle(color: p.text, fontSize: 13, height: 1.4),
          ),
          if (keyword.topCompetitor.isNotEmpty) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: seoOutlineButton(context),
              onPressed: () => launchUrl(
                Uri.parse('https://${keyword.topCompetitor}'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(
                Icons.emoji_events_outlined,
                size: 16,
                color: SeoColors.amber,
              ),
              label: Text(
                'Watch ${keyword.topCompetitor}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: wide
          ? Column(
              children: [
                rankBox,
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: trendBox),
                      const SizedBox(width: 10),
                      Expanded(child: nextBox),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                rankBox,
                const SizedBox(height: 10),
                trendBox,
                const SizedBox(height: 10),
                nextBox,
              ],
            ),
    );
  }
}
