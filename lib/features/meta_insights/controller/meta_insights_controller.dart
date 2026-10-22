// ============================================================
// META INSIGHTS CONTROLLER  (Drawer > Meta Insights)
//
//   Screen  --->  this controller  --->  MetaInsightsService  --->  API
//                      |
//                      +--> overviewResponse (cards, charts, top posts)
//
// Period changed -> new data. Hotel changed -> new data.
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/meta_overview_response.dart';
import '../services/meta_insights_service.dart';

enum MetaPeriod {
  day('day', 'Today'),
  week('week', 'Last 7 days'),
  days28('28_days', 'Last 28 days'),
  days90('90_days', 'Last 90 days');

  const MetaPeriod(this.value, this.label);

  /// Name used by the server
  final String value;
  final String label;
}

class MetaInsightsController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ============================================================
  // API RESPONSE (model)
  // ============================================================

  final overviewResponse = Rxn<MetaOverviewResponse>();

  MetaOverview get overview =>
      overviewResponse.value?.result ?? const MetaOverview();

  // ============================================================
  // STATE
  // ============================================================

  final period = MetaPeriod.days28.obs;
  final isLoading = true.obs;

  /// null = all good, otherwise this message is shown on screen
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Load again when the hotel changes
    ever(dashboard.selectedHotelId, (_) => load());
    load();
  }

  void changePeriod(MetaPeriod value) {
    if (period.value == value) return;
    period.value = value;
    load();
  }

  Future<void> load() async {
    if (hid.isEmpty) {
      errorMessage.value = 'No hotel selected';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final response = await MetaInsightsService.getPageOverview(
        hid: hid,
        period: period.value.value,
      );

      if (response.success == false) {
        errorMessage.value =
            response.responseMessage ??
            'Could not load the Meta page insights.';
      } else {
        overviewResponse.value = response;
        errorMessage.value = null;
      }
    } catch (e) {
      debugPrint('META INSIGHTS: load error: $e');
      errorMessage.value = _message(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// The server's message (like "Meta page not connected")
  String _message(Object e) {
    if (e is ApiException) {
      try {
        final json = jsonDecode(e.responseBody ?? '');
        if (json is Map && json['responseMessage'] != null) {
          return '${json['responseMessage']}';
        }
      } catch (_) {}
      return e.message;
    }
    return 'Could not load the Meta page insights.';
  }
}
