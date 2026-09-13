import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/auth/controllers/google_auth_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final googleAuthController = Get.put(GoogleAuthController());

  // ============================================================
  // STATES
  // ============================================================

  final isLoading = false.obs;
  final isLeadsLoading = false.obs;

  // ============================================================
  // USER DATA
  // ============================================================

  final user = Rxn<ProfileResponseModel>();

  // ============================================================
  // COMPLETE LEADS RESPONSE
  // ============================================================

  final leadResponse = Rxn<LeadResponseModel>();

  // ============================================================
  // LEADS DATA
  // ============================================================

  final RxList<LeadModel> leads = <LeadModel>[].obs;

  // ============================================================
  // SELECTED HOTEL
  // ============================================================

  final selectedHotelId = ''.obs;

  // ============================================================
  // ON INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    getUser();
  }

  // ============================================================
  // GET USER PROFILE
  // ============================================================

  Future<void> getUser() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final authToken = await TokenStorage.getAccessToken();

      if (authToken == null || authToken.isEmpty) {
        debugPrint('Access token not found');
        return;
      }

      final endpoint =
          '${AuthApiEndpoint.getUserProfile}/$authToken';

      final response = await ApiClient.get(
        endpoint,
        authenticated: false,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          // ====================================================
          // STORE USER RESPONSE
          // ====================================================

          user.value = ProfileResponseModel.fromJson(data);

          // ====================================================
          // GET HOTELS
          // ====================================================

          final hotels = user.value?.profile.hotels ?? [];

          if (hotels.isNotEmpty) {
            final hotelId = hotels.first.hotelId;

            // ==================================================
            // SELECT FIRST HOTEL
            // ==================================================

            selectedHotelId.value = hotelId;

            // ==================================================
            // GET LEADS FOR FIRST HOTEL
            // ==================================================

            await getLeads(hotelId);
          }
        }
      } else {
        debugPrint(
          'User API failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint(
        'Get user error: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GET LEADS
  // ============================================================

  Future<void> getLeads(String hotelId) async {
    if (hotelId.isEmpty) return;

    if (isLeadsLoading.value) return;

    isLeadsLoading.value = true;

    try {
      final authToken = await TokenStorage.getAccessToken();

      if (authToken == null || authToken.isEmpty) {
        debugPrint('Access token not found');
        return;
      }

      // ========================================================
      // CALL LEADS API
      // ========================================================

      final response = await ApiClient.get(
        '${LeadsApiEndpoint.getLeads}?hid=$hotelId',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      // ========================================================
      // SUCCESS RESPONSE
      // ========================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        // ======================================================
        // COMPLETE RESPONSE
        // ======================================================

        if (data is Map<String, dynamic>) {
          // ====================================================
          // STORE COMPLETE API RESPONSE IN MODEL
          // ====================================================

          leadResponse.value =
              LeadResponseModel.fromJson(data);

          // ====================================================
          // RESULT
          // ====================================================

          final result = leadResponse.value?.result;

          debugPrint(
            '========== LEADS RESPONSE =========='
          );

          debugPrint(
            'Success: ${leadResponse.value?.success}',
          );

          debugPrint(
            'Response Status Code: '
            '${leadResponse.value?.responseStatusCode}',
          );

          debugPrint(
            'Response Message: '
            '${leadResponse.value?.responseMessage}',
          );

          debugPrint(
            'Result: $result',
          );

          // ====================================================
          // DOCS
          // ====================================================

          final docs = result?.docs;

          debugPrint(
            'Docs: $docs',
          );

          // ====================================================
          // LEADS
          // ====================================================

          final loadedLeads = docs?.leads ?? [];

          // ====================================================
          // STORE LEADS IN RX LIST
          // ====================================================

          leads.assignAll(loadedLeads);

          debugPrint(
            'Leads Length: ${loadedLeads.length}',
          );

          // ====================================================
          // PAGINATION
          // ====================================================

          final pagination = result?.pagination;

          debugPrint(
            'Total: ${pagination?.total}',
          );

          debugPrint(
            'Page: ${pagination?.page}',
          );

          debugPrint(
            'Limit: ${pagination?.limit}',
          );

          debugPrint(
            'Total Pages: ${pagination?.totalPages}',
          );

          debugPrint(
            'Has Next Page: ${pagination?.hasNextPage}',
          );

          debugPrint(
            'Has Previous Page: ${pagination?.hasPrevPage}',
          );

          // ====================================================
          // PRINT EACH LEAD
          // ====================================================

          for (final lead in loadedLeads) {
            debugPrint(
              '--------------------------------',
            );

            debugPrint(
              'Lead ID: ${lead.id}',
            );

            debugPrint(
              'Name: ${lead.name}',
            );

            debugPrint(
              'Contact: ${lead.contact}',
            );

            debugPrint(
              'Email: ${lead.email}',
            );

            debugPrint(
              'Status: ${lead.status}',
            );

            debugPrint(
              'Check In: ${lead.checkIn}',
            );

            debugPrint(
              'Check Out: ${lead.checkOut}',
            );
          }

          debugPrint(
            '====================================',
          );
        }
      } else {
        debugPrint(
          'Leads API failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint(
        'Get leads error: $e',
      );
    } finally {
      isLeadsLoading.value = false;
    }
  }

  // ============================================================
  // CHANGE HOTEL
  // ============================================================

  Future<void> changeHotel(String hotelId) async {
    if (hotelId.isEmpty) return;

    if (selectedHotelId.value == hotelId) return;

    // ==========================================================
    // CHANGE SELECTED HOTEL
    // ==========================================================

    selectedHotelId.value = hotelId;

    // ==========================================================
    // GET NEW HOTEL LEADS
    // ==========================================================

    await getLeads(hotelId);
  }
}