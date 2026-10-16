import 'package:eazotel/core/api/apiexception/api_error_handler.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_call_analytics_mixin.dart';
import 'package:eazotel/features/leads/controller/leads_list_mixin.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/analytics_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/services/dashboard_api_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Leads code lives in features/leads/controller/leads_list_mixin.dart,
// call analytics code in dashboard_call_analytics_mixin.dart.
class DashboardController extends GetxController
    with DashboardLeadsMixin, DashboardCallAnalyticsMixin {
  // API service
  @override
  final DashboardApiService apiService = DashboardApiService();

  // ============================================================
  // LOADING
  // ============================================================

  final isLoading = false.obs;
  final isAnalyticsLoading = true.obs;

  // ============================================================
  // USER
  // ============================================================

  final userNameResponse = Rxn<UserResponseModel>();
  final user = Rxn<ProfileResponseModel>();

  // ============================================================
  // HOTEL
  // ============================================================

  @override
  final selectedHotelId = ''.obs;

  static const String hotelIdKey = 'selected_hotel_id';

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

    // getUser() loads the hotel id, then starts leads, analytics
    // AND call analytics automatically.
    // (Calling getCallAnalytics() here directly does nothing,
    // because selectedHotelId is still empty at this point.)
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

      // Call analytics starts automatically, in parallel with leads
      // (not awaited, so a slow leads API does not delay it)
      getCallAnalytics(savedHotelId.toString());

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

      //     userNameResponse.value =UserResponseModel(
      // status: result.status,
      // data: [
      //   // Apne custom user (TESTING)
      //   UserModel(displayName: '(gangadhar)', phone: '+917497042180'),

      //   // API se aaye user
      //   ...result.data,
      // ],   / for call testing
    } on ApiException catch (e) {
      ApiErrorHandler.handle(e);
    } catch (e) {
      // Handle unexpected error
    }
  }

  // ============================================================
  // GET ANALYTICS
  // ============================================================

  Future<void> getAnalytics(String hotelId) async {
    if (hotelId.isEmpty) return;

    try {
      // isAnalyticsLoading.value = true;

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

  // ============================================================
  // CHANGE HOTEL
  // ============================================================

  Future<void> changeHotel(String hotelId) async {
    if (hotelId.isEmpty) return;

    selectedHotelId.value = hotelId;

    // old analytics hata do
    analyticsResponse.value = null;

    // old call analytics bhi hata do
    callAnalytics.value = null;

    // UI ko loading state dikhao
    isAnalyticsLoading.value = true;

    // Leads bhi reset karo
    leadsSearch.value = '';
    resetLeadFilters();

    await Future.wait([
      getLeads(hotelId, reset: true),
      getAnalytics(hotelId),
      getCallAnalytics(hotelId),
    ]);
  }

  // ============================================================
  // CLEAR DASHBOARD DATA
  // ============================================================

  void clearDashboardData() {
    // Leads, pagination, search, filters
    clearLeadsData();

    // Analytics
    analyticsResponse.value = null;

    // Call analytics
    callAnalytics.value = null;
    isCallAnalyticsLoading.value = false;

    // Hotel
    selectedHotelId.value = '';

    // User
    userNameResponse.value = null;
    user.value = null;

    // Loading
    isLoading.value = false;
    isAnalyticsLoading.value = false;
  }
}
