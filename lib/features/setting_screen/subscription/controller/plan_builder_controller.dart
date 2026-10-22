// ============================================================
// PLAN BUILDER CONTROLLER  (like the web Billing page)
//
//   1. Base plan     : BASIC / PRO (ENTERPRISE = talk to sales)
//   2. Add-on apps   : already purchased ones -> "Purchased"
//   3. Team seats    : ₹500 / seat / mahina
//   4. Billing cycle : Monthly 5% | Quarterly 10% | 6 Months 15% | Yearly 40%
//   Total = (plan + new apps + seats) × months − discount + 18% GST
//
//   Pay -> create-order -> Razorpay -> verify-payment -> subscription taaza
//
// Razorpay works only on Android / iOS. The key comes from a config file,
// like the web dashboard: lib/core/config/app_env.dart (like env.js)
// ============================================================

import 'dart:io';

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/setting_screen/whatsapp/models/whatsapp_action_response.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/config/app_env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../model/billing_models.dart';
import '../model/subscription_model.dart';
import 'services/billing_service.dart';
import 'subscription_controller.dart';

class PlanBuilderController extends GetxController {
  static const int teamSeatPrice = 500;
  static const int gstPercent = 18;
  static const String salesWhatsappUrl = 'https://wa.me/+919501868775';

  /// Razorpay key: the one from the web Billing page (app_env.dart)
  static const String razorpayKey = AppEnv.razorpayBillingKeyId;

  final SubscriptionController subscriptionController =
      Get.isRegistered<SubscriptionController>()
      ? Get.find<SubscriptionController>()
      : Get.put(SubscriptionController());

  SubscriptionModel? get subscription => subscriptionController.subscription;

  // ============================================================
  // DATA
  // ============================================================

  final plans = <BillingPlan>[].obs;
  final apps = <BillingApp>[].obs;
  final isLoading = true.obs;
  final loadError = false.obs;

  // ============================================================
  // CHOICES
  // ============================================================

  final selectedPlan = Rxn<BillingPlan>();

  /// The current plan (not charged again). A new plan was chosen -> null
  final activePlanId = RxnString();

  final selectedAppIds = <String>{}.obs;
  final teamCount = 0.obs;
  final cycle = BillingCycle.month.obs;
  final isProcessing = false.obs;

  Razorpay? _razorpay;

  /// What was sent when payment started (verify needs the same)
  ({String planId, List<String> appIds, int validFor})? _pending;

  @override
  void onInit() {
    super.onInit();
    cycle.value = _defaultCycle();
    load();
  }

