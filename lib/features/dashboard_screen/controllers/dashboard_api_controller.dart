import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/auth/controllers/google_auth_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/dashboard_user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final googleAuthController = Get.put(GoogleAuthController());
   final isLoading = false.obs;

  final user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();

    // Dashboard open hote hi API call
    getUser();
  }

  Future<void> getUser() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      debugPrint('🚀 GET USER API STARTED');

      // SharedPreferences se saved auth token nikalo
      final authToken = await TokenStorage.getAccessToken();

      debugPrint('🔑 AUTH TOKEN: $authToken');

      if (authToken == null || authToken.isEmpty) {
        debugPrint('❌ AUTH TOKEN NOT FOUND');
        return;
      }

      // Token ko URL ke end mein bhejna hai
      final endpoint = '${AuthApiEndpoint.getUserProfile}/$authToken';

      debugPrint('🌐 GET USER URL: $endpoint');

      final response = await ApiClient.get(endpoint, authenticated: false);

      debugPrint('📡 GET USER STATUS: ${response.statusCode}');
      debugPrint('📦 GET USER RESPONSE: ${response.body}');

      if (response.statusCode >= 200) {
        final data = jsonDecode(response.body);

        debugPrint('✅ USER API SUCCESS');
        debugPrint('👤 USER DATA: $data');
        debugPrint(const JsonEncoder.withIndent('  ').convert(data));

        if (data is Map<String, dynamic>) {
          user.value = UserModel.fromJson(data);
        }
      } else {
        debugPrint('❌ GET USER FAILED: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ GET USER ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
