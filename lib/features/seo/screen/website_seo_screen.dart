// ============================================================
// WEBSITE SEO SCREEN  (Drawer > SEO > Website Seo)
//
// Like "Website SEO Tracker" in the web dashboard:
//   no website link -> lock the link (permanently, after asking)
//   top               -> link (tap = opens), country, Add keywords
//   summary           -> kitne keyword, top 3, top 10, avg position
//   Organic Rankings  -> keyword, search volume, CPC, position,
//                        difficulty, refresh, remove (sorting too)
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/website_seo_controller.dart';
import 'local_seo_setup_view.dart' show seoInput;
import 'widgets/seo_add_keywords_sheet.dart';
import 'widgets/seo_common.dart';
import 'widgets/seo_keyword_tile.dart';

class WebsiteSeoScreen extends StatelessWidget {
  const WebsiteSeoScreen({super.key});

  static void openAddKeywords(BuildContext context, WebsiteSeoController c) {
    showSeoAddKeywords(
      context,
      title: 'Add keywords',
      subtitle: 'Track Google ranking for ${c.lockedUrl} (${c.countryName})',
      hint: 'best hotel in city\nluxury resort near me',
      color: SeoColors.blue,
      perKeyword: c.perKeyword,
      balance: c.tokenBalance,
      saving: c.isSaving,
      error: c.addError,
      onAdd: c.addKeywords,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(WebsiteSeoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Website SEO'),
        actions: [
          Obx(
            () => SeoCreditsChip(
              balance: c.tokenBalance,
              pricing: c.pricing,
              lowAt: c.perKeyword,
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
            !c.isLoading.value && !c.loadFailed.value && c.lockedUrl.isNotEmpty;
        if (!ready || !TResponsive.of(context).isPhone) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          backgroundColor: SeoColors.blue,
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

            if (c.lockedUrl.isEmpty) return _SetupWebsite(c: c);

            return _Dashboard(c: c, r: r);
          }),
        ),
      ),
    );
  }
}

// ============================================================
// SETUP: website link lock
// ============================================================

class _SetupWebsite extends StatelessWidget {
  const _SetupWebsite({required this.c});

  final WebsiteSeoController c;

  Future<void> _lock(BuildContext context) async {
    final p = SettingPalette(context);
    final url = c.setupUrl.text.trim();

    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: p.card,
        title: Text('Lock this website?', style: TextStyle(color: p.text)),
        content: Text.rich(
          TextSpan(
            style: TextStyle(color: p.subText, height: 1.4),
            children: [
              TextSpan(
                text: url,
                style: TextStyle(color: p.text, fontWeight: FontWeight.w700),
              ),
              const TextSpan(
                text:
                    ' will be your primary website. This is permanent and '
                    'cannot be changed later.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: seoButton(SeoColors.blue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, lock it'),
          ),
        ],
      ),
    );

    if (sure != true) return;