  @override
  void onClose() {
    _razorpay?.clear();
    super.onClose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = false;

    try {
      final result = await BillingService.getPlans();
      plans.assignAll(result.plans);
      apps.assignAll(result.apps);

      // The current plan + purchased apps are pre-selected
      final current = subscription?.plan.id ?? '';
      selectedPlan.value = plans.firstWhereOrNull((p) => p.id == current);
      // Renew: the plan is charged (the current plan is not counted)
      activePlanId.value = current.isEmpty || isRenewal ? null : current;
      selectedAppIds
        ..clear()
        ..addAll(
          (subscription?.apps ?? const <SubscriptionAppModel>[])
              .map((a) => a.appId)
              .where((id) => id.isNotEmpty),
        );
    } catch (e) {
      debugPrint('PLAN BUILDER: load error: $e');
      loadError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================

  /// Paid plans (same as web: plans with price 0 are not shown)
  List<BillingPlan> get visiblePlans =>
      plans.where((p) => p.price > 0 || p.isEnterprise).toList();

  int get remainingDays {
    final end = subscription?.endDate;
    if (end == null) return 0;
    final days = end.difference(DateTime.now()).inHours / 24;
    return days <= 0 ? 0 : days.ceil();
  }

  /// Same as web: cycle starting from the remaining days
  BillingCycle _defaultCycle() {
    final months = (remainingDays / 30).floor().clamp(1, 1 << 20);
    if (months == 1) return BillingCycle.month;
    if (months == 3) return BillingCycle.quarter;
    return BillingCycle.sixMonth;
  }

  bool isPurchasedApp(String appId) =>
      (subscription?.apps ?? const <SubscriptionAppModel>[]).any(
        (a) => a.appId == appId,
      );

  /// This plan is active now (and has not expired)
  bool isPurchasedPlan(String planId) {
    final s = subscription;
    final end = s?.endDate;
    return s != null &&
        s.plan.id == planId &&
        end != null &&
        end.isAfter(DateTime.now());
  }

  Iterable<String> get _purchasedIds =>
      purchasedApps.map((a) => a.appId).where((id) => id.isNotEmpty);

  bool get appsLocked => selectedPlan.value == null;

  bool get isCurrentPlan =>
      selectedPlan.value != null &&
      selectedPlan.value!.id == activePlanId.value;

  /// New apps (not purchased before)
  /// Plan expired (or there is none): previously bought add-ons must be bought
  /// again, so they are also counted in the "add-on" list
  bool get isRenewal => remainingDays == 0;

  /// Add-ons taken in this order. On renew, the purchased ones too (the user can
  /// remove them), otherwise only new ones.
  List<BillingApp> get newApps => apps
      .where(
        (a) =>
            selectedAppIds.contains(a.id) &&
            (isRenewal || !isPurchasedApp(a.id)),
      )
      .toList();

  List<SubscriptionAppModel> get purchasedApps =>
      subscription?.apps ?? const <SubscriptionAppModel>[];

  num get teamCost => teamCount.value * teamSeatPrice;

  num get appsTotal => newApps.fold<num>(0, (sum, a) => sum + a.price);

  num get subtotal {
    final plan = selectedPlan.value;
    if (plan == null) return 0;
    return ((isCurrentPlan ? 0 : plan.price) + appsTotal + teamCost) *
        cycle.value.months;
  }

  num get discountAmount => subtotal * cycle.value.discount / 100;

  num get gstAmount => (subtotal - discountAmount) * gstPercent / 100;

  num get total => subtotal - discountAmount + gstAmount;

  /// Same as web: at least one new app is needed
  /// Renew: the plan alone is fine. Otherwise (same as web) at least one new app.
  bool get canPay =>
      !isProcessing.value &&
      (isRenewal ? selectedPlan.value != null : newApps.isNotEmpty);

  // ============================================================
  // ACTIONS
  // ============================================================

  void selectPlan(BillingPlan plan) {
    if (plan.isEnterprise || isPurchasedPlan(plan.id)) return;

    // Same as web: new plan -> choose apps again, the full plan price is charged
    selectedAppIds.clear();
    activePlanId.value = null;
    selectedPlan.value = plan;

    // Renew: previously bought add-ons are back in the list (the user can remove them)
    if (isRenewal) selectedAppIds.addAll(_purchasedIds);
  }

  void toggleApp(BillingApp app) {
    // An app bought in the current plan cannot be removed; on renew anything goes
    if (appsLocked || (!isRenewal && isPurchasedApp(app.id))) return;
    selectedAppIds.contains(app.id)
        ? selectedAppIds.remove(app.id)
        : selectedAppIds.add(app.id);
  }

  void changeTeam(int delta) =>
      teamCount.value = (teamCount.value + delta).clamp(0, 999);

  // ============================================================
  // PAY
  // ============================================================

  static bool get paymentSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> pay() async {
    final plan = selectedPlan.value;
    if (!canPay || plan == null) return;

    if (!paymentSupported) {
      _toast(
        'Pay from the mobile app',
        'Payments open in Razorpay, which works on Android and iOS. '
            'Please complete this purchase from your phone.',
      );
      return;
    }

    isProcessing.value = true;

    final appIds = newApps.map((a) => a.id).toList();
    final months = cycle.value.months;

    try {
      final order = await BillingService.createOrder(
        planId: plan.id,
        appIds: appIds,
        validFor: months,
        discount: cycle.value.discount,
        teamCount: teamCount.value,
        teamCost: teamCost,
        gst: gstPercent,
      );

      // Key: the server's if it sent one, otherwise the one from .env (at build time)
      final key = order.keyId.isNotEmpty ? order.keyId : razorpayKey;
      if (key.isEmpty) {
        isProcessing.value = false;
        _toast(
          'Payment is not set up',
          'The Razorpay key is missing (lib/core/config/app_env.dart).',
          error: true,
        );
        return;
      }

      _pending = (planId: plan.id, appIds: appIds, validFor: months);

      _razorpay ??= Razorpay()
        ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
        ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
        ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);

      _razorpay!.open({
        'key': key,
        'amount': order.amountInPaise,
        'currency': 'INR',
        'name': 'Eazotel Technologies Pvt Ltd',
        'description': '${plan.name} plan',
        'order_id': order.orderId,
        'theme': {'color': '#152547'},
      });
    } catch (e) {
      isProcessing.value = false;
      _toast(
        'Could not start payment',
        _errorText(e, 'Something went wrong. Please try again.'),
        error: true,
      );
    }
  }

  Future<void> _onSuccess(PaymentSuccessResponse r) async {
    final pending = _pending;
    try {
      if (pending == null) throw Exception('Missing order details');

      await BillingService.verifyPayment(
        paymentId: r.paymentId ?? '',
        orderId: r.orderId ?? '',
        signature: r.signature ?? '',
        validFor: pending.validFor,
        planId: pending.planId,
        appIds: pending.appIds,
      );

      _toast('Payment successful', 'Your plan has been updated.');

      // Show the new plan / apps
      await subscriptionController.load();

      // If it was the plan-expired screen, the dashboard checks again (so it opens)
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().getUser();
      }
      await load();
    } catch (e) {
      debugPrint('PLAN BUILDER: verify error: $e');
      _toast(
        'Payment received, not confirmed yet',
        'Your payment went through but we could not confirm it yet. '
            'Please contact support with payment ID ${r.paymentId ?? ''}.',
        error: true,
      );
    } finally {
      _pending = null;
      isProcessing.value = false;
    }
  }

  void _onError(PaymentFailureResponse r) {
    _pending = null;
    isProcessing.value = false;

    // Closed by the user, so do not show an error
    if (r.code == Razorpay.PAYMENT_CANCELLED) return;

    _toast(
      'Payment failed',
      (r.message ?? '').trim().isEmpty ? 'Please try again.' : r.message!,
      error: true,
    );
  }

  void _onWallet(ExternalWalletResponse r) {
    _toast(
      'Opening ${r.walletName ?? 'wallet'}',
      'Complete the payment there.',
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _errorText(Object e, String fallback) {
    if (e is ApiException) return WhatsappActionResponse.errorOf(e, fallback);
    final text = '$e'.replaceFirst('Exception: ', '').trim();
    return text.isEmpty || text.length > 200 ? fallback : text;
  }

  void _toast(String title, String message, {bool error = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      backgroundColor: error ? const Color(0xFFEF4444) : null,
      colorText: error ? Colors.white : null,
      duration: const Duration(seconds: 4),
    );
  }
}
