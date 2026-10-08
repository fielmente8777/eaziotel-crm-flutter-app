import 'package:eazotel/core/api/apiexception/api_error_handler.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/dashboard_screen/models/callAnalytisResponceModel.dart';
import 'package:eazotel/features/dashboard_screen/services/dashboard_api_service.dart';
import 'package:get/get.dart';

// Call analytics part of DashboardController.
mixin DashboardCallAnalyticsMixin on GetxController {
  // Provided by DashboardController
  DashboardApiService get apiService;
  RxString get selectedHotelId;

  final callAnalytics = Rxn<CallAnalyticsResponse>();
  final isCallAnalyticsLoading = false.obs;
  final callRangeDays = 30.obs; // 1 / 7 / 30 / 90

  Future<void> getCallAnalytics([String? hotelId]) async {
    final hid = (hotelId ?? selectedHotelId.value).trim();

    // savedHotelId.toString() gives "null" when nothing is saved
    if (hid.isEmpty || hid == 'null') return;

    // Local day boundaries → UTC (IST midnight = 18:30Z previous day)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = today.subtract(Duration(days: callRangeDays.value - 1));
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    try {
      isCallAnalyticsLoading.value = true;

      final result = await apiService.getCallAnalytics(
        hotelId: hid,
        from: from,
        to: to,
      );

      // Hotel changed while this request was running → ignore old result
      if (hid != selectedHotelId.value) return;

      callAnalytics.value = result;
    } on ApiException catch (e) {
      ApiErrorHandler.handle(e);
    } catch (e) {
      print('getCallAnalytics error: $e');
    } finally {
      isCallAnalyticsLoading.value = false;
    }
  }

  Future<void> changeCallRange(int days) async {
    if (callRangeDays.value == days) return;
    callRangeDays.value = days;
    await getCallAnalytics();
  }
}
