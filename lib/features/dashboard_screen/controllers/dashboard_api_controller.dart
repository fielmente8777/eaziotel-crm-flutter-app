import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/auth/controllers/google_auth_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/analytics_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final googleAuthController = Get.put(GoogleAuthController());

  // ============================================================
  // LOADING
  // ============================================================
  final Rxn<LeadModel> selectedLead = Rxn<LeadModel>();
  final isLoading = false.obs;

  final isLeadsLoading = false.obs;

  final isLoadingMoreLeads = false.obs;

  final isAnalyticsLoading = true.obs;

  // ============================================================
  // USER name
  // ============================================================

  final userNameResponse = Rxn<UserResponseModel>();

  // ============================================================
  // USER profile
  // ============================================================

  final user = Rxn<ProfileResponseModel>();

  final selectedHotelId = ''.obs;

  // ============================================================
  // LEADS
  // ============================================================

  final leadResponse = Rxn<LeadResponseModel>();

  final RxList<LeadModel> leads = <LeadModel>[].obs;

  final leadsPage = 0.obs;

  final leadsSearch = ''.obs;

  final hasMoreLeads = true.obs;

  final int leadsLimit = 20;

  // ============================================================
  // LEAD FILTERS
  // ============================================================

  /// Multiple source values.
  ///
  /// Example:
  /// ['eazbot', 'webform', 'whatsapp']
  final RxList<String> leadsSources = <String>[].obs;

  /// Multiple stage values.
  ///
  /// Example:
  /// ['Hot', 'Converted']
  final RxList<String> leadsStages = <String>[].obs;

  /// Start date + time.
  final Rxn<DateTime> leadsStartDate = Rxn<DateTime>();

  /// End date + time.
  final Rxn<DateTime> leadsEndDate = Rxn<DateTime>();

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
  // USER API
  // ============================================================

  Future<void> getUser() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {
      final token = await TokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        debugPrint('Access token not found');

        return;
      }

      final response = await ApiClient.get(
        '${AuthApiEndpoint.getUserProfile}/$token',
        authenticated: false,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        debugPrint('USER API RESPONSE: ${response.body}');

        if (data is Map<String, dynamic>) {
          user.value = ProfileResponseModel.fromJson(data);

          final hotels = user.value?.profile.hotels ?? [];

          if (hotels.isNotEmpty) {
            final hotelId = hotels.first.hotelId;

            selectedHotelId.value = hotelId;

            debugPrint('HOTEL ID: $hotelId');

            // Get first page of leads.
            await getLeads(hotelId, reset: true);

            // Get analytics.
            await getAnalytics(hotelId);
          }
        }
      } else {
        debugPrint(
          'User API failed: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Get user error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // get user detail
  // ============================================================

  Future<void> getUserDetails() async {
    final token = await TokenStorage.getAccessToken();

    final response = await ApiClient.get(
      '${AuthApiEndpoint.UserProfile}/$token',
      authenticated: false,
    );

    debugPrint('USER DETAILS RESPONSE: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        userNameResponse.value = UserResponseModel.fromJson(data);
      }
    }
  }

  // ============================================================
  // LEADS API
  // ============================================================

  Future<void> getLeads(String hotelId, {bool reset = false}) async {
    if (hotelId.isEmpty) {
      return;
    }

    // ============================================================
    // RESET
    // ============================================================

    if (reset) {
      leadsPage.value = 0;
      hasMoreLeads.value = true;
      leads.clear();
    }

    // ============================================================
    // PREVENT DUPLICATE CALL
    // ============================================================

    if (isLeadsLoading.value ||
        isLoadingMoreLeads.value ||
        !hasMoreLeads.value) {
      return;
    }

    final bool isFirstPage = leadsPage.value == 0;

    if (isFirstPage) {
      isLeadsLoading.value = true;
    } else {
      isLoadingMoreLeads.value = true;
    }

    try {
      // ==========================================================
      // TOKEN
      // ==========================================================

      final token = await TokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        debugPrint('Access token not found');
        return;
      }

      // ==========================================================
      // PAGE
      // ==========================================================

      final page = leadsPage.value + 1;

      final limit = leadsLimit;

      // ==========================================================
      // BASE URL
      // ==========================================================

      var url =
          '${LeadsApiEndpoint.getLeads}'
          '?hid=$hotelId'
          '&page=$page'
          '&limit=$limit';

      // ==========================================================
      // SEARCH
      // ==========================================================

      final search = leadsSearch.value.trim();

      if (search.isNotEmpty) {
        url += '&search=${Uri.encodeQueryComponent(search)}';
      }

      // ==========================================================
      // SOURCE
      // ==========================================================

      for (final source in leadsSources) {
        final value = source.trim();

        if (value.isNotEmpty) {
          url += '&source=${Uri.encodeQueryComponent(value)}';
        }
      }

      // ==========================================================
      // STAGE
      // ==========================================================

      for (final stage in leadsStages) {
        final value = stage.trim();

        if (value.isNotEmpty) {
          url += '&stage=${Uri.encodeQueryComponent(value)}';
        }
      }

      // ==========================================================
      // FROM DATE
      // ==========================================================

      if (leadsStartDate.value != null) {
        final from = _formatApiDate(leadsStartDate.value!);

        url += '&from=${Uri.encodeQueryComponent(from)}';
      }

      // ==========================================================
      // TO DATE
      // ==========================================================

      if (leadsEndDate.value != null) {
        final to = _formatApiDate(leadsEndDate.value!);

        url += '&to=${Uri.encodeQueryComponent(to)}';
      }

      // ==========================================================
      // DEBUG
      // ==========================================================

      debugPrint('GET LEADS URL: $url');

      // ==========================================================
      // API
      // ==========================================================

      final response = await ApiClient.get(
        url,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        debugPrint('LEADS API RESPONSE: ${response.body}');

        if (data is Map<String, dynamic>) {
          final parsedResponse = LeadResponseModel.fromJson(data);

          leadResponse.value = parsedResponse;

          final loadedLeads = parsedResponse.result?.docs?.leads ?? [];

          // ======================================================
          // FIRST PAGE
          // ======================================================

          if (isFirstPage) {
            leads.assignAll(loadedLeads);
          }
          // ======================================================
          // NEXT PAGE
          // ======================================================
          else {
            leads.addAll(loadedLeads);
          }

          // ======================================================
          // HAS MORE
          // ======================================================

          if (loadedLeads.length < leadsLimit) {
            hasMoreLeads.value = false;
          }

          // ======================================================
          // NEXT PAGE
          // ======================================================

          if (loadedLeads.isNotEmpty) {
            leadsPage.value++;
          }

          debugPrint(
            'Loaded: ${loadedLeads.length} | '
            'Total: ${leads.length} | '
            'Page: ${leadsPage.value}',
          );
        }
      } else {
        debugPrint(
          'Leads API failed: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Get leads error: $e');
    } finally {
      isLeadsLoading.value = false;
      isLoadingMoreLeads.value = false;
    }
  }

  // ============================================================
  // ANALYTICS API
  // ============================================================
  Future<void> getAnalytics(String hotelId) async {
    if (hotelId.isEmpty) {
      return;
    }

    // API call start hote hi loading true
    isAnalyticsLoading.value = true;

    try {
      final token = await TokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        debugPrint('Access token not found');
        return;
      }

      debugPrint('ANALYTICS LOADING: TRUE');
      debugPrint('GET ANALYTICS FOR HOTEL: $hotelId');

      final response = await ApiClient.get(
        '${analytics.getLeads}?hid=$hotelId&limit=500',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        debugPrint('ANALYTICS API RESPONSE: ${response.body}');

        if (data is Map<String, dynamic>) {
          analyticsResponse.value = AnalyticsResponse.fromJson(data);

          debugPrint('ANALYTICS DATA LOADED');
        }
      } else {
        debugPrint('Analytics API failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Get analytics error: $e');
    } finally {
      // API complete hone ke baad loading false
      isAnalyticsLoading.value = false;

      debugPrint('ANALYTICS LOADING: FALSE');
    }
  }
  // ============================================================
  // LEADS PAGINATION
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
  // LEADS SEARCH
  // ============================================================

  Future<void> searchLeads(String value) async {
    leadsSearch.value = value.trim();

    // Search API ke through jayega.
    // Existing source/stage/date filters
    // bhi saath jayenge.

    await getLeads(selectedHotelId.value, reset: true);
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  Future<void> clearLeadsSearch() async {
    leadsSearch.value = '';

    // Existing filters remain active.

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
    // ==========================================================
    // SAVE FILTERS
    // ==========================================================

    leadsSources.assignAll(sources);

    leadsStages.assignAll(stages);

    leadsStartDate.value = startDate;

    leadsEndDate.value = endDate;

    // ==========================================================
    // API CALL
    // ==========================================================

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

    // Search ko clear nahi kar rahe.
    //
    // Agar user ne:
    // search = "test"
    // filter = Hot
    //
    // kiya hai aur filter clear karta hai,
    // to search "test" active rahega.

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
    await getLeads(selectedHotelId.value, reset: true);
  }

  // ============================================================
  // CHANGE HOTEL
  // ============================================================

  Future<void> changeHotel(String hotelId) async {
    if (hotelId.isEmpty || selectedHotelId.value == hotelId) {
      return;
    }
  isAnalyticsLoading.value = true;

    selectedHotelId.value = hotelId;

    // ==========================================================
    // CLEAR SEARCH
    // ==========================================================

    leadsSearch.value = '';

    // ==========================================================
    // CLEAR FILTERS
    // ==========================================================

    leadsSources.clear();

    leadsStages.clear();

    leadsStartDate.value = null;

    leadsEndDate.value = null;

    debugPrint('HOTEL ID: $hotelId');

    // ==========================================================
    // GET LEADS
    // ==========================================================

    await getLeads(hotelId, reset: true);

    // ==========================================================
    // GET ANALYTICS
    // ==========================================================

    await getAnalytics(hotelId);
  }
}

String _formatApiDate(DateTime date) {
  final localDate = date.toLocal();

  final weekday = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ][localDate.weekday - 1];

  final month = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][localDate.month - 1];

  final day = localDate.day.toString().padLeft(2, '0');

  final hour = localDate.hour.toString().padLeft(2, '0');

  final minute = localDate.minute.toString().padLeft(2, '0');

  final second = localDate.second.toString().padLeft(2, '0');

  final offset = localDate.timeZoneOffset;

  final offsetHours = offset.inHours;

  final offsetMinutes = offset.inMinutes.abs() % 60;

  final sign = offset.isNegative ? '-' : '+';

  final offsetString =
      'GMT$sign'
      '${offsetHours.abs().toString().padLeft(2, '0')}'
      '${offsetMinutes == 0 ? '' : ':'}'
      '${offsetMinutes == 0 ? '' : offsetMinutes.toString().padLeft(2, '0')}';

  return '$weekday $month $day '
      '${localDate.year} '
      '$hour:$minute:$second '
      '$offsetString';
}
