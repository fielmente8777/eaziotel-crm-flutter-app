import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/googleAnalytis/controller/analytisController.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationController extends GetxController {
  late final DashboardController dashboardController;

  LocationController() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    dashboardController = Get.find<DashboardController>();
  }

  // ============================================================
  // STORAGE KEY
  // ============================================================

  static const String hotelIdKey = 'selected_hotel_id';

  final hotels = <HotelModel>[].obs;
  final filteredHotels = <HotelModel>[].obs;
  final selectedHotel = Rxn<HotelModel>();
  final showHotels = false.obs;

  @override
  void onInit() {
    super.onInit();

    loadHotels();

    ever(dashboardController.user, (_) => loadHotels());
  }

  // ============================================================
  // LOAD HOTELS
  // ============================================================

  Future<void> loadHotels() async {
    final apiHotels = dashboardController.user.value?.profile.hotels ?? [];

    if (apiHotels.isEmpty) {
      return;
    }

    hotels.assignAll(apiHotels);
    filteredHotels.assignAll(apiHotels);

    // Saved hotel ID storage se nikalo
    final prefs = await SharedPreferences.getInstance();

    final savedHotelId = prefs.getString(hotelIdKey);

    HotelModel? hotelToSelect;

    // ============================================================
    // SAVED HOTEL FIND KARO
    // ============================================================

    if (savedHotelId != null && savedHotelId.isNotEmpty) {
      hotelToSelect = apiHotels.firstWhereOrNull(
        (hotel) => hotel.hotelId == savedHotelId,
      );
    }

    // ============================================================
    // AGAR SAVED ID NAHI MILI TO FIRST HOTEL
    // ============================================================

    hotelToSelect ??= apiHotels.first;

    // ============================================================
    // SELECT HOTEL
    // ============================================================

    selectedHotel.value = hotelToSelect;

    // Storage mein bhi ensure karo
    await prefs.setString(hotelIdKey, hotelToSelect.hotelId);

    // Dashboard data load
    await dashboardController.changeHotel(hotelToSelect.hotelId);
  }

  // ============================================================
  // SELECT HOTEL
  // ============================================================

  Future<void> selectHotel(HotelModel hotel) async {
    selectedHotel.value = hotel;
    showHotels.value = false;

    // ============================================================
    // SAVE HOTEL ID
    // ============================================================

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(hotelIdKey, hotel.hotelId);

    // ============================================================
    // LOAD DASHBOARD DATA
    // ============================================================

    await dashboardController.changeHotel(hotel.hotelId);
   
  }

  // ============================================================
  // OPEN SELECTOR
  // ============================================================

  void openHotelSelector() {
    filteredHotels.assignAll(hotels);
    showHotels.value = true;
  }

  // ============================================================
  // CLOSE SELECTOR
  // ============================================================

  void closeHotelSelector() {
    showHotels.value = false;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void searchHotels(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredHotels.assignAll(hotels);
      return;
    }

    filteredHotels.assignAll(
      hotels.where(
        (hotel) =>
            hotel.local.toLowerCase().contains(query) ||
            hotel.city.toLowerCase().contains(query) ||
            hotel.state.toLowerCase().contains(query) ||
            hotel.country.toLowerCase().contains(query) ||
            hotel.hotelId.toLowerCase().contains(query),
      ),
    );
  }
}
