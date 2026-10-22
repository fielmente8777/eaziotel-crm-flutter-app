// ============================================================
// LOCAL SEO SCREEN  (Drawer > SEO > Local Seo)
//
// Like "Local SEO Intelligence" in the web dashboard:
//   setup adhoora   -> 3 step setup
//   top             -> property, radius (2/5/10 km), grid keyword
//   visibility      -> round meter + how many keywords are in the Map 3-Pack
//   map coverage    -> 5x5 grid (tap = detail), Re-scan
//   insights, stat cards, rank trend, keywords (tap = detail)
//
// Phone: everything stacked, a round "Add keywords" button at the bottom.
// Tablet / window: visibility + map in one row, keywords like a table.
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/local_seo_controller.dart';
import 'local_seo_setup_view.dart';
import 'widgets/seo_add_keywords_sheet.dart';
import 'widgets/seo_charts.dart';
import 'widgets/seo_common.dart';
import 'widgets/seo_geo_grid.dart';
import 'widgets/seo_insight_card.dart';
import 'widgets/seo_keyword_tile.dart';

class LocalSeoScreen extends StatelessWidget {
  const LocalSeoScreen({super.key});

  static void openAddKeywords(BuildContext context, LocalSeoController c) {
    final config = c.config;
    final area = config?.district.isNotEmpty == true
        ? config!.district
        : 'your area';

    showSeoAddKeywords(
      context,
      title: 'Track new keywords',
      subtitle: 'Local volume for ${config?.area ?? 'your area'}',
      hint:
          'hotel in $area\n'
          'best hotel ${config?.city.isNotEmpty == true ? config!.city : 'your city'}\n'
          'budget hotel near me',
      color: SeoColors.emerald,
      perKeyword: c.pricing.localPerKeyword,
      balance: c.tokenBalance,
      saving: c.isSaving,
      error: c.addError,
      onAdd: c.addKeywords,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LocalSeoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local SEO'),
        actions: [
          Obx(
            () => SeoCreditsChip(
              balance: c.tokenBalance,
              pricing: c.pricing,
              lowAt: c.pricing.localPerKeyword,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: c.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        final ready =
            !c.isLoading.value && !c.loadFailed.value && !c.needsSetup;
        if (!ready || !TResponsive.of(context).isPhone) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          backgroundColor: SeoColors.emerald,
          foregroundColor: Colors.white,
          onPressed: () => openAddKeywords(context, c),
          icon: const Icon(Icons.add),
          label: const Text('Add keywords'),
        );
      }),
      body: SafeArea(
        child: TResponsiveBuilder(
          builder: (context, r) => Obx(() {
            if (c.isLoading.value && c.intelligenceResponse.value == null) {
              return ListView(
                padding: EdgeInsets.all(r.pagePadding),
                children: [SeoShimmer(columns: r.isPhone ? 2 : 4)],
              );
            }

            if (c.loadFailed.value) return SeoErrorState(onRetry: c.load);

            if (c.needsSetup) return LocalSeoSetupView(onDone: c.load);

            return _Dashboard(c: c, r: r);
          }),
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.c, required this.r});

  final LocalSeoController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final wide = !r.isPhone;
    final gap = SizedBox(height: r.isPhone ? 12 : 16);

    return RefreshIndicator(
      color: SeoColors.emerald,
      onRefresh: c.refreshAll,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          r.pagePadding,
          r.pagePadding,
          r.pagePadding,
          // So the content is not hidden under the FAB
          r.isPhone ? 96 : r.pagePadding,
        ),
        children: [
          _Header(c: c, wide: wide),
          gap,
          _Controls(c: c),
          if (c.data.staleKeywords > 0) ...[
            gap,
            _StaleBanner(count: c.data.staleKeywords),
          ],
          gap,
          if (r.isDesktop)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _Visibility(c: c, vertical: true)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _MapCoverage(c: c)),
                ],
              ),
            )
          else ...[
            _Visibility(c: c, vertical: false),
            gap,
            _MapCoverage(c: c),
          ],
          if (c.insights.isNotEmpty) ...[
            gap,
            SeoInsightCard(insights: c.insights),
          ],
          gap,
          SeoGrid(
            columns: r.isPhone ? 2 : 4,
            children: [
              SeoStatCard(
                icon: Icons.tag,
                label: 'Keywords tracked',
                value: SeoFormat.number(c.keywords.length),
                sub:
                    'in ${c.config?.city.isNotEmpty == true ? c.config!.city : 'your area'}',
                color: SeoColors.emerald,
              ),
              SeoStatCard(
                icon: Icons.location_on_outlined,
                label: 'In Map 3-Pack',
                value: SeoFormat.number(c.inPack),
                sub: 'top-3 on Maps',
                color: SeoColors.teal,
              ),
              SeoStatCard(
                icon: Icons.track_changes,
                label: 'Opportunities',
                value: SeoFormat.number(c.data.summary.opportunities),
                sub: 'gap terms to win',
                color: SeoColors.amber,
              ),
              SeoStatCard(
                icon: Icons.leaderboard_outlined,
                label: 'Avg Maps rank',
                value: SeoFormat.rank(c.avgMapsRank),
                sub: 'lower is better',
                color: SeoColors.indigo,
              ),
            ],
          ),
          gap,
          _Trend(c: c),
          gap,
          _Keywords(c: c, wide: wide),
        ],
      ),
    );
  }
}

