import 'package:eazotel/core/api/apiexception/api_error_handler.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/analytics_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/services/dashboard_api_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  // API service
  final DashboardApiService apiService = DashboardApiService();

  // ============================================================
  // LOADING
  // ============================================================

  final isLoading = false.obs;
  final isLeadsLoading = false.obs;
  final isLoadingMoreLeads = false.obs;
  final isAnalyticsLoading = false.obs;

  // ============================================================
  // USER
  // ============================================================

  final userNameResponse = Rxn<UserResponseModel>();
  final user = Rxn<ProfileResponseModel>();

  // ============================================================
  // HOTEL
  // ============================================================

  final selectedHotelId = ''.obs;

  static const String hotelIdKey = 'selected_hotel_id';

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
  // ANALYTICS
  // ============================================================

  final analyticsResponse = Rxn<AnalyticsResponse>();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    getUser();
    getUserDetails();
  }

  // ============================================================
  // GET USER
  // ============================================================

  Future<void> getUser() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;

      final token = await TokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        return;
      }

      final result = await apiService.getUserProfile(token);

      user.value = result;

      final hotels = result.profile.hotels;

      if (hotels.isEmpty) {
        return;
      }


        final prefs = await SharedPreferences.getInstance();

      final savedHotelId = prefs.getString(hotelIdKey);


      // final hotelId = hotels.first.hotelId;

      selectedHotelId.value = savedHotelId.toString();

      await getLeads(savedHotelId.toString(), reset: true);

      getAnalytics(savedHotelId.toString());
    } on ApiException catch (e) {
      ApiErrorHandler.handle(e);
    } catch (e) {
      // Handle unexpected error
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GET USER DETAILS
  // ============================================================

  Future<void> getUserDetails() async {
    try {
      final token = await TokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        return;
      }

      final result = await apiService.getUserDetails(token);

      userNameResponse.value = result;
    } on ApiException catch (e) {
      ApiErrorHandler.handle(e);
    } catch (e) {
      // Handle unexpected error
    }
  }

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

      final result = await apiService.getLeads(
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
  // GET ANALYTICS
  // ============================================================

  // ============================================================
  // GET ANALYTICS
  // ============================================================

  Future<void> getAnalytics(String hotelId) async {
    if (hotelId.isEmpty) return;

    try {
      isAnalyticsLoading.value = true;

      final result = await apiService.getAnalytics(hotelId);

      analyticsResponse.value = result;
    } on ApiException catch (e) {
      ApiErrorHandler.handle(e);
    } catch (e) {
      print('getAnalytics error: $e');
    } finally {
      isAnalyticsLoading.value = false;
    }
  }

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

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  Future<void> clearLeadsSearch() async {
    leadsSearch.value = '';

    await getLeads(selectedHotelId.value, reset: true);
  }

  // ============================================================
  // APPLY FILTERS
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

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  Future<void> clearLeadFilters() async {
    leadsSources.clear();
    leadsStages.clear();

    leadsStartDate.value = null;
    leadsEndDate.value = null;

    // Search remains active
    await getLeads(selectedHotelId.value, reset: true);
  }

  // ============================================================
  // CHECK FILTER ACTIVE
  // ============================================================

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
  // CHANGE HOTEL
  // ============================================================
  Future<void> changeHotel(String hotelId) async {
    if (hotelId.isEmpty) return;

    selectedHotelId.value = hotelId;

    // old analytics hata do
    analyticsResponse.value = null;

    // UI ko loading state dikhao
    isAnalyticsLoading.value = true;

    // Leads bhi reset karo
    leadsSearch.value = '';
    leadsSources.clear();
    leadsStages.clear();
    leadsStartDate.value = null;
    leadsEndDate.value = null;

    await Future.wait([getLeads(hotelId, reset: true), getAnalytics(hotelId)]);
  } // ============================================================
  // CLEAR DASHBOARD DATA
  // ============================================================

  void clearDashboardData() {
    // Leads
    leads.clear();
    leadResponse.value = null;
    selectedLead.value = null;

    // Analytics
    analyticsResponse.value = null;

    // Hotel
    selectedHotelId.value = '';

    // Pagination
    leadsPage.value = 0;
    hasMoreLeads.value = true;

    // Search
    leadsSearch.value = '';

    // Filters
    leadsSources.clear();
    leadsStages.clear();

    leadsStartDate.value = null;
    leadsEndDate.value = null;

    // User
    userNameResponse.value = null;
    user.value = null;

    // Loading
    isLoading.value = false;
    isLeadsLoading.value = false;
    isLoadingMoreLeads.value = false;
    isAnalyticsLoading.value = false;
  }
}
