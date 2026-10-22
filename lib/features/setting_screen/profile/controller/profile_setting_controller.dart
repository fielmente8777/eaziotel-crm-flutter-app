// ============================================================
// PROFILE SETTING CONTROLLER  (Settings > Profile)
//
//   Screen (widgets)  --->  ye controller  --->  ProfileSettingService  --->  API
//
// Is file me 4 hisse hain:
//   1. PROFILE DATA    : user, hotel ki jaankari (dashboard se, nayi API nahi)
//   2. HOTELS          : edit / delete (API abhi nahi mili)
//   3. URLS            : landing pages / websites ke link
//   4. CHANGE PASSWORD : form check + API call
// ============================================================

import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/auth_user_model.dart';
import 'package:eazotel/features/setting_screen/whatsapp/models/whatsapp_action_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/profile_setting_service.dart';

/// Settings > Profile tab ki state. API calls [ProfileSettingService] me hain.
class ProfileSettingController extends GetxController {
  final ProfileSettingService _service = ProfileSettingService();

  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  final LocationController location = Get.isRegistered<LocationController>()
      ? Get.find<LocationController>()
      : Get.put(LocationController());

  // ============================================================
  // PROFILE DATA (dashboard se, alag API call nahi)
  // ============================================================

  ProfileModel? get profile => dashboard.user.value?.profile;

  List<HotelModel> get hotels => location.hotels;

  /// GET /user/user-details identity; retain the logged-in owner in client view.
  AuthUserModel? get currentUser =>
      dashboard.ownerUser.value ?? dashboard.authUser.value;

  // ============================================================
  // HOTELS
  // ============================================================

  /// Add / edit / delete sirf admin kar sakta hai (web jaisa)
  bool get canManageHotels =>
      dashboard.authUser.value?.isAdmin ?? dashboard.user.value?.admin ?? false;

  /// Abhi app me chuna hua hotel
  String get currentHotelId => location.selectedHotel.value?.hotelId ?? '';

  final isSavingHotel = false.obs;

  /// Jis hotel ka delete chal raha hai ('' = koi nahi)
  final deletingHotelId = ''.obs;

  /// Card par tap: app ka hotel badlo (header ke location selector jaisa)
  Future<void> switchHotel(HotelModel hotel) async {
    if (hotel.hotelId == currentHotelId) return;

    await location.selectHotel(hotel);
    _toast('Location changed', 'Now showing ${_nameOf(hotel)}.');
  }