// ============================================================
// HEADER + CONTROLS
// ============================================================

class _Header extends StatelessWidget {
  const _Header({required this.c, required this.wide});

  final LocalSeoController c;
  final bool wide;

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final p = SettingPalette(context);
    final config = c.config;

    return Row(
      children: [
        const SeoHeaderIcon(
          icon: Icons.location_on,
          colors: SeoColors.localGradient,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config?.businessName.isNotEmpty == true
                    ? config!.businessName
                    : 'Local SEO Intelligence',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    config?.area.isNotEmpty == true
                        ? config!.area
                        : 'Maps & organic command center',
                    style: const TextStyle(
                      color: SeoColors.emerald,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  SeoTag(
                    text: c.data.provider.toUpperCase(),
                    color: SeoColors.teal,
                    icon: Icons.auto_awesome,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (wide)
          ElevatedButton.icon(
            style: seoButton(SeoColors.emerald),
            onPressed: () => LocalSeoScreen.openAddKeywords(context, c),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add keywords'),
          ),
      ],
    );
  }
}

/// Radius chips + grid keyword dropdown
class _Controls extends StatelessWidget {
  const _Controls({required this.c});

  final LocalSeoController c;

  Future<void> _radius(int km) async {
    if (!await c.changeRadius(km)) {
      Get.snackbar(
        'Not saved',
        'Could not update radius.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _gridKeyword(String? kw) async {
    if (kw == null) return;
    if (await c.changeGridKeyword(kw)) {
      Get.snackbar(
        'Grid keyword updated',
        'Tap Re-scan to check "$kw" across your area.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Not saved',
        'Could not update grid keyword.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final p = SettingPalette(context);
    final radius = c.config?.radiusKm ?? 5;
    final names = c.keywords.map((k) => k.keyword).toSet().toList();
    final current = names.contains(c.gridMeta.keyword)
        ? c.gridMeta.keyword
        : null;

    final label = TextStyle(color: p.subText, fontSize: 12);

    return SeoPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Text('Radius', style: label),
              ),
              for (final km in LocalSeoController.radiusOptions)
                Padding(
                  padding: EdgeInsets.zero,
                  child: ChoiceChip(
                    label: Text('$km km'),
                    selected: radius == km,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    selectedColor: SeoColors.emerald.withValues(alpha: .18),
                    side: BorderSide(
                      color: radius == km ? SeoColors.emerald : p.border,
                    ),
                    labelStyle: TextStyle(
                      color: radius == km ? SeoColors.emerald : p.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    onSelected: (_) => _radius(km),
                  ),
                ),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Grid keyword', style: label),
                const SizedBox(width: 8),
                Flexible(
                  child: names.isEmpty
                      ? Text('— add keywords first —', style: label)
                      : DropdownButton<String>(
                          value: current,
                          hint: Text('— not set —', style: label),
                          isExpanded: true,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          dropdownColor: p.card,
                          style: const TextStyle(
                            color: SeoColors.emerald,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          items: [
                            for (final n in names)
                              DropdownMenuItem(
                                value: n,
                                child: Text(n, overflow: TextOverflow.ellipsis),
                              ),
                          ],
                          onChanged: _gridKeyword,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SeoColors.amber.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SeoColors.amber.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: SeoColors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data may be slightly stale — use the refresh button on each '
              'keyword to update rankings ($count keyword'
              '${count == 1 ? '' : 's'} outdated).',
              style: TextStyle(color: p.text, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VISIBILITY + MAP COVERAGE
// ============================================================

class _Visibility extends StatelessWidget {
  const _Visibility({required this.c, required this.vertical});

  final LocalSeoController c;

  /// On a window the gauge on top, the text below
  final bool vertical;

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final p = SettingPalette(context);
    final district = c.config?.district ?? '';

    final text = Column(
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          (district.isNotEmpty ? '$district visibility' : 'Local visibility')
              .toUpperCase(),
          textAlign: vertical ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: p.subText,
            fontSize: 10.5,
            letterSpacing: .6,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            style: TextStyle(color: p.subText, fontSize: 13.5, height: 1.4),
            children: [
              TextSpan(
                text: '${c.inPack}',
                style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
              ),
              const TextSpan(text: ' of '),
              TextSpan(
                text: '${c.keywords.length}',
                style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
              ),
              const TextSpan(text: ' tracked terms in the Map 3-Pack.'),
            ],
          ),
          textAlign: vertical ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 10),
        SeoTag(
          text: 'Avg Maps ${SeoFormat.rank(c.avgMapsRank)}',
          color: SeoColors.emerald,
          icon: Icons.location_on_outlined,
        ),
      ],
    );

    return SeoPanel(
      child: vertical
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SeoVisibilityGauge(score: c.visibility, size: 150),
                const SizedBox(height: 16),
                text,
              ],
            )
          : Row(
              children: [
                SeoVisibilityGauge(score: c.visibility, size: 118),
                const SizedBox(width: 16),
                Expanded(child: text),
              ],
            ),
    );
  }
}

class _MapCoverage extends StatelessWidget {
  const _MapCoverage({required this.c});

  final LocalSeoController c;

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final config = c.config;
    final meta = c.gridMeta;
    final scanning = c.isGridScanning;
    final triggering = c.isTriggeringScan.value;

    final status = scanning
        ? const SeoTag(text: 'Scanning…', color: SeoColors.amber, loading: true)
        : meta.status == 'done'
        ? const SeoTag(
            text: 'Updated',
            color: SeoColors.emerald,
            icon: Icons.check_circle_outline,
          )
        : meta.status == 'failed'
        ? const SeoTag(
            text: 'Failed',
            color: SeoColors.rose,
            icon: Icons.error_outline,
          )
        : null;

    return SeoPanel(
      icon: Icons.map_outlined,
      title:
          'Map Coverage — ${config?.district.isNotEmpty == true ? config!.district : 'Your Area'}',
      subtitle:
          '${meta.keyword.isNotEmpty ? '"${meta.keyword}"' : 'Primary keyword'}'
          ' · ${config?.radiusKm ?? 5} km',
      trailing: status,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              style: seoOutlineButton(context),
              onPressed: scanning || triggering ? null : c.triggerGridScan,
              icon: SeoSpin(
                spinning: triggering,
                child: const Icon(Icons.radar, size: 18),
              ),
              label: Text(
                triggering
                    ? 'Starting…'
                    : 'Re-scan (${c.pricing.geoGridScan} credits)',
              ),
            ),
          ),
          if (c.gridScanError.value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              c.gridScanError.value,
              style: const TextStyle(color: SeoColors.rose, fontSize: 12.5),
            ),
          ],
          const SizedBox(height: 14),
          if (config != null && config.hasLocation)
            SeoGeoGrid(
              points: c.data.geoGrid,
              size: meta.gridSize,
              centerLat: config.lat!,
              centerLng: config.lng!,
              radiusKm: config.radiusKm,
              scanning: scanning,
              businessName: config.businessName,
              area: config.area,
              lastScanned: meta.lastScannedAt,
            )
          else
            const SeoEmptyState(
              icon: Icons.location_off_outlined,
              title: 'Location not set',
              message:
                  'Your property location is missing, so the map '
                  'coverage cannot be shown.',
              color: SeoColors.amber,
            ),
        ],
      ),
    );
  }
}

