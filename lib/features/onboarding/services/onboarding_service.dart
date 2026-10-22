// ============================================================
// ONBOARDING SERVICE  (web: redux/api/onboardingApi.js)
//
//   createWebsite : POST /eazotel/createwebsite   (nexon)  -> { Status, hId }
//   complete      : POST /api/v1/onboarding       (gian)   -> free trial
//   countries / states / cities : countriesnow.space (bina login)
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OnboardingService {
  OnboardingService._();

  static const List<String> _facilityKeys = [
    'FrontDesk', 'Wifi', 'Board', 'Rooftop_Cafe', 'Health_Club',
    'Express_checks', 'Wave_Bar', 'Conference_Hall', 'Alchemy', 'Suncafe',
    'Doctor', 'Spa', 'Babysitting', 'Electricity', 'Concierge',
    'Conditinoer', 'Security', 'TravelTour', 'Currency_Exchange', 'Laundry',
    'Casino', 'Parking', 'Elevator', 'Jacuzzi', 'Room_Service',
    'Accept_Cards', 'Child_Care', 'Conference_Rooms', 'Fitness_Center',
    'Health_&_Beauty', 'Restaurant', 'Swimming_Pool', 'Housekeep',
    'cofeemaker', 'minibar', 'Evpoint', 'SaunaStream',
  ];

  /// Web jaisa hi payload. Sirf form wale field asli hain, baaki default
  /// (hotel baad me dashboard se badalta hai).
  static Map<String, dynamic> _websitePayload(
    String token,
    Map<String, String> f,
  ) => {
    'Token': token,
    'template': '1',
    'hotelName': f['hotelName'],
    'hotelPhone': f['hotelPhone'],
    'hotelAddress': '',
    'hotelState': f['state'],
    'hotelCity': f['city'],
    'hotelCountry': f['country'],
    'hotelPinCode': f['pinCode'],
    'hotelEmail': f['hotelEmail'],
    'oldWebsite': '',
    'planName': 'P1',
    'category': 'Hotel',
    'currency': f['currency'] ?? 'INR',
    'starRating': '3',
    'hasPool': 'false',
    'breakfastOption': <String>[],
    'serveBreakfast': 'false',
    'breakfastIncluded': 'false',
    'parkingType': '',
    'parkingAvailability': 'false',
    'parkingCost': '',
    'parkingLocation': '',
    'pricingStructure': '',
    'reservationRequirement': 'false',
    'logo': '',
    'totalroomCategory': '0',
    'roomCategories': <dynamic>[],
    'bannerVideo': '',
    'hotelDescription': '',
    'customDomain': '',
    'colorCombination': {
      'backgroundColor': '#153B5B',
      'buttonColor': '#0A3A75',
      'fontColor': '#0A3A75',
      'boardColor': '#0A3A75',
    },
    'Facilities': {
      for (final key in _facilityKeys)
        key: key == 'FrontDesk' ? 'true' : 'false',
    },
    'checkInFrom': '12:00',
    'checkInUntil': '23:59',
    'petCharges': '',
    'allowPets': 'false',
    'checkOutFrom': '07:00',
    'allowChildren': 'true',
    'checkOutUntil': '11:00',
    'languages': ['English'],
    'pagesRequired': <String, dynamic>{},
    'establishedSince': '',
    'document': <String, dynamic>{},
    'otaRequired': <String, dynamic>{},
  };

  // ============================================================
  // 1. WEBSITE + HOTEL PROFILE
  // ============================================================

  /// Naye hotel ka hId lautata hai ('' agar server ne nahi diya)
  static Future<String> createWebsite(Map<String, String> form) async {
    final token = await TokenStorage.getAccessToken() ?? '';

    final response = await ApiClient.post(
      OnboardingApiEndpoint.createWebsite,
      // token body me jata hai (web: skipAuth)
      authenticated: false,
      body: _websitePayload(token, form),
      timeout: const Duration(seconds: 60),
    );

    final data = jsonDecode(response.body);
    if (data is! Map || data['Status'] != true) {
      final message = data is Map ? data['Message'] : null;
      throw Exception(message ?? 'Could not create your website.');
    }
    return data['hId']?.toString() ?? '';
  }

  // ============================================================
  // 2. FREE TRIAL
  // ============================================================

  static Future<void> complete(Map<String, String> form) async {
    try {
      await ApiClient.post(
        OnboardingApiEndpoint.complete,
        baseUrl: BaseUrl.production2,
        body: {'propertyDetails': form},
        timeout: const Duration(seconds: 60),
      );
    } on ApiException catch (e) {
      // 409: trial pehle se hai, kuch baaki nahi
      if (e.statusCode != 409) rethrow;
    }
  }

  // ============================================================
  // COUNTRY / STATE / CITY  (na mile to [] -> field text box ban jata hai)
  // ============================================================

  static Future<dynamic> _places(String path, [Map<String, String>? body]) async {
    try {
      final uri = Uri.parse('${OnboardingApiEndpoint.placesUrl}$path');
      final response = body == null
          ? await http.get(uri)
          : await http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            );
      return (jsonDecode(response.body) as Map)['data'];
    } catch (e) {
      debugPrint('ONBOARDING places$path error: $e');
      return null;
    }
  }

  static Future<List<String>> countries() async {
    final data = await _places('');
    if (data is! List) return [];
    return [
      for (final item in data)
        if (item is Map && item['country'] != null) item['country'].toString(),
    ];
  }

  static Future<List<String>> states(String country) async {
    final data = await _places('/states', {'country': country});
    final list = data is Map ? data['states'] : null;
    if (list is! List) return [];
    return [
      for (final item in list)
        if (item is Map && item['name'] != null) item['name'].toString(),
    ];
  }

  static Future<List<String>> cities(String country, String state) async {
    final data = await _places('/state/cities', {
      'country': country,
      'state': state,
    });
    if (data is! List) return [];
    return data.map((e) => e.toString()).toList();
  }
}
