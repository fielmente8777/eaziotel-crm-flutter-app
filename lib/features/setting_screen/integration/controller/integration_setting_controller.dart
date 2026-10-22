// ============================================================
// INTEGRATION SETTING CONTROLLER
//
//   Screen (widgets)  --->  this controller  --->  IntegrationSettingService  --->  API
//
// This file has 4 parts:
//   1. DATA LOAD      : which integrations are connected + Search Console
//   2. FILTER         : search box + All / Communication / Analytics tabs
//   3. SEARCH CONSOLE : save the property type + domain
//   4. BUTTONS        : Connect / Disconnect
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/gsc_settings.dart';
import '../models/integration_item.dart';
import '../services/integration_setting_service.dart';

class IntegrationSettingController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ============================================================
  // 1. DATA LOAD
  // ============================================================

  final isLoading = true.obs;

  /// null = all good. If there is text, a full-screen message + Retry.
  final errorMessage = RxnString();

  final items = <IntegrationItem>[].obs;
  final google = const GoogleConnection().obs;

  /// Saved Search Console setting
  final gsc = const GscSettings().obs;

  /// The hotel's Google Analytics property (null = GA not connected, Search Console
  /// settings cannot be saved)
  final gaPropertyId = RxnString();

  /// The browser was opened for Google login -> reload the status when the app comes back
  bool _waitingForBrowser = false;
  AppLifecycleListener? _lifecycle;

  @override
  void onInit() {
    super.onInit();

    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!_waitingForBrowser) return;

        _waitingForBrowser = false;
        load();
      },
    );

    load();
  }

  @override
  void onClose() {
    _lifecycle?.dispose();
    super.onClose();
  }

  Future<void> load() async {
    if (hid.isEmpty) {
      errorMessage.value = 'No hotel selected';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final docs = await IntegrationSettingService.getIntegrations(hid: hid);

      items.assignAll([
        for (final item in IntegrationItem.all)
          item.copyWith(connected: IntegrationItem.isOn(docs[item.apiKey])),
      ]);
    } catch (e) {
      debugPrint('INTEGRATION: load error: $e');

      errorMessage.value = 'Unable to load integrations.';
      isLoading.value = false;
      return;
    }

    // Search Console. The rest of the page shows even if this fails.
    await Future.wait([_loadGoogleStatus(), _loadSearchConsole()]);

    isLoading.value = false;
  }

  Future<void> _loadGoogleStatus() async {
    try {
      google.value = await IntegrationSettingService.getGoogleStatus(hid: hid);
    } catch (e) {
      debugPrint('INTEGRATION: google status error: $e');
    }
  }

  Future<void> _loadSearchConsole() async {
    try {
      gaPropertyId.value = await IntegrationSettingService.getGaPropertyId(
        hid: hid,
      );

      final propertyId = gaPropertyId.value;

      gsc.value = propertyId == null
          ? const GscSettings()
          : await IntegrationSettingService.getGscSettings(
              propertyId: propertyId,
            );
    } catch (e) {
      debugPrint('INTEGRATION: search console error: $e');
    }
  }

  // ============================================================
  // 2. FILTER
  // ============================================================

  final search = ''.obs;
  final category = IntegrationCategory.all.obs;

  List<IntegrationItem> get visibleItems {
    final query = search.value.trim().toLowerCase();

    return items.where((item) {
      final inTab =
          category.value == IntegrationCategory.all ||
          item.category == category.value;

      return inTab && item.title.toLowerCase().contains(query);
    }).toList();
  }

  /// The Search Console card is part of the Analytics tab
  bool get showSearchConsole {
    final inTab =
        category.value == IntegrationCategory.all ||
        category.value == IntegrationCategory.analytics;

    return inTab &&
        'search console'.contains(search.value.trim().toLowerCase());
  }

  // ============================================================
  // 3. SEARCH CONSOLE
  // ============================================================

  final isSavingGsc = false.obs;

  /// "fielmente.com", "https://fielmente.com/" -> "fielmente.com"
  static String cleanDomain(String value) => value
      .trim()
      .replaceFirst(RegExp(r'^sc-domain:'), '')
      .replaceFirst(RegExp(r'^https?://'), '')
      .replaceFirst(RegExp(r'^www\.'), '')
      .replaceFirst(RegExp(r'/+$'), '');

  /// Return: null = saved, text = error to show in the form
  Future<String?> saveSearchConsole({
    required GscPropertyType type,
    required String domain,
    required String email,
  }) async {
    final propertyId = gaPropertyId.value;

    if (propertyId == null) {
      return 'Please connect Google Analytics first.';
    }

    final cleaned = cleanDomain(domain);

    if (cleaned.isEmpty || !cleaned.contains('.')) {
      return 'Please enter a valid domain, like example.com';
    }

    if (email.trim().isNotEmpty && !GetUtils.isEmail(email.trim())) {
      return 'Please enter a valid email';
    }

    isSavingGsc.value = true;

    try {
      await IntegrationSettingService.saveGscSettings(
        body: GscSettings.saveBody(
          propertyId: propertyId,
          hid: hid,
          type: type,
          domain: cleaned,
          email: email.trim(),
        ),
      );

      gsc.value = await IntegrationSettingService.getGscSettings(
        propertyId: propertyId,
      );

      Get.snackbar(
        'Saved',
        'Search Console settings saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSavingGsc.value = false;
    }
  }

  // ============================================================
  // EXOTEL CONNECT  (form: API Key, Auth Token, Sub Domain, Account SID, Number)
  // ============================================================

  final isConnectingExotel = false.obs;

  /// Return: null = connected, text = error to show in the form
  Future<String?> connectExotel({
    required String apiKey,
    required String authToken,
    required String subDomain,
    required String accountSid,
    required String virtualNumber,
  }) async {
    final body = {
      'apiKey': apiKey.trim(),
      'authToken': authToken.trim(),
      'subDomain': subDomain.trim(),
      'accountSID': accountSid.trim(),
      'virtualNumber': virtualNumber.trim(),
    };

    if (body.values.any((value) => value.isEmpty)) {
      return 'Please fill all fields';
    }

    isConnectingExotel.value = true;

    try {
      await IntegrationSettingService.connectExotel(body: body);

      // Show "Connected" on the card
      await load();

      _message('Exotel', 'Exotel connected successfully.');
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      isConnectingExotel.value = false;
    }
  }

  // ============================================================
  // 4. BUTTONS
  //   Google Ads Connect : Google login in the browser (refresh when the app comes back)
  //   Others             : login happens in the web dashboard
  // ============================================================

  final connectingKey = RxnString();

  Future<void> onAction(IntegrationItem item) async {
    if (!item.connected && item.apiKey == 'googleAdsInsight') {
      return _connectGoogleAds(item);
    }

    _message(
      item.title,
      item.connected
          ? 'Disconnecting is not available in the app yet. Please use the web dashboard.'
          : 'Please connect ${item.title} from the web dashboard.',
    );
  }

  Future<void> _connectGoogleAds(IntegrationItem item) async {
    final ndid = dashboard.user.value?.profile.ndid ?? '';

    if (ndid.isEmpty || connectingKey.value != null) return;

    connectingKey.value = item.apiKey;

    try {
      final url = await IntegrationSettingService.getGoogleAdsAuthUrl(
        ndid: ndid,
      );

      _waitingForBrowser = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!_waitingForBrowser) _message(item.title, 'Unable to open Google.');
    } catch (e) {
      debugPrint('INTEGRATION: google ads connect error: $e');
      _message(item.title, 'Unable to start Google login. Please try again.');
    } finally {
      connectingKey.value = null;
    }
  }

  void _message(String title, String text) {
    Get.snackbar(title, text, snackPosition: SnackPosition.BOTTOM);
  }
}