// ============================================================
// TREND + KEYWORDS
// ============================================================

class _Trend extends StatelessWidget {
  const _Trend({required this.c});

  final LocalSeoController c;

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final trend = c.data.trend;

    return SeoPanel(
      icon: Icons.trending_up,
      color: SeoColors.teal,
      title: 'Average ranking trend',
      subtitle: 'Last 30 days · lower is better',
      child: trend.isEmpty
          ? const SizedBox(
              height: 140,
              child: SeoEmptyState(
                icon: Icons.show_chart,
                title: 'No trend yet',
                message: 'Trend builds as daily rank snapshots accumulate.',
                color: SeoColors.teal,
              ),
            )
          : SeoRankChart(
              color: SeoColors.teal,
              points: [for (final t in trend) SeoRankPoint(t.label, t.avgRank)],
            ),
    );
  }
}

class _Keywords extends StatelessWidget {
  const _Keywords({required this.c, required this.wide});

  final LocalSeoController c;
  final bool wide;

  Future<void> _delete(BuildContext context, String keyword) async {
    if (!await confirmSeoDelete(context, keyword)) return;

    final ok = await c.untrackKeyword(keyword);
    Get.snackbar(
      ok ? 'Removed' : 'Not removed',
      ok ? '"$keyword" is no longer tracked.' : 'Please try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final city = c.config?.city ?? '';
    final list = c.keywords;

    return SeoPanel(
      icon: Icons.manage_search,
      color: SeoColors.emerald,
      title: 'Keyword intelligence',
      subtitle: [
        if (city.isNotEmpty) 'Volume = $city only',
        if (list.isNotEmpty) 'Tap a keyword for rank detail',
      ].join(' · '),
      child: list.isEmpty
          ? SeoEmptyState(
              icon: Icons.location_searching,
              title: 'No keywords tracked yet',
              message: 'Add local searches this property should win.',
              color: SeoColors.emerald,
              buttonLabel: 'Add keywords',
              onPressed: () => LocalSeoScreen.openAddKeywords(context, c),
            )
          : Column(
              children: [
                if (wide) const SeoKeywordHeader(kind: SeoKeywordKind.local),
                for (final k in list)
                  SeoKeywordTile(
                    key: ValueKey(k.key),
                    keyword: k,
                    kind: SeoKeywordKind.local,
                    wide: wide,
                    color: SeoColors.emerald,
                    refreshCost: c.pricing.localPerKeyword,
                    refreshing: c.refreshingKeyword.value == k.keyword,
                    busy: c.refreshingKeyword.value != null,
                    error: c.keywordErrors[k.keyword],
                    expanded: c.expandedKeyword.value == k.keyword,
                    onToggle: () => c.toggleExpanded(k.keyword),
                    onRefresh: () => c.refreshKeyword(k.keyword),
                    onDelete: () => _delete(context, k.keyword),
                  ),
              ],
            ),
    );
  }
}
