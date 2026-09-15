import 'dart:async';

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:get/get.dart';

class LeadsController extends GetxController {
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  // ============================================================
  // TAB
  // ============================================================

  final RxInt selectedLeadTab = 0.obs;

  // ============================================================
  // SEARCH
  // ============================================================

  final RxString searchText = ''.obs;

  Timer? _searchTimer;

  // ============================================================
  // FILTERS
  // ============================================================

  final RxList<String> selectedSources = <String>[].obs;

  final RxList<String> selectedStages = <String>[].obs;

  final Rxn<DateTime> startDateTime = Rxn<DateTime>();

  final Rxn<DateTime> endDateTime = Rxn<DateTime>();

  // ============================================================
  // SOURCE OPTIONS
  // ============================================================

  final List<String> sourceOptions = [
    'eazbot',
    'webform',
    'whatsapp',
    'facebook',
    'google',
    'visitors',
  ];

  // ============================================================
  // STAGE OPTIONS
  // ============================================================

  final List<String> stageOptions = [
    'Open Queries',
    'Contacted',
    'Converted',
    'Out Of Budget',
    'Potential For Later',
    'Quotation Provided',
    'Hot',
  ];

  // ============================================================
  // TAB
  // ============================================================

  void changeLeadTab(int index) {
    selectedLeadTab.value = index;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void updateSearch(String value) {
    searchText.value = value;

    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      dashboardController.searchLeads(value);
    });
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  Future<void> clearSearch() async {
    _searchTimer?.cancel();

    searchText.value = '';

    await dashboardController.clearLeadsSearch();
  }

  // ============================================================
  // LEADS
  // ============================================================

  List<LeadModel> get allLeads {
    return dashboardController.leads;
  }

  List<LeadModel> get filteredLeads {
    switch (selectedLeadTab.value) {
      case 0:
        return allLeads;

      case 1:
        return allLeads.where((lead) {
          return lead.contact?.trim().isNotEmpty == true;
        }).toList();

      case 2:
        return allLeads.where((lead) {
          return lead.status?.toLowerCase() == 'converted';
        }).toList();

      case 3:
        return allLeads.where((lead) {
          return lead.status?.toLowerCase() == 'hot';
        }).toList();

      default:
        return allLeads;
    }
  }

  // ============================================================
  // APPLY FILTER
  // ============================================================

  Future<void> applyFilters({
    required List<String> sources,
    required List<String> stages,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    selectedSources.assignAll(sources);

    selectedStages.assignAll(stages);

    startDateTime.value = startDate;

    endDateTime.value = endDate;

    // IMPORTANT:
    // Filter API ko jayega.
    // Local filtering nahi hogi.

    await dashboardController.applyLeadFilters(
      sources: selectedSources,
      stages: selectedStages,
      startDate: startDateTime.value,
      endDate: endDateTime.value,
    );
  }

  // ============================================================
  // CLEAR FILTER
  // ============================================================

  Future<void> clearFilters() async {
    selectedSources.clear();

    selectedStages.clear();

    startDateTime.value = null;

    endDateTime.value = null;

    await dashboardController.clearLeadFilters();
  }

  // ============================================================
  // FILTER ACTIVE
  // ============================================================

  bool get hasFilters {
    return selectedSources.isNotEmpty ||
        selectedStages.isNotEmpty ||
        startDateTime.value != null ||
        endDateTime.value != null;
  }

  // ============================================================
  // LOADING
  // ============================================================

  bool get isLoading {
    return dashboardController.isLeadsLoading.value;
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Future<void> loadMoreLeads() async {
    await dashboardController.loadMoreLeads();
  }

  bool get isLoadingMore {
    return dashboardController.isLoadingMoreLeads.value;
  }

  bool get hasMore {
    return dashboardController.hasMoreLeads.value;
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshLeads() async {
    await dashboardController.refreshLeads();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    _searchTimer?.cancel();

    super.onClose();
  }
}
