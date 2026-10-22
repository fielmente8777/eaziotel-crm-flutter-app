// ============================================================
// WHATSAPP MARKETING CONTROLLER
//
//   1. CAMPAIGN LIST   : all campaigns + All / Sent / Scheduled / In Progress
//   2. CAMPAIGN DETAIL : numbers of one campaign (page by page) + filter + search
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/marketing_models.dart';
import '../services/marketing_service.dart';

enum CampaignFilter {
  all('All'),
  sent('Sent'),
  scheduled('Scheduled'),
  inProgress('In Progress');

  const CampaignFilter(this.label);

  final String label;

  bool matches(String status) => switch (this) {
    CampaignFilter.all => true,
    CampaignFilter.sent => status == 'completed' || status == 'sent',
    CampaignFilter.scheduled => status == 'scheduled',
    CampaignFilter.inProgress => status == 'in-progress' || status == 'running',
  };
}

class WhatsappMarketingController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ============================================================
  // 1. CAMPAIGN LIST
  // ============================================================

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final campaigns = <WhatsappCampaign>[].obs;
  final filter = CampaignFilter.all.obs;

  /// Search by campaign or template name
  final search = ''.obs;

  List<WhatsappCampaign> get visibleCampaigns {
    final query = search.value.trim().toLowerCase();

    return campaigns
        .where(
          (c) =>
              filter.value.matches(c.status) &&
              (query.isEmpty ||
                  c.name.toLowerCase().contains(query) ||
                  c.templateName.toLowerCase().contains(query)),
        )
        .toList();
  }

  // ============================================================
  // SUMMARY (total of all campaigns, same as web)
  // ============================================================

  int get totalSent => campaigns.fold(0, (sum, c) => sum + c.sent);

  int get totalDelivered => campaigns.fold(0, (sum, c) => sum + c.delivered);

  int get totalRead => campaigns.fold(0, (sum, c) => sum + c.read);

  /// How many of the sent ones were delivered (%)
  int get deliveryRate =>
      totalSent == 0 ? 0 : (totalDelivered * 100 / totalSent).round();

  /// How many of the delivered ones were read (%)
  int get readRate =>
      totalDelivered == 0 ? 0 : (totalRead * 100 / totalDelivered).round();

  @override
  void onInit() {
    super.onInit();
    load();
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
      final list = await MarketingService.getWhatsappCampaigns(hid: hid);

      // Newest first
      list.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      campaigns.assignAll(list);
    } catch (e) {
      debugPrint('WHATSAPP MARKETING: load error: $e');
      errorMessage.value = 'Unable to load campaigns.';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 2. CAMPAIGN DETAIL
  // ============================================================

  static const int pageSize = 10;

  final detail = Rxn<WhatsappCampaign>();
  final recipients = <CampaignRecipient>[].obs;
  final recipientPage = const MarketingPage().obs;
  final isDetailLoading = false.obs;
  final detailError = RxnString();

  /// '' = All, otherwise sent / delivered / read / failed
  final recipientFilter = ''.obs;
  final recipientSearch = ''.obs;

  String? _openId;

  Future<void> openCampaign(WhatsappCampaign campaign) async {
    _openId = campaign.id;
    detail.value = campaign;
    recipients.clear();
    recipientFilter.value = '';
    recipientSearch.value = '';

    await loadRecipients(1);
  }

  Future<void> loadRecipients(int page) async {
    final id = _openId;
    if (id == null) return;

    isDetailLoading.value = true;
    detailError.value = null;

    try {
      final result = await MarketingService.getCampaignDetail(
        id: id,
        page: page,
        limit: pageSize,
      );

      // Meanwhile another campaign was opened
      if (id != _openId) return;

      detail.value = result.campaign;
      recipients.assignAll(result.recipients);
      recipientPage.value = result.page;
    } catch (e) {
      debugPrint('WHATSAPP MARKETING: detail error: $e');
      if (id == _openId) detailError.value = 'Unable to load recipients.';
    } finally {
      if (id == _openId) isDetailLoading.value = false;
    }
  }

  /// Numbers on this page, after filter + search
  List<CampaignRecipient> get visibleRecipients {
    final query = recipientSearch.value.trim().toLowerCase();

    return recipients.where((r) {
      final inFilter =
          recipientFilter.value.isEmpty || r.status == recipientFilter.value;

      final inSearch =
          query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.phone.contains(query);

      return inFilter && inSearch;
    }).toList();
  }

  /// How many numbers of each status on this page (for the filter chips)
  int countOf(String status) =>
      recipients.where((r) => r.status == status).length;
}
