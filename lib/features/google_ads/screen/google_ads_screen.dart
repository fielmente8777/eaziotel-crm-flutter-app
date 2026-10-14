// ============================================================
// GOOGLE ADS SCREEN  (Drawer > Google Ads Insights)
//
// Web dashboard ke "Google Ads Performance" jaisa:
//   Google Ads juda nahi   -> "Connect Google Ads" (Settings > Integration)
//   upar                   -> Sync + 7D / 30D / 90D + Account/Campaign/Ad Group/Ad
//   data hai               -> KPI, charts, campaign comparison, ad previews
//   data nahi              -> "Check for latest updates" (Sync)
//
// Phone par sab ek ke neeche ek, window par 3 column.
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/controller/setting_controller.dart';
import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../setting_screen/setting_screen.dart';
import '../controller/google_ads_controller.dart';
import '../models/google_ads_common.dart';
import 'widgets/ads_campaigns.dart';
import 'widgets/ads_charts.dart';
import 'widgets/ads_common.dart';

class GoogleAdsScreen extends StatelessWidget {
  const GoogleAdsScreen({super.key});

  Future<void> _sync(GoogleAdsController controller) async {
    final error = await controller.syncNow();

    Get.snackbar(
      error == null ? 'Workspace ready' : 'Sync interrupted',
      error ?? 'Your performance data is now up to date.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GoogleAdsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Ads Performance'),
        actions: [
          Obx(() {
            if (!controller.isConnected.value) return const SizedBox.shrink();

            final syncing = controller.isSyncing.value;

            return TextButton.icon(
              onPressed: syncing ? null : () => _sync(controller),
              icon: const Icon(Icons.sync, size: 18),
              label: Text(syncing ? 'Syncing...' : 'Sync Data'),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: TResponsiveBuilder(
          builder: (context, r) {
            final kpiColumns = r.value(phone: 2, tablet: 3, desktop: 6);

            return Obx(() {
              if (controller.isCheckingConnection.value) {
                return ListView(
                  padding: EdgeInsets.all(r.pagePadding),
                  children: [AdsShimmer(columns: kpiColumns)],
                );
              }

              if (!controller.isConnected.value) {
                return _NotConnected(onRetry: controller.start);
              }

              return RefreshIndicator(
                onRefresh: controller.loadMetrics,
                child: ListView(
                  padding: EdgeInsets.all(r.pagePadding),
                  children: [
                    Text(
                      controller.targetLabel,
                      style: TextStyle(
                        color: SettingPalette(context).subText,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RangeChips(controller: controller),
                    const SizedBox(height: 12),
                    _Filters(
                      controller: controller,
                      columns: r.isPhone ? 1 : 2,
                    ),
                    const SizedBox(height: 16),
                    if (controller.isLoading.value)
                      AdsShimmer(columns: kpiColumns)
                    else if (!controller.summary.hasData)
                      _NoData(
                        days: controller.range.value.days,
                        syncing: controller.isSyncing.value,
                        onSync: () => _sync(controller),
                      )
                    else
                      _Dashboard(
                        controller: controller,
                        kpiColumns: kpiColumns,
                        wide: !r.isPhone,
                        threeColumns: r.isDesktop,
                      ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

// ============================================================
// TOP: range + filters
// ============================================================

class _RangeChips extends StatelessWidget {
  const _RangeChips({required this.controller});

  final GoogleAdsController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final range in AdsRange.values)
          ChoiceChip(
            label: Text(range.label),
            selected: controller.range.value == range,
            onSelected: (_) => controller.changeRange(range),
          ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller, required this.columns});

  final GoogleAdsController controller;
  final int columns;

  Widget _dropdown({
    required String label,
    required String value,
    required List<AdsDropdownItem> options,
    required ValueChanged<String> onChanged,
    String? allLabel,
    bool enabled = true,
  }) {
    final items = [
      if (allLabel != null) (id: GoogleAdsController.all, label: allLabel),
      for (final o in options) (id: o.id, label: o.label),
    ];

    final safeValue = items.any((o) => o.id == value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: [
        for (final o in items)
          DropdownMenuItem(
            value: o.id,
            child: Text(
              o.label.isEmpty ? 'N/A' : o.label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: enabled && items.isNotEmpty
          ? (v) => onChanged(v ?? GoogleAdsController.all)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdsGrid(
      columns: columns,
      children: [
        _dropdown(
          label: 'Account',
          value: c.accountId.value,
          options: c.accounts,
          onChanged: c.changeAccount,
        ),
        _dropdown(
          label: 'Campaign',
          value: c.campaignId.value,
          options: c.campaigns,
          allLabel: 'All Campaigns (Account)',
          enabled: c.accountId.value.isNotEmpty,
          onChanged: c.changeCampaign,
        ),
        _dropdown(
          label: 'Ad Group',
          value: c.adGroupId.value,
          options: c.adGroups,
          allLabel: 'All Ad Groups',
          enabled: c.campaignId.value != GoogleAdsController.all,
          onChanged: c.changeAdGroup,
        ),
        _dropdown(
          label: 'Ad',
          value: c.adId.value,
          options: c.ads,
          allLabel: 'All Ads (Aggregated)',
          enabled: c.adGroupId.value != GoogleAdsController.all,
          onChanged: c.changeAd,
        ),
      ],
    );
  }
}

// ============================================================
// DASHBOARD (data hai)
// ============================================================

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.controller,
    required this.kpiColumns,
    required this.wide,
    required this.threeColumns,
  });

  final GoogleAdsController controller;
  final int kpiColumns;
  final bool wide;
  final bool threeColumns;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final s = c.summary;
    final t = s.totals;
    final d = s.derived;
    final prev = c.previousTotals;
    final isAd = c.adId.value != GoogleAdsController.all;

    const indigo = Color(0xFF6366F1);
    const violet = Color(0xFF8B5CF6);
    const cyan = Color(0xFF0891B2);

    final labels = [for (final p in s.series) p.label];

    final small = [
      AdsPanel(
        title: 'Conversion Funnel',
        subtitle: 'Impressions → Clicks → Conversions',
        child: Column(
          children: [
            FunnelBars(
              steps: [
                ('Impressions', t.impressions, TAppColors.info),
                ('Clicks', t.clicks, violet),
                ('Conversions', t.conversions, TAppColors.success),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: MiniStat(
                    label: 'CTR',
                    value: AdsFormat.percent(d.ctr),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MiniStat(
                    label: 'Conv. Rate',
                    value: AdsFormat.percent(d.conversionRate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      AdsPanel(
        title: 'Clicks by Device',
        subtitle: 'Distribution across devices',
        child: c.devices.isEmpty
            ? const EmptyMini(
                text: 'No device data for this selection yet. Try a Sync.',
              )
            : DeviceDonut(slices: c.devices),
      ),
      AdsPanel(
        title: 'Search Impression Share',
        subtitle: isAd
            ? 'Not available at ad level'
            : 'Share of eligible impressions',
        child: d.searchImpressionShare == null
            ? EmptyMini(
                text: isAd
                    ? 'Switch to a campaign or account view to see impression share.'
                    : 'No impression share data for this range.',
              )
            : ImpressionShareRing(
                share: d.searchImpressionShare!,
                approx: d.searchImpressionShareApprox,
              ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---------- KPI ----------
        AdsGrid(
          columns: kpiColumns,
          children: [
            KpiCard(
              label: 'Impressions',
              value: AdsFormat.number(t.impressions),
              color: TAppColors.info,
              change: c.change(t.impressions, prev?.impressions),
            ),
            KpiCard(
              label: 'Clicks',
              value: AdsFormat.number(t.clicks),
              color: indigo,
              change: c.change(t.clicks, prev?.clicks),
            ),
            KpiCard(
              label: 'Cost',
              value: AdsFormat.money(t.cost),
              color: violet,
              change: c.change(t.cost, prev?.cost),
              lowerIsBetter: true,
            ),
            KpiCard(
              label: 'Conversions',
              value: AdsFormat.number(t.conversions),
              color: TAppColors.success,
              change: c.change(t.conversions, prev?.conversions),
            ),
            KpiCard(
              label: 'CTR',
              value: AdsFormat.percent(d.ctr),
              color: TAppColors.warning,
              hint: 'Click-through rate',
            ),
            KpiCard(
              label: 'Avg. CPC',
              value: AdsFormat.money(d.averageCpc),
              color: TAppColors.error,
              hint: 'Cost per click',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ---------- Mini stats ----------
        AdsGrid(
          columns: wide ? 4 : 2,
          children: [
            MiniStat(
              label: 'Conversion Rate',
              value: AdsFormat.percent(d.conversionRate),
            ),
            MiniStat(
              label: 'Cost / Conversion',
              value: AdsFormat.money(d.costPerConversion),
            ),
            MiniStat(
              label: 'ROAS',
              value: t.cost > 0 && t.conversionsValue > 0
                  ? '${AdsFormat.decimal(d.roas)}×'
                  : 'N/A',
              color: TAppColors.success,
            ),
            MiniStat(
              label: 'Conv. Value',
              value: AdsFormat.money(t.conversionsValue),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ---------- Charts ----------
        AdsPanel(
          title: 'Engagement Trend',
          subtitle: 'Daily clicks & conversions',
          child: TwoLineChart(
            labels: labels,
            filled: true,
            lines: [
              ChartLine(
                name: 'Clicks',
                color: indigo,
                values: [for (final p in s.series) p.clicks],
              ),
              ChartLine(
                name: 'Conversions',
                color: TAppColors.success,
                values: [for (final p in s.series) p.conversions],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AdsPanel(
          title: 'Spend vs. Revenue',
          subtitle: 'Daily cost against conversion value (₹)',
          badge: 'ROAS ${AdsFormat.decimal(d.roas)}×',
          child: TwoLineChart(
            labels: labels,
            money: true,
            lines: [
              ChartLine(
                name: 'Cost',
                color: violet,
                values: [for (final p in s.series) p.cost],
              ),
              ChartLine(
                name: 'Conv. Value',
                color: cyan,
                values: [for (final p in s.series) p.conversionsValue],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ---------- Funnel / Device / Impression share ----------
        if (threeColumns)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < small.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: small[i]),
                ],
              ],
            ),
          )
        else
          for (final panel in small) ...[panel, const SizedBox(height: 12)],
        const SizedBox(height: 12),

        // ---------- Campaigns ----------
        AdsPanel(
          title: 'Campaign Comparison',
          subtitle: 'Ranked by spend in selected range. Tap to open.',
          child: CampaignComparison(
            rows: c.campaignRows,
            wide: wide,
            onTap: c.changeCampaign,
          ),
        ),
        const SizedBox(height: 12),

        // ---------- Ad previews ----------
        AdsPanel(
          title: 'Live Ad Previews',
          subtitle: 'How your ads appear on Google Search',
          child: c.ads.isEmpty
              ? const EmptyMini(
                  text:
                      'Select a Campaign and Ad Group above to view live ad previews.',
                )
              : AdsGrid(
                  columns: threeColumns ? 3 : (wide ? 2 : 1),
                  children: [
                    for (final ad in c.ads.take(6)) AdPreviewCard(ad: ad),
                  ],
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ============================================================
// EMPTY / NOT CONNECTED
// ============================================================

class _NoData extends StatelessWidget {
  const _NoData({
    required this.days,
    required this.syncing,
    required this.onSync,
  });

  final int days;
  final bool syncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: TAppColors.info.withValues(alpha: 0.12),
            child: const Icon(
              Icons.cloud_download_outlined,
              size: 32,
              color: TAppColors.info,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Data for Past $days Days',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We couldn't find any performance data for this time range. "
            'Check for the latest updates from Google Ads.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.subText, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: settingSmallButton(),
            onPressed: syncing ? null : onSync,
            icon: const Icon(Icons.sync, size: 18),
            label: Text(
              syncing ? 'Checking for updates...' : 'Check for latest updates',
            ),
          ),
        ],
      ),
    );
  }
}

class _NotConnected extends StatelessWidget {
  const _NotConnected({required this.onRetry});

  final Future<void> Function() onRetry;

  /// Settings kholo, Integration tab chuna hua
  void _openIntegration() {
    Get.put(SettingController()).selectedTab.value = SettingTab.integration;
    Get.to(() => const SettingScreen())?.then((_) => onRetry());
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  size: 44,
                  color: Color(0xFFF9AB00),
                ),
                const SizedBox(height: 12),
                Text(
                  'Connect Google Ads',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connect your Google Ads account to see campaign performance here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.subText, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: settingSmallButton(),
                    onPressed: _openIntegration,
                    child: const Text('Connect Now'),
                  ),
                ),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
