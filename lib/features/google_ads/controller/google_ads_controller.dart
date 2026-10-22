// ============================================================
// GOOGLE ADS CONTROLLER
//
//   Screen  --->  this controller  --->  GoogleAdsService  --->  API
//                      |
//                      +--> every API's response model is stored here
//                           (accountResponse, campaignResponse, summaryResponse ...)
//
// Same logic as the web dashboard (GoogleAdsInsights.jsx):
//   1. CONNECTED?  : Google Ads not connected -> "Connect Google Ads"
//   2. RANGE       : 7D / 30D / 90D (from the DB only)
//   3. FILTERS     : Account -> Campaign -> Ad Group -> Ad
//   4. METRICS     : summary + pichhla range (badlav %) + devices
//   5. COMPARISON  : summary of each campaign, by spend
//   6. SYNC        : fresh 90 days of data from Google
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/google_ads_account_response.dart';
import '../models/google_ads_ad_group_response.dart';
import '../models/google_ads_ad_response.dart';
import '../models/google_ads_campaign_response.dart';
import '../models/google_ads_device_response.dart';
import '../models/google_ads_summary_response.dart';
import '../services/google_ads_service.dart';

enum AdsRange {
  d7('7D', 7),
  d30('30D', 30),
  d90('90D', 90);

  const AdsRange(this.label, this.days);

  final String label;
  final int days;
}

