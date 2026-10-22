// ============================================================
// WHATSAPP CREDITS CONTROLLER
//
// The "brain" of the Settings > WhatsApp > Credits & Usage page.
//
//   Screen (widgets)  --->  this controller  --->  WhatsappSettingService  --->  API
//
// The page has two tabs:
//   Overview      : wallet, free messages, this month's usage   (billing API)
//   Transactions  : list of recharges, page by page              (transactions API)
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/whatsapp_billing.dart';
import '../services/whatsapp_setting_service.dart';

/// The two tabs of the Credits & Usage page
enum CreditsTab {
  overview('Overview'),
  transactions('Transactions');

  const CreditsTab(this.label);

  final String label;
}

class WhatsappCreditsController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  /// Which tab is open now
  final selectedTab = CreditsTab.overview.obs;

  @override
  void onInit() {
    super.onInit();

    loadBilling();
    loadTransactions(page: 1);
  }

  // ============================================================
  // 1. OVERVIEW (wallet + usage)
  // ============================================================

  final isBillingLoading = true.obs;

  /// null = all good. If there is text, Overview shows that message.
  final billingError = RxnString();

  /// null = data has not come yet
  final billing = Rxn<WhatsappBilling>();

  /// Runs when the page opens and on the refresh button
  Future<void> loadBilling() async {
    isBillingLoading.value = true;
    billingError.value = null;

    try {
      final json = await WhatsappSettingService.getBilling(hid: hid);

      billing.value = WhatsappBilling.fromJson(json);
    } catch (e) {
      debugPrint('WHATSAPP CREDITS: billing error: $e');

      billingError.value = 'Unable to load credits. Please try again.';
    } finally {
      isBillingLoading.value = false;
    }
  }

  /// The payment (Razorpay) API for "Add Credits" has not been found yet
  void addCredits() {
    Get.snackbar(
      'Not connected yet',
      'Adding credits needs the payment API. The screen is ready.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ============================================================
  // 2. TRANSACTIONS (list of recharges)
  // ============================================================

  /// How many entries per page
  static const int _pageSize = 10;

  final isTransactionsLoading = true.obs;

  final transactionsError = RxnString();

  /// The page shown now (items + page number + total)
  final transactions = const WhatsappTransactionPage().obs;

  Future<void> loadTransactions({required int page}) async {
    isTransactionsLoading.value = true;
    transactionsError.value = null;

    try {
      final json = await WhatsappSettingService.getTransactions(
        hid: hid,
        page: page,
        limit: _pageSize,
      );

      transactions.value = WhatsappTransactionPage.fromJson(json);
    } catch (e) {
      debugPrint('WHATSAPP CREDITS: transactions error: $e');

      transactionsError.value =
          'Unable to load transactions. Please try again.';
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  bool get hasPreviousPage => transactions.value.page > 1;

  bool get hasNextPage =>
      transactions.value.page < transactions.value.totalPages;

  void previousPage() {
    if (hasPreviousPage) loadTransactions(page: transactions.value.page - 1);
  }

  void nextPage() {
    if (hasNextPage) loadTransactions(page: transactions.value.page + 1);
  }

  /// "Showing 1–4 of 4"
  String get showingLabel {
    final current = transactions.value;

    if (current.total == 0) return 'No transactions';

    final first = (current.page - 1) * _pageSize + 1;
    final last = first + current.items.length - 1;

    return 'Showing $first–$last of ${current.total}';
  }
}