  /// Naye hotel ki id app chunta hai (web jaisa): sab number hain to
  /// sabse badi + 1, warna abhi ka time
  String _nextHotelId() {
    final ids = hotels.map((h) => h.hotelId).toList();
    final numbers = ids.map(int.tryParse).toList();

    if (ids.isNotEmpty && numbers.every((n) => n != null)) {
      return '${numbers.cast<int>().reduce((a, b) => a > b ? a : b) + 1}';
    }
    return '${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Add (hotel == null) ya edit. true = save ho gaya (dialog band karo)
  Future<bool> saveHotel(HotelModel? hotel, Map<String, String> fields) async {
    if (isSavingHotel.value) return false;

    final adding = hotel == null;
    final clean = {for (final e in fields.entries) e.key: e.value.trim()};
    if ((clean['local'] ?? '').isEmpty) return false;

    isSavingHotel.value = true;

    try {
      final hotelId = adding ? _nextHotelId() : hotel.hotelId;
      final list = adding
          ? await _service.addHotel(hotelId: hotelId, fields: clean)
          : await _service.updateHotel(hotelId: hotelId, fields: clean);

      // Server ne list na bheji to apni taraf se badlo
      await location.replaceHotels(
        list ??
            [
              for (final h in hotels)
                if (h.hotelId != hotelId) h,
              HotelModel(
                hotelId: hotelId,
                local: clean['local'] ?? '',
                city: clean['city'] ?? '',
                state: clean['state'] ?? '',
                country: clean['country'] ?? '',
                pinCode: clean['pinCode'] ?? '',
              ),
            ],
      );

      _toast(adding ? 'Location added' : 'Location updated', _nameOf2(clean));
      return true;
    } catch (e) {
      _toast(
        adding ? 'Could not add the location' : 'Could not update the location',
        _errorText(e),
        error: true,
      );
      return false;
    } finally {
      isSavingHotel.value = false;
    }
  }

  Future<void> deleteHotel(HotelModel hotel) async {
    if (hotel.hotelId == currentHotelId) {
      _toast(
        "Can't remove this location",
        "You can't remove the location you're using. Switch to another one first.",
        error: true,
      );
      return;
    }

    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove location?'),
        content: Text(
          '${_nameOf(hotel)} will be removed from your account. '
          'Bookings and leads already recorded for it are not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    deletingHotelId.value = hotel.hotelId;

    try {
      final list = await _service.deleteHotel(hotel.hotelId);
      await location.replaceHotels(
        list ?? hotels.where((h) => h.hotelId != hotel.hotelId).toList(),
      );
      _toast('Location removed', '${_nameOf(hotel)} was removed.');
    } catch (e) {
      _toast('Could not remove the location', _errorText(e), error: true);
    } finally {
      deletingHotelId.value = '';
    }
  }

  /// Server ka message (ho to), warna seedha sa
  String _errorText(Object e) {
    if (e is ApiException) {
      return WhatsappActionResponse.errorOf(e, 'Please try again.');
    }
    final text = '$e'.replaceFirst('Exception: ', '').trim();
    return text.isEmpty || text.length > 200 ? 'Please try again.' : text;
  }

  String _nameOf(HotelModel h) =>
      h.local.trim().isEmpty ? 'This location' : h.local.trim();

  String _nameOf2(Map<String, String> f) =>
      (f['local'] ?? '').isEmpty ? 'Saved' : f['local']!;

  void _toast(String title, String message, {bool error = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: error ? const Color(0xFFEF4444) : null,
      colorText: error ? Colors.white : null,
      margin: const EdgeInsets.all(12),
    );
  }

  // ============================================================
  // URLS
  // ============================================================

  final landingPages = <String>[].obs;
  final websites = <String>[].obs;

  static final RegExp _linkPattern = RegExp(
    r'^(https?://)?[\w-]+(\.[\w-]+)+(/\S*)?$',
  );

  /// Link list me jodta hai. Galat / duplicate ho to error text deta hai.
  String? addLink(RxList<String> list, String value) {
    final link = value.trim();

    if (link.isEmpty) return 'Please enter a link';

    if (!_linkPattern.hasMatch(link)) {
      return 'Please enter a valid link, like yourhotel.com';
    }

    if (list.any((e) => e.toLowerCase() == link.toLowerCase())) {
      return 'This link is already added';
    }

    list.add(link);
    return null;
  }

  void saveLinks() => _notConnected('Saving links');

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  final passwordError = RxnString();
  final isChangingPassword = false.obs;

  /// Form sahi ho to null, warna dikhane wala error
  String? _validatePassword() {
    final current = currentPassword.text;
    final next = newPassword.text;
    final confirm = confirmPassword.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      return 'Please fill all three fields';
    }

    if (next.length < 6) return 'New password must be at least 6 characters';

    if (next != confirm) {
      return 'New password and re-enter password do not match';
    }

    return null;
  }

  Future<void> changePassword() async {
    if (isChangingPassword.value) return;

    passwordError.value = _validatePassword();

    if (passwordError.value != null) return;

    isChangingPassword.value = true;

    try {
      final result = await _service.changePassword(
        currentPassword: currentPassword.text,
        newPassword: newPassword.text,
      );

      if (!result.success) {
        passwordError.value = result.message ?? 'Unable to change the password';
        return;
      }

      currentPassword.clear();
      newPassword.clear();
      confirmPassword.clear();

      Get.snackbar(
        'Password changed',
        result.message ?? 'Your password has been updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('CHANGE PASSWORD ERROR: $e');

      passwordError.value = 'Unable to change the password. Please try again.';
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  /// TODO: backend API milne par [ProfileSettingService] me call jodni hai
  void _notConnected(String action) {
    Get.snackbar(
      'Not connected yet',
      '$action needs its API. The screen is ready.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();

    super.onClose();
  }
}
