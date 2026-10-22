// ============================================================
// ONBOARDING CONTROLLER  (web: pages/Onboarding/OnboardingForm.jsx)
//
// Naya account (koi hotel nahi) -> ye form:
//   1. website + hotel banao   (createWebsite)
//   2. free trial shuru        (complete)
//   3. dashboard dobara load   (ab hotel hai -> seedha dashboard)
//
// Form ka draft phone me save rehta hai, taaki app band ho to bhara hua
// data na jaye. Website ban chuki ho aur trial fail ho, to retry par
// doosri website nahi banti.
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/onboarding/services/onboarding_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  static const String _draftKey = 'onboarding_draft';
  static const String _websiteCreatedKey = 'onboarding_website_created';

  static const List<String> currencies = ['INR', 'USD', 'EUR', 'GBP', 'AED'];

  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  // ---------- Text fields ----------
  final hotelName = TextEditingController();
  final hotelEmail = TextEditingController();
  final hotelPhone = TextEditingController();
  final pinCode = TextEditingController();

  /// Jab places API se list na mile, tab ye text box ban jate hain
  final countryText = TextEditingController();
  final stateText = TextEditingController();
  final cityText = TextEditingController();

  // ---------- Dropdowns ----------
  final currency = 'INR'.obs;
  final country = ''.obs;
  final state = ''.obs;
  final city = ''.obs;

  /// null = load ho raha hai, [] = API ke paas kuch nahi (text box dikhao)
  final countries = Rxn<List<String>>();
  final states = Rxn<List<String>>();
  final cities = Rxn<List<String>>();

  /// field name -> error text
  final errors = <String, String>{}.obs;

  /// '' = khali. Warna button par yahi likha aata hai.
  final submitting = ''.obs;

  bool get busy => submitting.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _restoreDraft();
    for (final c in [
      hotelName,
      hotelEmail,
      hotelPhone,
      pinCode,
      countryText,
      stateText,
      cityText,
    ]) {
      c.addListener(_saveDraft);
    }
    _loadCountries();
  }

  // ============================================================
  // VALUES
  // ============================================================

  String get countryValue =>
      countries.value?.isEmpty == true ? countryText.text.trim() : country.value;
  String get stateValue =>
      states.value?.isEmpty == true ? stateText.text.trim() : state.value;
  String get cityValue =>
      cities.value?.isEmpty == true ? cityText.text.trim() : city.value;

  Map<String, String> get _form => {
    'hotelName': hotelName.text.trim(),
    'currency': currency.value,
    'hotelEmail': hotelEmail.text.trim(),
    'hotelPhone': hotelPhone.text.trim(),
    'country': countryValue,
    'state': stateValue,
    'city': cityValue,
    'pinCode': pinCode.text.trim(),
  };

  void clearError(String field) {
    if (errors.containsKey(field)) errors.remove(field);
  }

  void setCurrency(String value) {
    currency.value = value;
    _saveDraft();
  }

  /// Naye country ke apne states / cities
  void setCountry(String value) {
    if (value == country.value) return;
    country.value = value;
    state.value = '';
    city.value = '';
    cities.value = null;
    clearError('country');
    _saveDraft();
    _loadStates();
  }

  void setState(String value) {
    if (value == state.value) return;
    state.value = value;
    city.value = '';
    clearError('state');
    _saveDraft();
    _loadCities();
  }

  void setCity(String value) {
    city.value = value;
    clearError('city');
    _saveDraft();
  }

  // ============================================================
  // PLACES
  // ============================================================

  Future<void> _loadCountries() async {
    final list = await OnboardingService.countries();
    countries.value = list;
    if (list.isEmpty) {
      // list hi nahi mili: state / city bhi likh kar
      states.value = [];
      cities.value = [];
    } else if (country.value.isNotEmpty) {
      _loadStates();
    }
  }

  Future<void> _loadStates() async {
    states.value = null;
    final forCountry = country.value;
    if (forCountry.isEmpty) return;
    final list = await OnboardingService.states(forCountry);
    if (forCountry != country.value) return; // beech me badal gaya
    states.value = list;
    if (list.isEmpty) {
      cities.value = []; // city bhi likh kar
    } else if (state.value.isNotEmpty) {
      _loadCities();
    }
  }

  Future<void> _loadCities() async {
    cities.value = null;
    final forCountry = country.value;
    final forState = state.value;
    if (forCountry.isEmpty || forState.isEmpty) return;
    final list = await OnboardingService.cities(forCountry, forState);
    if (forCountry != country.value || forState != state.value) return;
    cities.value = list;
  }

  // ============================================================
  // DRAFT
  // ============================================================

  /// Login token me account ka email hota hai, use type nahi karna padta
  Future<String> _tokenEmail() async {
    try {
      final token = await TokenStorage.getAccessToken() ?? '';
      final parts = token.split('.');
      if (parts.length < 2) return '';
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final email = (jsonDecode(payload) as Map)['Email'];
      return email?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _restoreDraft() async {
    Map draft = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      draft = jsonDecode(prefs.getString(_draftKey) ?? '{}') as Map;
    } catch (_) {}

    String read(String key) => draft[key]?.toString() ?? '';

    hotelName.text = read('hotelName');
    hotelPhone.text = read('hotelPhone');
    pinCode.text = read('pinCode');
    hotelEmail.text = read('hotelEmail').isNotEmpty
        ? read('hotelEmail')
        : await _tokenEmail();
    if (currencies.contains(read('currency'))) currency.value = read('currency');
    country.value = read('country');
    state.value = read('state');
    city.value = read('city');
    countryText.text = read('country');
    stateText.text = read('state');
    cityText.text = read('city');

    // countries pehle aa chuke ho to states abhi load karo
    if (countries.value?.isNotEmpty == true && country.value.isNotEmpty) {
      _loadStates();
    }
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, jsonEncode(_form));
    } catch (_) {}
  }

  // ============================================================
  // VALIDATE
  // ============================================================

  static const Map<String, String> _labels = {
    'hotelName': 'Hotel name',
    'currency': 'Currency',
    'hotelEmail': 'Hotel email',
    'hotelPhone': 'Hotel phone',
    'country': 'Country',
    'state': 'State',
    'city': 'City',
    'pinCode': 'PIN / ZIP code',
  };

  bool _validate(Map<String, String> form) {
    final next = <String, String>{};
    form.forEach((name, value) {
      if (value.isEmpty) next[name] = '${_labels[name]} is required';
    });
    final email = form['hotelEmail']!;
    if (email.isNotEmpty && !_emailRe.hasMatch(email)) {
      next['hotelEmail'] = 'Enter a valid email address';
    }
    final phone = form['hotelPhone']!;
    if (phone.isNotEmpty && phone.replaceAll(RegExp(r'\D'), '').length < 7) {
      next['hotelPhone'] = 'Enter a valid phone number';
    }
    errors.assignAll(next);
    return next.isEmpty;
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  /// true = ho gaya (dashboard khud khul jata hai)
  Future<bool> submit() async {
    if (busy) return false;
    final form = _form;
    if (!_validate(form)) return false;

    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getString(_websiteCreatedKey) == null) {
        submitting.value = 'Creating your website...';
        final hid = await OnboardingService.createWebsite(form);
        await prefs.setString(_websiteCreatedKey, hid.isEmpty ? 'true' : hid);
      }

      submitting.value = 'Starting your free trial...';
      await OnboardingService.complete(form);

      submitting.value = 'Opening your dashboard...';
      final hid = prefs.getString(_websiteCreatedKey);
      await prefs.remove(_draftKey);
      await prefs.remove(_websiteCreatedKey);

      // naya hotel hi chuna hua rahe
      if (hid != null && hid != 'true') {
        await prefs.setString(DashboardController.hotelIdKey, hid);
      }

      // Hotel ban gaya: dashboard dobara load -> gate khul jata hai
      final dashboard = Get.find<DashboardController>();
      await dashboard.getUser();
      dashboard.getUserDetails();

      Get.snackbar(
        'Welcome to Eazotel!',
        'Your property is ready.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('ONBOARDING error: $e');
      final message = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Could not finish setup',
        message.isEmpty
            ? 'Could not finish setting up your account. Please try again.'
            : message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );
      return false;
    } finally {
      submitting.value = '';
    }
  }

  @override
  void onClose() {
    for (final c in [
      hotelName,
      hotelEmail,
      hotelPhone,
      pinCode,
      countryText,
      stateText,
      cityText,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
