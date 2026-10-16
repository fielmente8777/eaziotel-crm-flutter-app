// ============================================================
// EMAIL MARKETING CONTROLLER  (web dashboard ke "EazoMail" jaisa)
//
//   Recipients : leads ki email list (server par search + page)
//                select karo (ek-ek / poora page / search ke saare)
//                -> "recipient batch" banta hai -> Compose -> bhejo
//   Campaigns  : bheje gaye email + stats, tap = detail
//   Templates  : saved / AI se bane email (search, preview, delete)
// ============================================================

import 'dart:async';

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

/// Bhejne ke liye taiyaar log (server ka batch)
typedef RecipientBatch = ({String batchId, int count});

class EmailMarketingController extends GetxController {
  static const int recipientPageSize = 50;

  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  final section = EmailSection.recipients.obs;

  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();

    loadRecipients(1);
    loadCampaigns(1);
    loadTemplates(1);
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    _templateTimer?.cancel();
    super.onClose();
  }

  // ============================================================
  // RECIPIENTS
  // ============================================================

  final recipients = <EmailRecipient>[].obs;
  final recipientPage = const MarketingPage().obs;
  final isRecipientsLoading = true.obs;
  final recipientsError = RxnString();
  final recipientSearch = ''.obs;

  /// Purana naam (screen me use hota hai). Search ab server karta hai.
  List<EmailRecipient> get visibleRecipients => recipients;

  /// Search likhte hi nahi, ruk kar (0.4 sec) server se poochho
  void searchRecipients(String value) {
    recipientSearch.value = value;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      clearSelection();
      loadRecipients(1);
    });
  }

  Future<void> loadRecipients(int page) async {
    if (hid.isEmpty) return;

    isRecipientsLoading.value = true;
    recipientsError.value = null;

    try {
      final result = await MarketingService.getEmailRecipients(
        hid: hid,
        page: page,
        limit: recipientPageSize,
        search: recipientSearch.value,
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
  // SELECTION
  // ============================================================

  final selectedIds = <String>{}.obs;

  /// true = search ke SAARE log chune (sirf is page ke nahi)
  final allMatching = false.obs;

  final isPreparing = false.obs;

  int get selectedCount =>
      allMatching.value ? recipientPage.value.total : selectedIds.length;

  bool isSelected(EmailRecipient r) =>
      allMatching.value || selectedIds.contains(r.id);

  bool get isPageSelected =>
      recipients.isNotEmpty &&
      recipients.every((r) => allMatching.value || selectedIds.contains(r.id));

  /// "Select all N matching" dikhana hai? (poora page chuna, par aur bhi hain)
  bool get canSelectAllMatching =>
      isPageSelected &&
      !allMatching.value &&
      recipientPage.value.total > recipients.length;

  void toggle(EmailRecipient r) {
    if (allMatching.value || r.id.isEmpty) return;
    selectedIds.contains(r.id)
        ? selectedIds.remove(r.id)
        : selectedIds.add(r.id);
  }

  void togglePage() {
    final ids = recipients.map((r) => r.id).where((id) => id.isNotEmpty);

    if (isPageSelected) {
      allMatching.value = false;
      selectedIds.removeAll(ids);
    } else {
      selectedIds.addAll(ids);
    }
  }

  void selectAllMatching() => allMatching.value = true;

  void clearSelection() {
    allMatching.value = false;
    selectedIds.clear();
  }

  /// Chune hue logon ka batch. Galti ho to [onError].
  Future<RecipientBatch?> prepareSelected({
    required void Function(String) onError,
  }) async {
    if (selectedCount == 0) {
      onError('Select at least one recipient first.');
      return null;
    }

    return _prepare(
      () => allMatching.value
          ? MarketingService.createBatchFromSearch(
              hid: hid,
              search: recipientSearch.value,
            )
          : MarketingService.createBatchFromLeads(
              hid: hid,
              leadIds: selectedIds.toList(),
            ),
      fallbackCount: selectedCount,
      onError: onError,
    );
  }

  /// Excel / haath se likhe email ka batch
  Future<RecipientBatch?> prepareEmails(
    List<String> emails, {
    required void Function(String) onError,
  }) => _prepare(
    () => MarketingService.createBatchFromEmails(hid: hid, emails: emails),
    fallbackCount: emails.length,
    onError: onError,
  );

  Future<RecipientBatch?> _prepare(
    Future<RecipientBatch> Function() call, {
    required int fallbackCount,
    required void Function(String) onError,
  }) async {
    if (isPreparing.value) return null;
    isPreparing.value = true;

    try {
      final batch = await call();

      if (batch.batchId.isEmpty) {
        onError('Could not prepare recipients for this email.');
        return null;
      }

      return (
        batchId: batch.batchId,
        count: batch.count > 0 ? batch.count : fallbackCount,
      );
    } catch (e) {
      onError(
        MarketingService.errorText(
          e,
          'Could not prepare recipients for this email.',
        ),
      );
      return null;
    } finally {
      isPreparing.value = false;
    }
  }

  /// Email chala gaya: selection hatao, campaign list taaza karo
  void onSent() {
    clearSelection();
    loadCampaigns(1);
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

  // ============================================================
  // CAMPAIGN DETAIL (ek campaign + uske recipients, status se filter)
  // ============================================================

  final detail = Rxn<EmailCampaign>();
  final detailRecipients = <EmailCampaignRecipient>[].obs;
  final detailPage = const MarketingPage().obs;
  final isDetailLoading = false.obs;
  final detailError = RxnString();

  /// '' = All, warna pending / sent / failed / opened / clicked
  final detailStatus = ''.obs;

  String? _openCampaignId;

  Future<void> openCampaign(EmailCampaign campaign) async {
    _openCampaignId = campaign.id;
    detail.value = campaign;
    detailRecipients.clear();
    detailStatus.value = '';

    // Poora campaign (HTML ke saath) + pehla page
    unawaited(_loadCampaign(campaign.id));
    await loadDetailRecipients(1);
  }

  Future<void> _loadCampaign(String id) async {
    if (id.isEmpty) return;

    try {
      final full = await MarketingService.getEmailCampaign(hid: hid, id: id);
      if (full != null && id == _openCampaignId) detail.value = full;
    } catch (e) {
      debugPrint('EMAIL MARKETING: campaign detail error: $e');
    }
  }

  void changeDetailStatus(String status) {
    detailStatus.value = status;
    loadDetailRecipients(1);
  }

  Future<void> loadDetailRecipients(int page) async {
    final id = _openCampaignId;
    if (id == null || id.isEmpty) return;

    isDetailLoading.value = true;
    detailError.value = null;

    try {
      final result = await MarketingService.getEmailCampaignRecipients(
        hid: hid,
        id: id,
        page: page,
        status: detailStatus.value,
      );

      if (id != _openCampaignId) return;

      detailRecipients.assignAll(result.items);
      detailPage.value = result.page;
    } catch (e) {
      debugPrint('EMAIL MARKETING: campaign recipients error: $e');
      if (id == _openCampaignId) {
        detailError.value = 'Unable to load recipients.';
      }
    } finally {
      if (id == _openCampaignId) isDetailLoading.value = false;
    }
  }

  // ============================================================
  // TEMPLATES
  // ============================================================

  final templates = <EmailTemplate>[].obs;
  final templatePage = const MarketingPage().obs;
  final isTemplatesLoading = true.obs;
  final templatesError = RxnString();
  final templateSearch = ''.obs;
  final deletingTemplateId = ''.obs;

  Timer? _templateTimer;

  void searchTemplates(String value) {
    templateSearch.value = value;
    _templateTimer?.cancel();
    _templateTimer = Timer(
      const Duration(milliseconds: 400),
      () => loadTemplates(1),
    );
  }

  Future<void> loadTemplates(int page) async {
    if (hid.isEmpty) return;

    isTemplatesLoading.value = true;
    templatesError.value = null;

    try {
      final result = await MarketingService.getEmailTemplates(
        hid: hid,
        page: page,
        search: templateSearch.value,
      );

      templates.assignAll(result.items);
      templatePage.value = result.page;
    } catch (e) {
      debugPrint('EMAIL MARKETING: templates error: $e');
      templatesError.value = 'Unable to load templates.';
    } finally {
      isTemplatesLoading.value = false;
    }
  }

  Future<bool> deleteTemplate(
    EmailTemplate template, {
    required void Function(String) onError,
  }) async {
    deletingTemplateId.value = template.id;

    try {
      await MarketingService.deleteEmailTemplate(hid: hid, id: template.id);
      templates.removeWhere((t) => t.id == template.id);

      // Page khali ho gaya to pichhla page
      final page = templatePage.value;
      final next = templates.isEmpty && page.page > 1
          ? page.page - 1
          : page.page;
      unawaited(loadTemplates(next));
      return true;
    } catch (e) {
      onError(MarketingService.errorText(e, 'Could not delete the template.'));
      return false;
    } finally {
      deletingTemplateId.value = '';
    }
  }
}
