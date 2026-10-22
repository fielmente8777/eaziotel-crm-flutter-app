import 'package:eazotel/core/api/apiexception/api_error_handler.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_call_analytics_mixin.dart';
import 'package:eazotel/features/leads/controller/leads_list_mixin.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/dashboard_screen/models/auth_user_model.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/analytics_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/services/dashboard_api_service.dart';
import 'package:flutter/foundation.dart';
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
  // null = checking, true = dashboard, false = subscription expired.
  final isSubscriptionActive = RxnBool();
  // true = new account, no hotel -> onboarding form first (same as web)
  final needsOnboarding = RxnBool();

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

      // Load the profile (hotels) + the logged-in user (role, assigned locations)
      // together
      final profileFuture = apiService.getUserProfile(token);
      final authFuture = _loadAuthUser();

      final result = await profileFuture;
      await authFuture;

      user.value = result;
      needsOnboarding.value =
          !result.status || result.profile.hotels.isEmpty;
      if (needsOnboarding.value == true) return;
      final endDate = DateTime.tryParse(result.subscriptionDetails.endDate);
      isSubscriptionActive.value = endDate?.isAfter(DateTime.now()) ?? false;
      if (isSubscriptionActive.value != true) return;

      // Only the hotels this user should see
      final hotels = allowedHotels;

      if (hotels.isEmpty) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      // The hotel from last time, but only if this user can open it
      final hotelId = _pickHotel(hotels, prefs.getString(hotelIdKey)).hotelId;
      await prefs.setString(hotelIdKey, hotelId);

      selectedHotelId.value = hotelId;

      // Call analytics starts automatically, in parallel with leads
      // (not awaited, so a slow leads API does not delay it)
      getCallAnalytics(hotelId);

      await getLeads(hotelId, reset: true);

      getAnalytics(hotelId);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(e);
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // WHICH LOCATIONS A USER CAN SEE (same as the web dashboard)
  //   isAdmin       -> all locations
  //   team member   -> only assigned_location ones
  //   role "owner"  -> also client accounts (LocationController)
  // ============================================================

  /// The logged-in user (GET /user/user-details)
  final authUser = Rxn<AuthUserModel>();
  final ownerUser = Rxn<AuthUserModel>();

  bool get isOwner => (ownerUser.value ?? authUser.value)?.isOwner ?? false;
  bool get isViewingClient => ownerUser.value?.isOwner ?? false;

  Future<void> _loadAuthUser() async {
    final ownerToken = await TokenStorage.getOwnerAccessToken();
    if (ownerToken != null) {
      try {
        // Verify owner privileges with the owner's credentials, never a client role.
        ownerUser.value = await apiService.getAuthUser(accessToken: ownerToken);
      } catch (e) {
        debugPrint('OWNER SESSION ERROR: $e');
      }
    }
    try {
      authUser.value = await apiService.getAuthUser();
    } catch (e) {
      // If not found, same as before: all locations (do not lock anyone out)
      debugPrint('AUTH USER (user-details) ERROR: $e');
    }
  }

  /// Hotels this user can see
  List<HotelModel> get allowedHotels {
    final all = user.value?.profile.hotels ?? const <HotelModel>[];
    final me = authUser.value;
    return me == null ? all : me.allowedHotels(all);
  }

  HotelModel _pickHotel(List<HotelModel> allowed, String? savedHid) =>
      authUser.value?.pickHotel(allowed, savedHid) ??
      allowed.firstWhere(
        (h) => h.hotelId == savedHid,
        orElse: () => allowed.first,
      );

  /// Same rules from outside too (LocationController)
  HotelModel? pickHotel(List<HotelModel> allowed, String? savedHid) =>
      allowed.isEmpty ? null : _pickHotel(allowed, savedHid);

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
      //   // Own custom user (TESTING)
      //   UserModel(displayName: '(gangadhar)', phone: '+917497042180'),

      //   // Users from the API
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

    // clear the old analytics
    analyticsResponse.value = null;

    // clear the old call analytics too
    callAnalytics.value = null;

    // show the loading state in the UI
    isAnalyticsLoading.value = true;

    // reset leads too
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
    // The logged-in user (role / locations)
    authUser.value = null;
    ownerUser.value = null;

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
    isSubscriptionActive.value = null;
    needsOnboarding.value = null;

    // Loading
    isLoading.value = false;
    isAnalyticsLoading.value = false;
  }
}
