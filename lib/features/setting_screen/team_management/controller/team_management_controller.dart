// ============================================================
// TEAM MANAGEMENT CONTROLLER
//
//   Screen (widgets)  --->  ye controller  --->  TeamManagementService  --->  API
//
// Is file me 4 hisse hain:
//   1. MEMBERS   : selected hotel ke team members (dashboard ke data se)
//   2. LOCATIONS : form ke "Select Location" dropdown ke hotel
//   3. SAVE      : form check + Create / Edit API
//   4. DELETE    : user hatana
// ============================================================

import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:get/get.dart';

import '../models/location_option.dart';
import '../models/team_member_display.dart';
import '../models/team_user_request.dart';
import '../services/team_management_service.dart';

class TeamManagementController extends GetxController {
  /// Users, hotels aur selected hotel dashboard se milte hain
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get selectedHotelId => dashboard.selectedHotelId.value;

  // ============================================================
  // 1. MEMBERS  (sirf selected hotel ke)
  //
  //   - superadmin hamesha dikhta hai (poore account par access)
  //   - baaki users tab, jab unka koi assigned hotel selected hotel ho
  //
  // Obx ke andar padho to hotel badalne par list apne aap badalti hai.
  // ============================================================

  List<UserModel> get members {
    final all = dashboard.userNameResponse.value?.data ?? [];
    final hid = selectedHotelId;

    return all.where((user) {
      if (user.isSuperAdmin) return true;

      return user.assignedLocation.any((location) => location.hid == hid);
    }).toList();
  }

  // ============================================================
  // 2. LOCATIONS  (profile.hotels se)
  // ============================================================

  List<LocationOption> get locations {
    final hotels = dashboard.user.value?.profile.hotels ?? [];

    return [
      for (final hotel in hotels)
        LocationOption(
          hid: hotel.hotelId,
          name: hotel.city.isNotEmpty ? hotel.city : hotel.local,
        ),
    ];
  }

  /// Create form me pehle se chuna hua hotel (jo abhi selected hai)
  LocationOption? get selectedLocation =>
      locations.firstWhereOrNull((location) => location.hid == selectedHotelId);

  // ============================================================
  // 3. SAVE  (Create / Edit)
  // ============================================================

  /// true = Save chal raha hai (button par "Saving...")
  final isSaving = false.obs;

  /// [existing] null = Create, warna Edit.
  /// Return: null = ho gaya, text = form me dikhane wala error.
  Future<String?> saveUser({
    UserModel? existing,
    required String name,
    required String phone,
    required String email,
    required String password,
    required LocationOption? location,
    required Set<String> selected,
  }) async {
    if (isSaving.value) return null;

    // ---------- Form check (password ke alawa sab zaroori) ----------
    final error = _validate(
      name: name,
      phone: phone,
      email: email,
      location: location,
    );

    if (error != null) return error;

    // ---------- API ----------
    isSaving.value = true;

    try {
      final token = await TokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        return 'Session expired. Please login again.';
      }

      final request = TeamUserRequest(
        existing: existing,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        password: password,
        location: location!,
        selected: selected,
      );

      final message = request.isEdit
          ? await TeamManagementService.editUser(
              token: token,
              body: request.toJson(),
            )
          : await TeamManagementService.createUser(
              token: token,
              body: request.toJson(),
            );

      await _reloadMembers();

      Get.snackbar('Success', message, snackPosition: SnackPosition.BOTTOM);
      return null;
    } catch (e) {
      return _errorText(e);
    } finally {
      isSaving.value = false;
    }
  }

  String? _validate({
    required String name,
    required String phone,
    required String email,
    required LocationOption? location,
  }) {
    if (name.trim().isEmpty) return 'Please enter a name';
    if (phone.trim().isEmpty) return 'Please enter a phone number';
    if (phone.trim().length < 10) return 'Please enter a valid phone number';
    if (email.trim().isEmpty) return 'Please enter an email';
    if (!GetUtils.isEmail(email.trim())) return 'Please enter a valid email';
    if (location == null) return 'Please select a location';

    return null;
  }

  // ============================================================
  // 4. DELETE
  // ============================================================

  Future<void> deleteUser(UserModel user) async {
    try {
      final message = await TeamManagementService.deleteUser(
        emailId: user.emailId ?? '',
      );

      await _reloadMembers();

      Get.snackbar('Deleted', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', _errorText(e), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  /// Create / Edit / Delete ke baad list dobara lao
  Future<void> _reloadMembers() => dashboard.getUserDetails();

  /// "Exception: User already exists" -> "User already exists"
  String _errorText(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