    final error = await c.lockWebsite();
    if (error != null) {
      Get.snackbar(
        'Setup failed',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SeoColors.rose,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SeoPanel(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SeoHeaderIcon(
                  icon: Icons.lock_outline,
                  colors: SeoColors.websiteGradient,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Set your primary website URL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: TextStyle(color: p.subText, height: 1.45),
                    children: const [
                      TextSpan(
                        text:
                            'Enter the main website you want to track Google '
                            'rankings for. ',
                      ),
                      TextSpan(
                        text: 'This is permanent and cannot be changed later.',
                        style: TextStyle(
                          color: SeoColors.rose,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: c.setupUrl,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(color: p.text),
                  onSubmitted: (_) {
                    if (c.canLockUrl) _lock(context);
                  },
                  decoration: seoInput(context, 'yourhotel.com').copyWith(
                    prefixIcon: Icon(Icons.language, color: p.subText),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: SeoColors.blue,
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton.icon(
                      style: seoButton(SeoColors.blue).copyWith(
                        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
                      ),
                      onPressed: c.canLockUrl && !c.isSettingUrl.value
                          ? () => _lock(context)
                          : null,
                      icon: SeoSpin(
                        spinning: c.isSettingUrl.value,
                        child: Icon(
                          c.isSettingUrl.value
                              ? Icons.sync
                              : Icons.lock_outline,
                          size: 18,
                        ),
                      ),
                      label: Text(
                        c.isSettingUrl.value ? 'Locking…' : 'Lock URL',
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

// ============================================================
// DASHBOARD
// ============================================================

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.c, required this.r});

  final WebsiteSeoController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final gap = SizedBox(height: r.isPhone ? 12 : 16);
    final total = c.data.websiteKeywords.length;

    return RefreshIndicator(
      color: SeoColors.blue,
      onRefresh: c.refreshAll,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          r.pagePadding,
          r.pagePadding,
          r.pagePadding,
          r.isPhone ? 96 : r.pagePadding,
        ),
        children: [
          _Header(c: c, wide: !r.isPhone),
          gap,
          SeoGrid(
            columns: r.isPhone ? 2 : 4,
            children: [
              SeoStatCard(
                icon: Icons.tag,
                label: 'Keywords tracked',
                value: SeoFormat.number(total),
                sub: c.countryName,
                color: SeoColors.blue,
              ),
              SeoStatCard(
                icon: Icons.emoji_events_outlined,
                label: 'In top 3',
                value: SeoFormat.number(c.inTop3),
                sub: 'best spots on Google',
                color: SeoColors.emerald,
              ),
              SeoStatCard(
                icon: Icons.looks_one_outlined,
                label: 'On page 1',
                value: SeoFormat.number(c.inTop10),
                sub: 'top 10 results',
                color: SeoColors.teal,
              ),
              SeoStatCard(
                icon: Icons.leaderboard_outlined,
                label: 'Avg position',
                value: SeoFormat.rank(c.avgPosition),
                sub: 'lower is better',
                color: SeoColors.indigo,
              ),
            ],
          ),
          gap,
          _Rankings(c: c, wide: !r.isPhone),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.c, required this.wide});

  final WebsiteSeoController c;
  final bool wide;

  Future<void> _open() async {
    final url = c.lockedUrl;
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _country(String? code) async {
    if (code == null) return;
    if (!await c.changeCountry(code)) {
      Get.snackbar(
        'Not saved',
        'Could not change the country. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final p = SettingPalette(context);

    final country = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeoSpin(
            spinning: c.isChangingCountry.value,
            child: Icon(
              c.isChangingCountry.value ? Icons.sync : Icons.public,
              size: 17,
              color: SeoColors.blue,
            ),
          ),
          const SizedBox(width: 6),
          DropdownButton<String>(
            value:
                WebsiteSeoController.countries.any(
                  (x) => x.code == c.country.value,
                )
                ? c.country.value
                : 'IN',
            underline: const SizedBox.shrink(),
            dropdownColor: p.card,
            style: TextStyle(color: p.text, fontWeight: FontWeight.w600),
            items: [
              for (final x in WebsiteSeoController.countries)
                DropdownMenuItem(value: x.code, child: Text(x.name)),
            ],
            onChanged: c.isChangingCountry.value ? null : _country,
          ),
        ],
      ),
    );

    return SeoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SeoHeaderIcon(
                icon: Icons.language,
                colors: SeoColors.websiteGradient,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Website SEO Tracker',
                          style: TextStyle(
                            color: p.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SeoTag(
                          text: 'LOCKED',
                          color: SeoColors.emerald,
                          icon: Icons.lock_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: _open,
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(color: p.subText, fontSize: 12.5),
                          children: [
                            const TextSpan(text: 'Tracking: '),
                            TextSpan(
                              text: c.lockedUrl,
                              style: const TextStyle(
                                color: SeoColors.blue,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: SeoColors.blue,
                              ),
                            ),
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Icon(
                                  Icons.open_in_new,
                                  size: 13,
                                  color: SeoColors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              country,
              if (wide)
                ElevatedButton.icon(
                  style: seoButton(SeoColors.blue),
                  onPressed: () => WebsiteSeoScreen.openAddKeywords(context, c),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add keywords'),
                ),
              Text(
                '${c.perKeyword} credits per keyword in ${c.countryName}',
                style: TextStyle(color: p.subText, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Rankings extends StatelessWidget {
  const _Rankings({required this.c, required this.wide});

  final WebsiteSeoController c;
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
    final p = SettingPalette(context);
    final list = c.keywords;

    final sort = Wrap(
      spacing: 6,
      children: [
        for (final (value, label) in const [
          (WebsiteSort.rank, 'Best rank'),
          (WebsiteSort.volume, 'Volume'),
          (WebsiteSort.name, 'A–Z'),
        ])
          ChoiceChip(
            label: Text(label),
            selected: c.sortBy.value == value,
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            selectedColor: SeoColors.blue.withValues(alpha: .15),
            side: BorderSide(
              color: c.sortBy.value == value ? SeoColors.blue : p.border,
            ),
            labelStyle: TextStyle(
              color: c.sortBy.value == value ? SeoColors.blue : p.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => c.sortBy.value = value,
          ),
      ],
    );

    return SeoPanel(
      icon: Icons.search,
      color: SeoColors.blue,
      title: 'Organic Rankings',
      subtitle: 'Where your website shows on Google',
      child: list.isEmpty
          ? SeoEmptyState(
              icon: Icons.search,
              title: 'No keywords tracked yet',
              message:
                  'Monitor where your website ranks on Google for specific searches.',
              color: SeoColors.blue,
              buttonLabel: 'Track first keyword',
              onPressed: () => WebsiteSeoScreen.openAddKeywords(context, c),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerLeft, child: sort),
                const SizedBox(height: 12),
                if (wide) const SeoKeywordHeader(kind: SeoKeywordKind.website),
                for (final k in list)
                  SeoKeywordTile(
                    key: ValueKey(k.key),
                    keyword: k,
                    kind: SeoKeywordKind.website,
                    wide: wide,
                    color: SeoColors.blue,
                    refreshCost: c.perKeyword,
                    refreshing: c.refreshingKeyword.value == k.keyword,
                    busy: c.refreshingKeyword.value != null,
                    error: c.keywordErrors[k.keyword],
                    onRefresh: () => c.refreshKeyword(k.keyword),
                    onDelete: () => _delete(context, k.keyword),
                  ),
              ],
            ),
    );
  }
}
