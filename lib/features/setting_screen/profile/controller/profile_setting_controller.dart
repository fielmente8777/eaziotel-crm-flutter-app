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

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
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

  /// Login kiya hua user: hotel ke email wala, warna list ka pehla
  UserModel? get currentUser {
    final users = dashboard.userNameResponse.value?.data ?? [];
    if (users.isEmpty) return null;

    final email = profile?.hotelEmail.trim().toLowerCase() ?? '';

    return users.firstWhereOrNull(
          (u) => (u.emailId ?? '').trim().toLowerCase() == email,
        ) ??
        users.first;
  }

  // ============================================================
  // HOTELS
  // ============================================================

  void editHotel(HotelModel hotel) => _notConnected('Editing a hotel');

  void deleteHotel(HotelModel hotel) => _notConnected('Deleting a hotel');

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