class GoogleAdsController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  /// '' = "All ..." (the first option of the dropdown)
  static const String all = '';

  // ============================================================
  // API RESPONSE (model) - this is the real data
  // ============================================================

  final accountResponse = Rxn<GoogleAdsAccountResponse>();
  final campaignResponse = Rxn<GoogleAdsCampaignResponse>();
  final adGroupResponse = Rxn<GoogleAdsAdGroupResponse>();
  final adResponse = Rxn<GoogleAdsAdResponse>();
  final summaryResponse = Rxn<GoogleAdsSummaryResponse>();

  /// Summary of the previous range of the same length (for the KPI change %)
  final previousSummaryResponse = Rxn<GoogleAdsSummaryResponse>();
  final deviceResponse = Rxn<GoogleAdsDeviceResponse>();

  /// Campaign Comparison (summary of each campaign)
  final campaignRows = <GoogleAdsCampaignRow>[].obs;

  // ---------- Direct getters for the screen ----------

  List<GoogleAdsAccount> get accounts =>
      accountResponse.value?.accounts ?? const [];

  List<GoogleAdsCampaign> get campaigns =>
      campaignResponse.value?.enabled ?? const [];

  List<GoogleAdsAdGroup> get adGroups =>
      adGroupResponse.value?.enabled ?? const [];

  List<GoogleAdsAd> get ads => adResponse.value?.enabled ?? const [];

  GoogleAdsSummary get summary =>
      summaryResponse.value?.result ?? const GoogleAdsSummary();

  GoogleAdsTotals? get previousTotals =>
      previousSummaryResponse.value?.result.totals;

  List<GoogleAdsDevice> get devices =>
      deviceResponse.value?.grouped ?? const [];

  // ============================================================
  // STATE
  // ============================================================

  final isCheckingConnection = true.obs;
  final isConnected = false.obs;
  final isLoading = false.obs;
  final isSyncing = false.obs;

  final range = AdsRange.d30.obs;

  final accountId = ''.obs;
  final campaignId = all.obs;
  final adGroupId = all.obs;
  final adId = all.obs;

  /// Accounts already auto-synced (do not sync again)
  final Set<String> _autoSynced = {};

  @override
  void onInit() {
    super.onInit();
    start();
  }

  // ============================================================
  // 1. CONNECTED?
  // ============================================================

  Future<void> start() async {
    isCheckingConnection.value = true;

    try {
      isConnected.value =
          hid.isNotEmpty &&
          await GoogleAdsService.isGoogleAdsConnected(hid: hid);
    } catch (e) {
      debugPrint('GOOGLE ADS: connection check error: $e');
      isConnected.value = false;
    } finally {
      isCheckingConnection.value = false;
    }

    if (isConnected.value) await loadAccounts();
  }

  // ============================================================
  // 2. RANGE
  // ============================================================

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// From [days] days ago until today
  static ({String start, String end}) rangeOf(int days, {DateTime? now}) {
    final end = now ?? DateTime.now();
    return (start: _fmt(end.subtract(Duration(days: days))), end: _fmt(end));
  }

  /// The same number of days, right before (for the change %)
  static ({String start, String end}) previousOf(int days, {DateTime? now}) {
    final current = (now ?? DateTime.now()).subtract(Duration(days: days));
    final end = current.subtract(const Duration(days: 1));
    return (start: _fmt(end.subtract(Duration(days: days))), end: _fmt(end));
  }

  Future<void> changeRange(AdsRange value) async {
    range.value = value;
    await loadMetrics();
    await buildComparison();
  }

  // ============================================================
  // 3. FILTERS
  // ============================================================

  Future<void> loadAccounts() async {
    isLoading.value = true;

    try {
      accountResponse.value = await GoogleAdsService.getGoogleAdsAccounts();
    } catch (e) {
      debugPrint('GOOGLE ADS: accounts error: $e');
    } finally {
      isLoading.value = false;
    }

    if (accounts.isNotEmpty && accountId.value.isEmpty) {
      await changeAccount(accounts.first.id);
    }
  }

  Future<void> changeAccount(String id) async {
    accountId.value = id;
    campaignId.value = all;
    adGroupId.value = all;
    adId.value = all;
    campaignResponse.value = null;
    adGroupResponse.value = null;
    adResponse.value = null;
    campaignRows.clear();

    try {
      campaignResponse.value = await GoogleAdsService.getGoogleAdsCampaigns(
        accountId: id,
      );
    } catch (e) {
      debugPrint('GOOGLE ADS: campaigns error: $e');
    }

    final hasData = await loadMetrics();

    // Same as web: the DB is empty and no sync has happened yet -> sync once
    if (!hasData && !_autoSynced.contains(id)) {
      await syncNow();
      return;
    }

    await buildComparison();
  }

  Future<void> changeCampaign(String id) async {
    campaignId.value = id;
    adGroupId.value = all;
    adId.value = all;
    adGroupResponse.value = null;
    adResponse.value = null;

    if (id != all) {
      try {
        adGroupResponse.value = await GoogleAdsService.getGoogleAdsAdGroups(
          campaignId: id,
        );
      } catch (e) {
        debugPrint('GOOGLE ADS: ad groups error: $e');
      }
    }

    await loadMetrics();
  }

  Future<void> changeAdGroup(String id) async {
    adGroupId.value = id;
    adId.value = all;
    adResponse.value = null;

    if (id != all) {
      try {
        adResponse.value = await GoogleAdsService.getGoogleAdsAds(
          adGroupId: id,
        );
      } catch (e) {
        debugPrint('GOOGLE ADS: ads error: $e');
      }
    }

    await loadMetrics();
  }

  Future<void> changeAd(String id) async {
    adId.value = id;
    await loadMetrics();
  }

  /// Data of the lowest selected item: Ad > Campaign > Account
  ({String id, String level}) get target {
    if (adId.value != all) return (id: adId.value, level: 'ad');
    if (campaignId.value != all) {
      return (id: campaignId.value, level: 'campaign');
    }
    return (id: accountId.value, level: 'account');
  }

  String get targetLabel {
    if (adId.value != all) return 'Single ad';
    if (campaignId.value != all) {
      final c = campaigns.firstWhereOrNull((c) => c.id == campaignId.value);
      return c == null ? 'Selected campaign' : 'Campaign: ${c.label}';
    }
    return 'All campaigns (account total)';
  }

  // ============================================================
  // 4. METRICS
  // ============================================================

  /// Return: whether data was found
  Future<bool> loadMetrics() async {
    final t = target;
    if (accountId.value.isEmpty || t.id.isEmpty) return false;

    final r = rangeOf(range.value.days);
    final p = previousOf(range.value.days);

    isLoading.value = true;

    try {
      final response = await GoogleAdsService.getGoogleAdsSummary(
        entityId: t.id,
        level: t.level,
        startDate: r.start,
        endDate: r.end,
      );

      if (!response.result.hasData) {
        _clearMetrics();
        return false;
      }

      summaryResponse.value = response;

      // Devices and the previous range: show the rest even if these fail
      await Future.wait([
        _loadDevices(t.id, t.level, r.start, r.end),
        _loadPrevious(t.id, t.level, p.start, p.end),
      ]);

      return true;
    } catch (e) {
      debugPrint('GOOGLE ADS: metrics error: $e');
      _clearMetrics();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDevices(
    String id,
    String level,
    String from,
    String to,
  ) async {
    try {
      deviceResponse.value = await GoogleAdsService.getGoogleAdsDevices(
        entityId: id,
        level: level,
        startDate: from,
        endDate: to,
      );
    } catch (_) {
      deviceResponse.value = null;
    }
  }

  Future<void> _loadPrevious(
    String id,
    String level,
    String from,
    String to,
  ) async {
    try {
      previousSummaryResponse.value =
          await GoogleAdsService.getGoogleAdsSummary(
            entityId: id,
            level: level,
            startDate: from,
            endDate: to,
          );
    } catch (_) {
      previousSummaryResponse.value = null;
    }
  }

  void _clearMetrics() {
    summaryResponse.value = null;
    previousSummaryResponse.value = null;
    deviceResponse.value = null;
  }

  /// Change % (null if the previous value is 0 or missing)
  double? change(double current, double? before) =>
      before == null || before == 0 ? null : (current - before) / before;

  // ============================================================
  // 5. CAMPAIGN COMPARISON
  // ============================================================

  Future<void> buildComparison() async {
    if (campaigns.isEmpty) {
      campaignRows.clear();
      return;
    }

    final r = rangeOf(range.value.days);

    final rows = await Future.wait(
      campaigns.map((c) async {
        try {
          final response = await GoogleAdsService.getGoogleAdsSummary(
            entityId: c.id,
            level: 'campaign',
            startDate: r.start,
            endDate: r.end,
          );
          return GoogleAdsCampaignRow(
            campaignId: c.id,
            name: c.label,
            summary: response.result,
          );
        } catch (_) {
          return GoogleAdsCampaignRow(
            campaignId: c.id,
            name: c.label,
            summary: const GoogleAdsSummary(),
          );
        }
      }),
    );

    rows.sort((a, b) => b.summary.totals.cost.compareTo(a.summary.totals.cost));
    campaignRows.assignAll(rows);
  }

  // ============================================================
  // 6. SYNC
  // ============================================================

  /// Return: null = done, text = error
  Future<String?> syncNow() async {
    if (isSyncing.value) return null;

    isSyncing.value = true;

    final r = rangeOf(AdsRange.d90.days); // The web always syncs 90 days
    final account = accountId.value;

    try {
      await GoogleAdsService.syncGoogleAds(
        startDate: r.start,
        endDate: r.end,
        accountId: account,
        campaignId: campaignId.value,
      );

      if (account.isNotEmpty) _autoSynced.add(account);

      if (account.isEmpty) {
        await loadAccounts();
      } else {
        await loadMetrics();
        await buildComparison();
      }
      return null;
    } catch (e) {
      debugPrint('GOOGLE ADS: sync error: $e');
      return "We couldn't connect to Google Ads right now. Please try again.";
    } finally {
      isSyncing.value = false;
    }
  }
}
