// ============================================================
// EMAIL MARKETING CONTROLLER
//
//   Recipients : email list (search + page)
//   Campaigns  : bheje gaye email (page) + stats
//   Templates  : API abhi nahi mili
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/marketing_models.dart';
import '../services/marketing_service.dart';

enum EmailSection {
  recipients('Recipients'),
  campaigns('Campaigns'),
  templates('Templates');

  const EmailSection(this.label);

  final String label;
}

class EmailMarketingController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  final section = EmailSection.recipients.obs;

  @override
  void onInit() {
    super.onInit();

    loadRecipients(1);
    loadCampaigns(1);
  }

  // ============================================================
  // RECIPIENTS
  // ============================================================

  final recipients = <EmailRecipient>[].obs;
  final recipientPage = const MarketingPage().obs;
  final isRecipientsLoading = true.obs;
  final recipientsError = RxnString();
  final recipientSearch = ''.obs;

  List<EmailRecipient> get visibleRecipients {
    final query = recipientSearch.value.trim().toLowerCase();

    return recipients
        .where(
          (r) =>
              query.isEmpty ||
              r.name.toLowerCase().contains(query) ||
              r.email.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadRecipients(int page) async {
    if (hid.isEmpty) return;

    isRecipientsLoading.value = true;
    recipientsError.value = null;

    try {
      final result = await MarketingService.getEmailRecipients(
        hid: hid,
        page: page,
      );

      recipients.assignAll(result.items);
      recipientPage.value = result.page;
    } catch (e) {
      debugPrint('EMAIL MARKETING: recipients error: $e');
      recipientsError.value = 'Unable to load recipients.';
    } finally {
      isRecipientsLoading.value = false;
    }
  }

  // ============================================================
  // CAMPAIGNS
  // ============================================================

  final campaigns = <EmailCampaign>[].obs;
  final campaignPage = const MarketingPage().obs;
  final isCampaignsLoading = true.obs;
  final campaignsError = RxnString();

  Future<void> loadCampaigns(int page) async {
    if (hid.isEmpty) return;

    isCampaignsLoading.value = true;
    campaignsError.value = null;

    try {
      final result = await MarketingService.getEmailCampaigns(
        hid: hid,
        page: page,
      );

      campaigns.assignAll(result.items);
      campaignPage.value = result.page;
    } catch (e) {
      debugPrint('EMAIL MARKETING: campaigns error: $e');
      campaignsError.value = 'Unable to load campaigns.';
    } finally {
      isCampaignsLoading.value = false;
    }
  }
}
