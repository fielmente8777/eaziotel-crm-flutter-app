// ============================================================
// SUBSCRIPTION CONTROLLER
//
//   Screen  --->  ye controller  --->  SubscriptionService  --->  API
// ============================================================

import 'package:eazotel/features/setting_screen/subscription/controller/services/Subscription_services.dart';
import 'package:eazotel/features/setting_screen/subscription/model/subscription_model.dart';
import 'package:eazotel/features/setting_screen/subscription/screen/subscription_plans_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  final isLoading = true.obs;

  /// null = sab theek. Text ho to wahi message dikhta hai.
  final errorMessage = RxnString();

  final data = Rxn<SubscriptionResponseModel>();

  SubscriptionModel? get subscription => data.value?.subscription;

  List<PaymentModel> get payments => data.value?.payments ?? [];

  // ---------- Payment list: pehle 10, "Show more" par aur ----------
  static const int _pageSize = 10;

  final visibleCount = _pageSize.obs;

  List<PaymentModel> get visiblePayments =>
      payments.take(visibleCount.value).toList();

  bool get hasMorePayments => visibleCount.value < payments.length;

  void showMorePayments() {
    visibleCount.value = (visibleCount.value + _pageSize).clamp(
      0,
      payments.length,
    );
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      data.value = await SubscriptionService.getMySubscription();
      visibleCount.value = _pageSize;
    } catch (e) {
      debugPrint('SUBSCRIPTION: load error: $e');
      errorMessage.value = 'Unable to load subscription. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ---------- Plan / apps khareedna (web ke Billing page jaisa) ----------

  /// Plans & billing screen kholo; wapas aane par subscription taaza
  Future<void> upgradePlan() async {
    await Get.to(() => const SubscriptionPlansScreen());
    load();
  }

  void manageBilling() => upgradePlan();
}
