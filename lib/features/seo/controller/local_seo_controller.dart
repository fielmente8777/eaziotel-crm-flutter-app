// ============================================================
// LOCAL SEO CONTROLLER
//
//   Screen  --->  this controller  --->  SeoService  --->  API
//                      |
//                      +--> intelligenceResponse (keywords, config, grid)
//                      +--> tokenResponse        (credits, from the mixin)
//
// Same logic as the web dashboard (SeoIntelligenceDashboard.tsx):
//   1. SETUP      : no config / onboarding incomplete -> setup wizard
//   2. VISIBILITY : how many keywords are in the Map 3-Pack (top 3)
//   3. MAP GRID   : radius, grid keyword, re-scan (checks every 5 sec during a scan)
//   4. KEYWORDS   : add, refresh rank, remove
// ============================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/seo_insight.dart';
import '../models/seo_intelligence_response.dart';
import '../services/seo_service.dart';
import 'seo_token_mixin.dart';

class LocalSeoController extends GetxController with SeoTokenMixin {
  static const List<int> radiusOptions = [2, 5, 10];

  // ============================================================
  // API RESPONSE (model)
  // ============================================================

  final intelligenceResponse = Rxn<SeoIntelligenceResponse>();

  // ---------- Direct getters for the screen ----------

  SeoIntelligence get data =>
      intelligenceResponse.value?.result ?? const SeoIntelligence();

  SeoLocalConfig? get config => data.localConfig;
  SeoGridMeta get gridMeta => data.gridMeta;
  List<SeoKeyword> get keywords => data.localKeywords;

  /// First time: show the setup wizard
  bool get needsSetup =>
      intelligenceResponse.value != null &&
      (config == null || !config!.onboardingComplete);

  // ============================================================
  // STATE
  // ============================================================

  final isLoading = true.obs;
  final loadFailed = false.obs;

  final isSaving = false.obs;
  final addError = ''.obs;

  /// Which keyword is being refreshed
  final refreshingKeyword = RxnString();

  /// Keyword -> error ("Need 2 tokens (have 1)")
  final keywordErrors = <String, String>{}.obs;

  /// Which keyword is open (detail)
  final expandedKeyword = RxnString();

  final isTriggeringScan = false.obs;
  final watchingGridScan = false.obs;
  final gridScanError = ''.obs;

