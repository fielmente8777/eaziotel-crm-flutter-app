import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/dashboard_screen/models/auth_user_model.dart';
import 'package:flutter/foundation.dart';
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

  /// Owner: the 'Client accounts' tab is open on the Select Hotel screen
  final showClients = false.obs;
  final _workers = <Worker>[];

  @override
  void onInit() {
    super.onInit();

    loadHotels();
    if (isOwner) loadClients();
    _workers.add(
      ever(dashboardController.ownerUser, (_) {
        if (isOwner) loadClients();
      }),
    );

    _workers.add(ever(dashboardController.user, (_) => loadHotels()));

    // Role / assigned locations arrived -> rebuild the list (allowed hotels only)
    _workers.add(
      ever(dashboardController.authUser, (_) {
        loadHotels();
        if (isOwner) loadClients();
      }),
    );
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }

  // ============================================================
  // LOAD HOTELS
  // ============================================================

  Future<void> loadHotels() async {
    // Only the hotels this user should see (same as web):
    // admin -> all, team member -> only assigned
    final apiHotels = dashboardController.allowedHotels;

    if (apiHotels.isEmpty) {
      hotels.clear();
      filteredHotels.clear();
      return;
    }

    hotels.assignAll(apiHotels);
    filteredHotels.assignAll(apiHotels);

    // Get the saved hotel ID from storage
    final prefs = await SharedPreferences.getInstance();

    final savedHotelId = prefs.getString(hotelIdKey);

    // ============================================================
    // SAVED HOTEL (if this user can open it), otherwise
    // admin -> last one, team member -> first one (same as web)
    // ============================================================

    final hotelToSelect =
        dashboardController.pickHotel(apiHotels, savedHotelId) ??
        apiHotels.first;

    // The dashboard is already loading this hotel's data -> do not load it again
    if (dashboardController.selectedHotelId.value == hotelToSelect.hotelId) {
      selectedHotel.value = hotelToSelect;
      return;
    }

    // ============================================================
    // SELECT HOTEL
    // ============================================================

    selectedHotel.value = hotelToSelect;

    // Make sure it is in storage too
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
  // OWNER: CLIENT ACCOUNTS  (like the web "LocationSwitcher")
  //   list of all clients -> tap one -> switch-account gives its
  //   token -> client data opens, the owner session is kept
  // ============================================================

  bool get isOwner => dashboardController.isOwner;
  bool get isViewingClient => dashboardController.isViewingClient;

  final clients = <ClientAccountModel>[].obs;
  final isClientsLoading = false.obs;
  final clientSearch = ''.obs;

  /// The client being switched to (hotelEmail)
  final switchingClient = ''.obs;

  List<ClientAccountModel> get visibleClients =>
      clients.where((c) => c.matches(clientSearch.value)).toList();

  Future<void> loadClients() async {
    if (!isOwner || isClientsLoading.value) return;

    isClientsLoading.value = true;
    try {
      clients.assignAll(await dashboardController.apiService.getAllClients());
    } catch (e) {
      debugPrint('ALL CLIENTS ERROR: $e');
      clients.clear();
    } finally {
      isClientsLoading.value = false;
    }
  }

  /// Go into the client account. On error, [onError].
  Future<void> switchClient(
    ClientAccountModel client, {
    required void Function(String) onError,
    required Future<void> Function() onSwitched,
  }) async {
    if (!isOwner || switchingClient.value.isNotEmpty) return;
    if (client.hotelEmail.isEmpty) {
      onError(
        'This client has no account email. Add it to the client record before switching.',
      );
      return;
    }

    switchingClient.value = client.hotelEmail;
    try {
      final token = await dashboardController.apiService.switchAccount(
        client.hotelEmail,
      );
      if (token == null || token.isEmpty) {
        onError('Could not switch to ${client.hotelName}. Please try again.');
        return;
      }

      // New token + that client's first location
      await TokenStorage.enterClient(token, client.firstHotelId);

      await onSwitched();
    } catch (e) {
      debugPrint('SWITCH ACCOUNT ERROR: $e');
      onError('Could not switch to ${client.hotelName}. Please try again.');
    } finally {
      switchingClient.value = '';
    }
  }

  // ============================================================
  // REPLACE HOTELS (after add / edit / delete in Settings)
  // ============================================================

  /// Use the server's new list. The selected hotel stays (if it was renamed,
  /// the new name shows). If it was removed, pick the first hotel.
  Future<void> replaceHotels(List<HotelModel> list) async {
    hotels.assignAll(list);
    filteredHotels.assignAll(list);

    final currentId = selectedHotel.value?.hotelId;
    final current = list.firstWhereOrNull((h) => h.hotelId == currentId);

    if (current != null) {
      selectedHotel.value = current;
    } else if (list.isNotEmpty) {
      await selectHotel(list.first);
    }
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
