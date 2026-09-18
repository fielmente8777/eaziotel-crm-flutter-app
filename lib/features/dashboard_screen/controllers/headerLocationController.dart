 import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileResponseModel%20.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  final hotels = <HotelModel>[].obs;

  final filteredHotels = <HotelModel>[].obs;

  final selectedHotel = Rxn<HotelModel>();

  final showHotels = false.obs;

  @override
  void onInit() {
    super.onInit();

    loadHotels();

    ever(
      dashboardController.user,
      (_) => loadHotels(),
    );
  }

  // ============================================================
  // LOAD HOTELS FROM API MODEL
  // ============================================================

  void loadHotels() {
    final apiHotels =
        dashboardController.user.value?.profile.hotels ?? [];

    hotels.assignAll(apiHotels);
    filteredHotels.assignAll(apiHotels);

    if (apiHotels.isNotEmpty) {
      selectedHotel.value = apiHotels.first;
    }
  }

  // ============================================================
  // OPEN
  // ============================================================

  void openHotelSelector() {
    filteredHotels.assignAll(hotels);
    showHotels.value = true;
    
  }

  // ============================================================
  // CLOSE
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
            hotel.hotelId.contains(query),
      ),
    );
  }

  // ============================================================
  // SELECT HOTEL
  // ============================================================

  Future<void> selectHotel(HotelModel hotel) async {
    selectedHotel.value = hotel;

    showHotels.value = false;

    // DashboardController ko new hotel ID
    // aur leads API call
    await dashboardController.changeHotel(
      hotel.hotelId,
    );
  }
}