  Timer? _poll;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }

  // ============================================================
  // 1. LOAD
  // ============================================================

  Future<void> load() async {
    await Future.wait([_fetch(), loadTokens()]);
  }

  /// [silent] = do not show the loading shimmer (refresh / polling)
  Future<void> _fetch({bool silent = false}) async {
    if (!silent) isLoading.value = true;

    try {
      intelligenceResponse.value = await SeoService.getSeoIntelligence();
      loadFailed.value = false;
    } catch (e) {
      debugPrint('LOCAL SEO: load error: $e');
      if (!silent) loadFailed.value = intelligenceResponse.value == null;
    } finally {
      if (!silent) isLoading.value = false;
    }

    _syncPolling();
  }

  Future<void> refreshAll() async {
    await Future.wait([_fetch(silent: true), loadTokens()]);
  }

  // ============================================================
  // 2. VISIBILITY (calculated the same way as web)
  // ============================================================

  int get inPack => keywords
      .where((k) => k.liveGmbRank != null && k.liveGmbRank! <= 3)
      .length;

  double? get avgMapsRank {
    final ranked = keywords.where((k) => k.liveGmbRank != null).toList();
    if (ranked.isEmpty) return null;

    final total = ranked.fold<double>(0, (s, k) => s + k.liveGmbRank!);
    return total / ranked.length;
  }

  /// 0 - 100: what % of keywords are in the Map 3-Pack
  double get visibility =>
      keywords.isEmpty ? 0 : inPack / keywords.length * 100;

  List<SeoInsight> get insights => SeoInsight.build(data.keywords);

  // ============================================================
  // 3. MAP GRID
  // ============================================================

  bool get isGridScanning =>
      gridMeta.status == 'scanning' ||
      (gridMeta.status == 'pending' && watchingGridScan.value);

  /// While a scan runs, fresh data every 5 seconds
  void _syncPolling() {
    final status = gridMeta.status;

    if (status == 'scanning') watchingGridScan.value = true;
    if (status == 'done' || status == 'failed') watchingGridScan.value = false;

    if (isGridScanning) {
      _poll ??= Timer.periodic(
        const Duration(seconds: 5),
        (_) => _fetch(silent: true),
      );
    } else {
      _poll?.cancel();
      _poll = null;
    }
  }

  Future<void> triggerGridScan() async {
    if (isTriggeringScan.value) return;

    gridScanError.value = '';
    isTriggeringScan.value = true;
    watchingGridScan.value = true;
    _setData(data.copyWith(gridMeta: gridMeta.copyWith(status: 'pending')));

    try {
      await SeoService.triggerGridScan();
      await loadTokens();
      await _fetch(silent: true);
    } catch (e) {
      gridScanError.value =
          SeoService.tokenShortage(e) ??
          SeoService.errorMessage(e, 'Scan trigger failed.');
      await loadTokens();

      watchingGridScan.value = false;
      _setData(data.copyWith(gridMeta: gridMeta.copyWith(status: 'failed')));
      _syncPolling();
    } finally {
      isTriggeringScan.value = false;
    }
  }

  Future<bool> changeRadius(int km) async {
    final current = config;
    if (current == null || current.radiusKm == km) return true;

    try {
      await SeoService.updateRadius(radiusKm: km);
      _setData(data.copyWith(localConfig: current.copyWith(radiusKm: km)));
      return true;
    } catch (e) {
      debugPrint('LOCAL SEO: radius error: $e');
      return false;
    }
  }

  Future<bool> changeGridKeyword(String keyword) async {
    if (keyword.isEmpty || keyword == gridMeta.keyword) return true;

    try {
      await SeoService.updateGridKeyword(keyword: keyword);
      _setData(data.copyWith(gridMeta: gridMeta.copyWith(keyword: keyword)));
      return true;
    } catch (e) {
      debugPrint('LOCAL SEO: grid keyword error: $e');
      return false;
    }
  }

  // ============================================================
  // 4. KEYWORDS
  // ============================================================

  int costFor(int count) => count * pricing.localPerKeyword;

  /// Return: whether they were added (if not, the reason is in addError)
  Future<bool> addKeywords(List<String> list) async {
    if (list.isEmpty) return false;

    addError.value = '';
    isSaving.value = true;

    try {
      await SeoService.trackKeywords(
        keywords: list,
        selfDomain: config?.selfDomain ?? '',
        selfHotelName: config?.businessName ?? '',
      );
      await loadTokens();
      await _fetch(silent: true);
      return true;
    } catch (e) {
      final shortage = SeoService.tokenShortage(e);
      addError.value = shortage ?? "Couldn't add keywords. Please try again.";
      if (shortage != null) await loadTokens();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> refreshKeyword(String keyword) async {
    if (refreshingKeyword.value != null) return;

    keywordErrors.remove(keyword);
    refreshingKeyword.value = keyword;

    try {
      await SeoService.refreshKeyword(keyword: keyword);
      await loadTokens();
      await _fetch(silent: true);
    } catch (e) {
      final shortage = SeoService.tokenShortage(e);
      keywordErrors[keyword] = shortage ?? "Couldn't refresh. Try again.";
      if (shortage != null) await loadTokens();
    } finally {
      refreshingKeyword.value = null;
    }
  }

  /// Return: whether it was removed
  Future<bool> untrackKeyword(String keyword) async {
    try {
      await SeoService.untrackKeyword(keyword: keyword);
      _setData(
        data.copyWith(
          keywords: data.keywords.where((k) => k.keyword != keyword).toList(),
        ),
      );
      if (expandedKeyword.value == keyword) expandedKeyword.value = null;
      return true;
    } catch (e) {
      debugPrint('LOCAL SEO: untrack error: $e');
      return false;
    }
  }

  void toggleExpanded(String keyword) {
    expandedKeyword.value = expandedKeyword.value == keyword ? null : keyword;
  }

  // ============================================================
  // HELPER
  // ============================================================

  void _setData(SeoIntelligence value) {
    final response = intelligenceResponse.value;
    if (response == null) return;
    intelligenceResponse.value = response.copyWith(result: value);
  }
}
