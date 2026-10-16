import 'package:eazotel/core/api/apiexception/api_error_handler.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/leads/models/leads_responce_modle.dart';
import 'package:eazotel/features/leads/services/leads_api_service.dart';
import 'package:get/get.dart';

// Leads part of DashboardController: list, pagination, search and filters.
// (Leads feature ka hissa; Home par "Recent Leads" bhi isi se aate hain)
mixin DashboardLeadsMixin on GetxController {
  // Leads ki API (features/leads/services)
  final LeadsApiService leadsApiService = LeadsApiService();

  // Provided by DashboardController
  RxString get selectedHotelId;

  // ============================================================
  // LOADING
  // ============================================================

  final isLeadsLoading = false.obs;
  final isLoadingMoreLeads = false.obs;

  // ============================================================
  // LEADS
  // ============================================================

  final selectedLead = Rxn<LeadModel>();

  final leadResponse = Rxn<LeadResponseModel>();
  final leads = <LeadModel>[].obs;

  final leadsPage = 0.obs;
  final leadsSearch = ''.obs;
  final hasMoreLeads = true.obs;

  final int leadsLimit = 20;

  // ============================================================
  // LEAD FILTERS
  // ============================================================

  final leadsSources = <String>[].obs;
  final leadsStages = <String>[].obs;

  final leadsStartDate = Rxn<DateTime>();
  final leadsEndDate = Rxn<DateTime>();

  // ============================================================
  // GET LEADS
  // ============================================================

  Future<void> getLeads(String hotelId, {bool reset = false}) async {
    if (hotelId.isEmpty) {
      return;
    }

    // Reset pagination
    if (reset) {
      leadsPage.value = 0;
      hasMoreLeads.value = true;
      leads.clear();
    }

    // Prevent duplicate calls
    if (isLeadsLoading.value ||
        isLoadingMoreLeads.value ||
        !hasMoreLeads.value) {
      return;
    }

    final isFirstPage = leadsPage.value == 0;

    try {
      if (isFirstPage) {
        isLeadsLoading.value = true;
      } else {
        isLoadingMoreLeads.value = true;
      }

      final page = leadsPage.value + 1;

      final result = await leadsApiService.getLeads(
        hotelId: hotelId,
        page: page,
        limit: leadsLimit,
        search: leadsSearch.value,
        sources: leadsSources,
        stages: leadsStages,
        startDate: leadsStartDate.value,
        endDate: leadsEndDate.value,
      );

      leadResponse.value = result;

      final loadedLeads = result.result?.docs?.leads ?? [];

      // First page
      if (isFirstPage) {
        leads.assignAll(loadedLeads);
      }
      // Next pages
      else {
        leads.addAll(loadedLeads);
      }

      // Check more pages
      if (loadedLeads.length < leadsLimit) {
        hasMoreLeads.value = false;
      }

      // Update page
      if (loadedLeads.isNotEmpty) {
        leadsPage.value++;
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(e);
    } catch (e) {
      // Handle unexpected error
    } finally {
      isLeadsLoading.value = false;
      isLoadingMoreLeads.value = false;
    }
  }

  // ============================================================
  // LOAD MORE LEADS
  // ============================================================

  Future<void> loadMoreLeads() async {
    if (selectedHotelId.value.isEmpty) {
      return;
    }

    if (!hasMoreLeads.value) {
      return;
    }

    if (isLeadsLoading.value || isLoadingMoreLeads.value) {
      return;
    }

    await getLeads(selectedHotelId.value);
  }

  // ============================================================
  // SEARCH LEADS
  // ============================================================

  Future<void> searchLeads(String value) async {
    leadsSearch.value = value.trim();

    await getLeads(selectedHotelId.value, reset: true);
  }

  Future<void> clearLeadsSearch() async {
    leadsSearch.value = '';

    await getLeads(selectedHotelId.value, reset: true);
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Future<void> applyLeadFilters({
    required List<String> sources,
    required List<String> stages,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    leadsSources.assignAll(sources);
    leadsStages.assignAll(stages);

    leadsStartDate.value = startDate;
    leadsEndDate.value = endDate;

    await getLeads(selectedHotelId.value, reset: true);
  }

  Future<void> clearLeadFilters() async {
    resetLeadFilters();

    // Search remains active
    await getLeads(selectedHotelId.value, reset: true);
  }

  // Clears the filter values only, does not reload
  void resetLeadFilters() {
    leadsSources.clear();
    leadsStages.clear();

    leadsStartDate.value = null;
    leadsEndDate.value = null;
  }

  bool get hasLeadFilters {
    return leadsSources.isNotEmpty ||
        leadsStages.isNotEmpty ||
        leadsStartDate.value != null ||
        leadsEndDate.value != null;
  }

  // ============================================================
  // REFRESH LEADS
  // ============================================================

  Future<void> refreshLeads() async {
    if (selectedHotelId.value.isEmpty) {
      return;
    }

    await getLeads(selectedHotelId.value, reset: true);
  }

  // ============================================================
  // CLEAR LEADS DATA
  // ============================================================

  void clearLeadsData() {
    leads.clear();
    leadResponse.value = null;
    selectedLead.value = null;

    leadsPage.value = 0;
    hasMoreLeads.value = true;

    leadsSearch.value = '';
    resetLeadFilters();

    isLeadsLoading.value = false;
    isLoadingMoreLeads.value = false;
  }
}
