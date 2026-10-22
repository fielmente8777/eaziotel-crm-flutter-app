// ============================================================
// WEBSITE SEO CONTROLLER
//
//   Screen  --->  this controller  --->  SeoService  --->  API
//                      |
//                      +--> intelligenceResponse (website keywords + url)
//                      +--> tokenResponse        (credits, from the mixin)
//
// Same logic as the web dashboard (WebsiteDashboard.tsx):
//   1. NO URL     : lock the website link (permanently)
//   2. COUNTRY    : India / US / ... (credits depend on the country)
//   3. KEYWORDS   : add, refresh Google rank, remove
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/seo_intelligence_response.dart';
import '../models/seo_token_response.dart';
import '../services/seo_service.dart';
import 'seo_token_mixin.dart';

enum WebsiteSort { rank, volume, name }

class WebsiteSeoController extends GetxController with SeoTokenMixin {
  static const List<({String code, String name})> countries = [
    (code: 'IN', name: 'India'),
    (code: 'US', name: 'United States'),
    (code: 'GB', name: 'United Kingdom'),
    (code: 'AE', name: 'UAE'),
    (code: 'AU', name: 'Australia'),
    (code: 'CA', name: 'Canada'),
    (code: 'WORLD', name: 'Worldwide (Global)'),
  ];

  // ============================================================
  // API RESPONSE (model)
  // ============================================================

  final intelligenceResponse = Rxn<SeoIntelligenceResponse>();

  SeoIntelligence get data =>
      intelligenceResponse.value?.result ?? const SeoIntelligence();

  /// The locked website link ('' = not yet)
  String get lockedUrl => data.localConfig?.websiteUrl.trim() ?? '';

  // ============================================================
  // STATE
  // ============================================================

  final isLoading = true.obs;
  final loadFailed = false.obs;

  final country = 'IN'.obs;
  final isChangingCountry = false.obs;

  final setupUrl = TextEditingController();
  final isSettingUrl = false.obs;
  final _setupTick = 0.obs;

  final isSaving = false.obs;
  final addError = ''.obs;
  final refreshingKeyword = RxnString();
  final keywordErrors = <String, String>{}.obs;

  final sortBy = WebsiteSort.rank.obs;

  @override
  void onInit() {
    super.onInit();
    setupUrl.addListener(() => _setupTick.value++);
    load();
  }

  @override
  void onClose() {
    setupUrl.dispose();
    super.onClose();
  }

  bool get canLockUrl {
    _setupTick.value;
    return setupUrl.text.trim().isNotEmpty;
  }

  // ============================================================
  // 1. LOAD
  // ============================================================

  Future<void> load() async {
    await Future.wait([_fetch(), loadTokens()]);
  }

  Future<void> refreshAll() async {
    await Future.wait([_fetch(silent: true), loadTokens()]);
  }

  Future<void> _fetch({bool silent = false}) async {
    if (!silent) isLoading.value = true;

    try {
      intelligenceResponse.value = await SeoService.getSeoIntelligence();
      loadFailed.value = false;

      final saved = data.localConfig?.websiteCountry ?? '';
      if (saved.isNotEmpty) country.value = saved;
    } catch (e) {
      debugPrint('WEBSITE SEO: load error: $e');
      if (!silent) loadFailed.value = intelligenceResponse.value == null;
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// Return: null = done, text = error
  Future<String?> lockWebsite() async {
    final url = setupUrl.text.trim();
    if (url.isEmpty || isSettingUrl.value) return null;

    isSettingUrl.value = true;

    try {
      await SeoService.setWebsite(websiteUrl: url);
      await _fetch();
      return null;
    } catch (e) {
      return SeoService.errorMessage(e, 'Setup failed. Please try again.');
    } finally {
      isSettingUrl.value = false;
    }
  }

  // ============================================================
  // 2. DESH
  // ============================================================

  String get countryName =>
      countries.firstWhereOrNull((c) => c.code == country.value)?.name ??
      country.value;

  /// India 2 credits, others 3 credits (per keyword)
  int get perKeyword => SeoTokenPricing.websiteFor(country.value);

  int costFor(int count) => count * perKeyword;

  /// Return: whether it changed
  Future<bool> changeCountry(String code) async {
    if (code == country.value || isChangingCountry.value) return true;

    final before = country.value;
    country.value = code;
    isChangingCountry.value = true;

    try {
      await SeoService.updateWebsiteCountry(country: code);
      await refreshAll();
      return true;
    } catch (e) {
      debugPrint('WEBSITE SEO: country error: $e');
      country.value = before;
      return false;
    } finally {
      isChangingCountry.value = false;
    }
  }

  // ============================================================
  // 3. KEYWORDS
  // ============================================================

  List<SeoKeyword> get keywords {
    final list = [...data.websiteKeywords];

    switch (sortBy.value) {
      case WebsiteSort.rank:
        // Ranked ones first (lower = better), unranked ones at the end
        list.sort(
          (a, b) =>
              (a.liveOrganicRank ?? 9999).compareTo(b.liveOrganicRank ?? 9999),
        );
      case WebsiteSort.volume:
        list.sort(
          (a, b) => (b.searchVolume ?? 0).compareTo(a.searchVolume ?? 0),
        );
      case WebsiteSort.name:
        list.sort((a, b) => a.keyword.compareTo(b.keyword));
    }

    return list;
  }

  int get inTop3 => data.websiteKeywords
      .where((k) => k.liveOrganicRank != null && k.liveOrganicRank! <= 3)
      .length;

  int get inTop10 => data.websiteKeywords
      .where((k) => k.liveOrganicRank != null && k.liveOrganicRank! <= 10)
      .length;

  double? get avgPosition {
    final ranked = data.websiteKeywords
        .where((k) => k.liveOrganicRank != null)
        .toList();
    if (ranked.isEmpty) return null;

    return ranked.fold<double>(0, (s, k) => s + k.liveOrganicRank!) /
        ranked.length;
  }

  Future<bool> addKeywords(List<String> list) async {
    if (list.isEmpty) return false;

    addError.value = '';
    isSaving.value = true;

    try {
      await SeoService.trackWebsiteKeywords(keywords: list);
      await refreshAll();
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
      await refreshAll();
    } catch (e) {
      final shortage = SeoService.tokenShortage(e);
      keywordErrors[keyword] = shortage ?? "Couldn't refresh. Try again.";
      if (shortage != null) await loadTokens();
    } finally {
      refreshingKeyword.value = null;
    }
  }

  Future<bool> untrackKeyword(String keyword) async {
    try {
      await SeoService.untrackKeyword(keyword: keyword);

      final response = intelligenceResponse.value;
      if (response != null) {
        intelligenceResponse.value = response.copyWith(
          result: data.copyWith(
            keywords: data.keywords.where((k) => k.keyword != keyword).toList(),
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('WEBSITE SEO: untrack error: $e');
      return false;
    }
  }
}
