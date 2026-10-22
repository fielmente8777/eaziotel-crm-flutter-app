// ============================================================
// META INSIGHTS SCREEN  (Drawer > Meta Insights)
//
// Like "Meta Page Insights" on the web:
//   top    : Today / 7 days / 28 days / 90 days
//   cards  : Followers, New Followers, Reach, Impressions, Video Views
//            (with ▲ / ▼ change)
//   charts : Reach, Engagements (daily)
//   posts  : the best posts (tap = open on Facebook)
//
// Phone: cards in 2 columns, charts stacked.
// Tablet: 3 cards, charts side by side.  Window: 5 cards.
// Meta not connected / error -> message + "Open Integrations".
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../setting_screen/controller/setting_controller.dart';
import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../setting_screen/setting_screen.dart';
import '../controller/meta_insights_controller.dart';
import 'widgets/meta_widgets.dart';

class MetaInsightsScreen extends StatelessWidget {
  const MetaInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MetaInsightsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meta Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: c.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: TResponsiveBuilder(
          builder: (context, r) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Periods(c: c, r: r),
              Expanded(
                child: Obx(() {
                  final hasData = c.overviewResponse.value != null;

                  if (c.isLoading.value && !hasData) return _Loading(r: r);

                  if (c.errorMessage.value != null && !hasData) {
                    return _Error(c: c);
                  }

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: c.isLoading.value ? .55 : 1,
                    child: RefreshIndicator(
                      onRefresh: c.load,
                      child: _Body(c: c, r: r),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Periods extends StatelessWidget {
  const _Periods({required this.c, required this.r});

  final MetaInsightsController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.pagePadding, 10, r.pagePadding, 4),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final p in MetaPeriod.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.label),
                    selected: c.period.value == p,
                    showCheckmark: false,
                    onSelected: (_) => c.changePeriod(p),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.c, required this.r});

  final MetaInsightsController c;
  final TResponsive r;

  Future<void> _openPost(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final data = c.overview;
    final cardCols = r.value(phone: 2, tablet: 3, desktop: 5);
    final postCols = r.value(phone: 1, tablet: 2, desktop: 3);
    final sideCharts = r.width >= 760;
    const gap = SizedBox(height: 16);

    final reach = MetaLineChart(
      title: 'Reach',
      points: data.reach,
      color: const Color(0xFF8B5CF6),
    );
    final engagements = MetaLineChart(
      title: 'Engagements',
      points: data.engagements,
      color: const Color(0xFF1877F2),
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(r.pagePadding),
      children: [
        if (c.errorMessage.value != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              c.errorMessage.value!,
              style: const TextStyle(color: Colors.red, fontSize: 12.5),
            ),
          ),
        if (data.cards.isEmpty)
          Text(
            'No page numbers for this period.',
            style: TextStyle(color: p.subText),
          )
        else
          _Grid(
            columns: cardCols,
            children: [for (final card in data.cards) MetaStatCard(card: card)],
          ),
        gap,
        if (sideCharts)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: reach),
                const SizedBox(width: 16),
                Expanded(child: engagements),
              ],
            ),
          )
        else ...[
          reach,
          gap,
          engagements,
        ],
        gap,
        Text(
          'Top posts',
          style: TextStyle(
            color: p.text,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        Text(
          'Best performing posts in this period',
          style: TextStyle(color: p.subText, fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        if (data.topPosts.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border),
            ),
            child: Text(
              'No posts found for this period.',
              style: TextStyle(color: p.subText),
            ),
          )
        else
          _Grid(
            columns: postCols,
            children: [
              for (var i = 0; i < data.topPosts.length; i++)
                MetaPostCard(
                  post: data.topPosts[i],
                  rank: i + 1,
                  onTap: data.topPosts[i].permalink.isEmpty
                      ? null
                      : () => _openPost(data.topPosts[i].permalink),
                ),
            ],
          ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 12.0;
        final width = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.c});

  final MetaInsightsController c;

  void _openIntegration() {
    Get.put(SettingController()).selectedTab.value = SettingTab.integration;
    Get.to(() => const SettingScreen())?.then((_) => c.load());
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1877F2).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.facebook,
                color: Color(0xFF1877F2),
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              c.errorMessage.value ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Make sure your Facebook Page is connected in Settings > Integrations.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: c.load,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try again'),
                ),
                ElevatedButton.icon(
                  style: settingSmallButton(),
                  onPressed: _openIntegration,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Open Integrations'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.r});

  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget box(double h) => Container(
      height: h,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(r.pagePadding),
        children: [
          _Grid(
            columns: r.value(phone: 2, tablet: 3, desktop: 5),
            children: List.generate(5, (_) => box(112)),
          ),
          const SizedBox(height: 16),
          box(280),
          const SizedBox(height: 16),
          box(120),
        ],
      ),
    );
  }
}
