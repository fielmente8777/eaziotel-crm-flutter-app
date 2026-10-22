// ============================================================
// LOCAL SEO SETUP CONTROLLER  (the 3-step wizard for the first time)
//
//   Step 1  Business : name, type (hotel/resort...), website
//   Step 2  Location : tap on the map / GPS -> lat, lng, district, city
//   Step 3  Keywords : suggestions from the API (if it fails, we make our own)
//
//   Finish -> onboarding API + track API (selected keywords)
// ============================================================

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../services/seo_service.dart';

class LocalSeoSetupController extends GetxController {
  static const List<String> businessTypes = [
    'hotel',
    'resort',
    'hostel',
    'homestay',
    'villa',
    'retreat',
    'glamping',
  ];

  final step = 1.obs;

  // ---------- Step 1 ----------
  final name = TextEditingController();
  final domain = TextEditingController();
  final businessType = 'hotel'.obs;

  // ---------- Step 2 ----------
  final lat = TextEditingController();
  final lng = TextEditingController();
  final district = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final radiusKm = 5.obs;
  String _pincode = '';

  final isLocating = false.obs;
  final locationError = ''.obs;

  // ---------- Step 3 ----------
  final custom = TextEditingController();
  final suggestions = <String>[].obs;
  final selected = <String>{}.obs;
  final isSuggesting = false.obs;
  final isSaving = false.obs;

  /// To turn the button on/off when the text changes
  final _tick = 0.obs;

  List<TextEditingController> get _fields => [
    name,
    domain,
    lat,
    lng,
    district,
    city,
    state,
    custom,
  ];

  @override
  void onInit() {
    super.onInit();
    for (final field in _fields) {
      field.addListener(() => _tick.value++);
    }
  }

  @override
  void onClose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.onClose();
  }

  // ============================================================
  // WHEN WE CAN GO NEXT
  // ============================================================

  double? get latValue => double.tryParse(lat.text.trim());
  double? get lngValue => double.tryParse(lng.text.trim());

  bool get canLeaveStep1 {
    _tick.value;
    return name.text.trim().length > 2;
  }

  bool get canLeaveStep2 {
    _tick.value;
    return latValue != null &&
        lngValue != null &&
        district.text.trim().isNotEmpty &&
        city.text.trim().isNotEmpty;
  }

  bool get hasCustomText {
    _tick.value;
    return custom.text.trim().isNotEmpty;
  }

  void goTo(int value) {
    step.value = value;
    if (value == 3 && suggestions.isEmpty) fetchSuggestions();
  }

  // ============================================================
  // STEP 2: LOCATION
  // ============================================================

  /// Tap on the map / GPS: fill lat-lng, then fill the address by itself
  Future<void> setPoint(double latitude, double longitude) async {
    lat.text = latitude.toStringAsFixed(6);
    lng.text = longitude.toStringAsFixed(6);
    locationError.value = '';

    try {
      final address = await SeoService.reverseGeocode(
        lat: latitude,
        lng: longitude,
      );

      if (address.city.isNotEmpty) city.text = address.city;
      if (address.district.isNotEmpty) district.text = address.district;
      if (address.state.isNotEmpty) state.text = address.state;
      _pincode = address.pincode;
    } catch (_) {
      // If the address is not found, the user can fill it in
    }
  }

  /// Return: lat/lng if found (to move the map there)
  Future<({double lat, double lng})?> detectLocation() async {
    if (isLocating.value) return null;

    isLocating.value = true;
    locationError.value = '';

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        locationError.value = 'Please turn on location (GPS).';
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        locationError.value =
            'Could not get location. Tap on the map or enter it manually.';
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await setPoint(position.latitude, position.longitude);
      return (lat: position.latitude, lng: position.longitude);
    } catch (e) {
      debugPrint('LOCAL SEO SETUP: location error: $e');
      locationError.value =
          'Could not get location. Tap on the map or enter it manually.';
      return null;
    } finally {
      isLocating.value = false;
    }
  }

  // ============================================================
  // STEP 3: KEYWORDS
  // ============================================================

  Future<void> fetchSuggestions() async {
    if (city.text.trim().isEmpty || district.text.trim().isEmpty) return;

    isSuggesting.value = true;

    try {
      final response = await SeoService.suggestKeywords(
        businessType: businessType.value,
        city: city.text.trim(),
        district: district.text.trim(),
        state: state.text.trim(),
      );

      suggestions.assignAll(
        response.suggestions.isEmpty ? _fallback() : response.suggestions,
      );
    } catch (_) {
      // Same as web: if the API fails, make them ourselves
      suggestions.assignAll(_fallback());
    } finally {
      isSuggesting.value = false;
    }
  }

  List<String> _fallback() {
    final bt = businessType.value;
    final ci = city.text.trim().toLowerCase();
    final di = district.text.trim().toLowerCase();

    return [
      '$bt in $di',
      'best $bt in $di',
      '$bt near $di',
      '$bt $ci',
      'budget $bt $di',
      'luxury $bt $di',
      '$bt near me $ci',
      'book $bt $di',
    ];
  }

  void toggle(String keyword) {
    if (!selected.remove(keyword)) selected.add(keyword);
  }

  void addCustom() {
    final keyword = custom.text.trim();
    if (keyword.isEmpty) return;

    if (!suggestions.contains(keyword)) suggestions.add(keyword);
    selected.add(keyword);
    custom.clear();
  }

  // ============================================================
  // FINISH
  // ============================================================

  /// Return: null = done, text = error
  Future<String?> submit() async {
    if (selected.isEmpty || isSaving.value) return null;

    isSaving.value = true;
    final keywords = selected.toList();

    try {
      await SeoService.saveOnboarding(
        businessName: name.text.trim(),
        lat: latValue ?? 0,
        lng: lngValue ?? 0,
        radiusKm: radiusKm.value,
        city: city.text.trim(),
        district: district.text.trim(),
        state: state.text.trim(),
        pincode: _pincode,
        selfDomain: domain.text.trim(),
        primaryKeyword: keywords.first,
      );

      await SeoService.trackKeywords(
        keywords: keywords,
        selfDomain: domain.text.trim(),
        selfHotelName: name.text.trim(),
      );

      return null;
    } catch (e) {
      return SeoService.tokenShortage(e) ??
          SeoService.errorMessage(e, 'Setup failed. Please try again.');
    } finally {
      isSaving.value = false;
    }
  }
}
