import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/googleAnalytis/models/Conversions%20model.dart';
import 'package:eazotel/features/googleAnalytis/models/analytisdata.dart';
import 'package:eazotel/features/googleAnalytis/models/audienceModle.dart';
 import 'package:eazotel/features/googleAnalytis/models/deviceModle.dart';
import 'package:eazotel/features/googleAnalytis/models/geoModle.dart';
  import 'package:eazotel/features/googleAnalytis/models/featuresModels/analytics_metric.dart';
import 'package:eazotel/features/googleAnalytis/models/featuresModels/filateDateRange.dart';
import 'package:eazotel/features/googleAnalytis/models/topPageModel.dart';
 import 'package:eazotel/features/googleAnalytis/models/traffic_sources_model.dart';
import 'package:eazotel/features/googleAnalytis/services/analytisServices.dart';
import 'package:get/get.dart';

class AnalytisController extends GetxController {
  // Loading
  final isLoading = true.obs; // chart
  final isTrafficLoading = false.obs; // traffic sources
  final isPagesLoading = false.obs; // top pages
  final isConversionsLoading = false.obs; // events + conversions
  final isDevicesLoading = false.obs; // device & tech
  final isGeoLoading = false.obs; // countries + cities
  final isAudienceLoading = false.obs; // users by device / country

  // Hotel ka Google Analytics connect nahi hai
  final isNotConnected = false.obs;
  static const String notConnectedError = 'GA property not connected';

  final hotelId = ''.obs;

  // Data
  final Rxn<AnalyticsModel> analyticsData = Rxn<AnalyticsModel>();
  final Rxn<TrafficSourcesModel> trafficData = Rxn<TrafficSourcesModel>();
  final Rxn<TopPagesModel> topPagesData = Rxn<TopPagesModel>();
  final Rxn<ConversionsModel> conversionsData = Rxn<ConversionsModel>();
  final Rxn<DevicesModel> devicesData = Rxn<DevicesModel>();
  final Rxn<GeoModel> geoData = Rxn<GeoModel>();
  final Rxn<AudienceModel> audienceData = Rxn<AudienceModel>();

  // Filters
  final Rx<DateRangeOption> selectedRange = DateRangeOption.defaultOption.obs;
  final Rx<AnalyticsMetric> selectedMetric = AnalyticsMetric.newUsers.obs;

  final LocationController locationController = Get.put(LocationController());
  final AnalytisService analytisService = Get.put(AnalytisService());

  @override
  void onInit() {
    super.onInit();

    hotelId.value = locationController.selectedHotel.value?.hotelId ?? '';

    ever(locationController.selectedHotel, (hotel) {
      hotelId.value = hotel?.hotelId ?? '';
      if (hotelId.value.isNotEmpty) loadAll();
    });

    if (hotelId.value.isNotEmpty) loadAll();
  }

  void changeMetric(AnalyticsMetric m) => selectedMetric.value = m;

  void changeDateRange(DateRangeOption option) {
    if (selectedRange.value.label == option.label) return;
    selectedRange.value = option;
    loadAll();
  }

  /// Saari APIs ek saath
  Future<void> loadAll() async {
    await Future.wait([
      getAnalytics(),
      getTrafficSources(),
      getTopPages(),
      getConversions(),
      getDevices(),
      getGeo(),
      getAudience(),
    ]);
  }

  Future<void> getAnalytics() async {
    if (hotelId.value.isEmpty) return;
    try {
      isLoading.value = true;
      final json = await analytisService.getAnalytics(
        hid: hotelId.value,
        startDate: selectedRange.value.startDate,
        endDate: selectedRange.value.endDate,
      );

      // API replies {"error":"GA property not connected"} with status 200
      if (json['error'] == notConnectedError) {
        isNotConnected.value = true;
        analyticsData.value = null;
        return;
      }

      isNotConnected.value = false;
      analyticsData.value = AnalyticsModel.fromJson(json);
    } catch (e) {
      // ...or the same body with an error status (ApiClient throws)
      isNotConnected.value =
          e is ApiException &&
          (e.responseBody?.contains(notConnectedError) ?? false);
      print('Analytics Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTrafficSources() async {
    if (hotelId.value.isEmpty) return;
    try {
      isTrafficLoading.value = true;
      final json = await analytisService.getTrafficSources(
        hid: hotelId.value,
        startDate: selectedRange.value.startDate,
        endDate: selectedRange.value.endDate,
      );
      trafficData.value = TrafficSourcesModel.fromJson(json);
    } catch (e) {
      print('Traffic Sources Error: $e');
    } finally {
      isTrafficLoading.value = false;
    }
  }

  Future<void> getTopPages() async {
    if (hotelId.value.isEmpty) return;
    try {
      isPagesLoading.value = true;
      final json = await analytisService.getTopPages(
        hid: hotelId.value,
        startDate: selectedRange.value.startDate,
        endDate: selectedRange.value.endDate,
      );
      topPagesData.value = TopPagesModel.fromJson(json);
    } catch (e) {
      print('Top Pages Error: $e');
      topPagesData.value = null; // purana hotel/range ka data na dikhe
    } finally {
      isPagesLoading.value = false;
    }
  }

  Future<void> getConversions() async {
    if (hotelId.value.isEmpty) return;
    try {
      isConversionsLoading.value = true;
      final json = await analytisService.getConversions(
        hid: hotelId.value,
        startDate: selectedRange.value.startDate,
        endDate: selectedRange.value.endDate,
      );
      conversionsData.value = ConversionsModel.fromJson(json);
    } catch (e) {
      print('Conversions Error: $e');
      conversionsData.value = null;
    } finally {
      isConversionsLoading.value = false;
    }
  }

  Future<void> getDevices() async {
    if (hotelId.value.isEmpty) return;
    try {
      isDevicesLoading.value = true;
      final json = await analytisService.getDevices(
        hid: hotelId.value,
        startDate: selectedRange.value.startDate,
        endDate: selectedRange.value.endDate,
      );
      devicesData.value = DevicesModel.fromJson(json);
    } catch (e) {
      print('Devices Error: $e');
      devicesData.value = null;
    } finally {
      isDevicesLoading.value = false;
    }
  }

  Future<void> getGeo() async {
    if (hotelId.value.isEmpty) return;
    try {
      isGeoLoading.value = true;
      final json = await analytisService.getGeo(
        hid: hotelId.value,
        startDate: selectedRange.value.startDate,
        endDate: selectedRange.value.endDate,
      );
      geoData.value = GeoModel.fromJson(json);
    } catch (e) {
      print('Geo Error: $e');
      geoData.value = null;
    } finally {
      isGeoLoading.value = false;
    }
  }

  Future<void> getAudience() async {
    if (hotelId.value.isEmpty) return;
    try {
      isAudienceLoading.value = true;
      final json = await analytisService.getAudience(
        hid: hotelId.value,
        startDate: selectedRange.value.startDate,
        endDate: selectedRange.value.endDate,
      );
      audienceData.value = AudienceModel.fromJson(json);
    } catch (e) {
      print('Audience Error: $e');
      audienceData.value = null;
    } finally {
      isAudienceLoading.value = false;
    }
  }
}