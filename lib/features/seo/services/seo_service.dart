// ============================================================
// SEO SERVICE
//
// Local SEO + Website SEO ki saari API. Har function:
//   API call  ->  log (URL, STATUS, BODY)  ->  JSON  ->  Response model
//
//   getSeoIntelligence    : GET    /seo-intelligence
//   getSeoTokens          : GET    /seo-intelligence/tokens
//   trackKeywords         : POST   /seo-intelligence/track
//   suggestKeywords       : POST   /seo-intelligence/suggest-keywords
//   saveOnboarding        : POST   /seo-intelligence/onboarding
//   triggerGridScan       : POST   /seo-intelligence/trigger-grid-scan
//   updateRadius          : POST   /seo-intelligence/update-radius
//   updateGridKeyword     : POST   /seo-intelligence/update-grid-keyword
//   setWebsite            : POST   /seo-intelligence/set-website
//   updateWebsiteCountry  : POST   /seo-intelligence/update-website-country
//   trackWebsiteKeywords  : POST   /seo-intelligence/track-link
//   refreshKeyword        : POST   /seo-intelligence/refresh-keyword
//   untrackKeyword        : DELETE /seo-intelligence/<keyword>
//   reverseGeocode        : OpenStreetMap se lat/lng ka pata
//
// Credit kam ho to API 402 deti hai -> tokenShortage(e) se message.
// ============================================================

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import '../models/seo_action_response.dart';
import '../models/seo_address.dart';
import '../models/seo_intelligence_response.dart';
import '../models/seo_suggestion_response.dart';
import '../models/seo_token_response.dart';

class SeoService {
  SeoService._();

  static const String _base = BaseUrl.production2;

  // ============================================================
  // SEO DATA (keywords, config, geo grid, trend)
  // ============================================================

  static Future<SeoIntelligenceResponse> getSeoIntelligence() async {
    // "t" = purana (cache) data na aaye
    final endpoint =
        '${SeoApiEndpoint.intelligence}?t=${DateTime.now().millisecondsSinceEpoch}';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: _base,
      );

      _log(
        'SEO INTELLIGENCE API',
        endpoint,
        response.statusCode,
        response.body,
      );

      // JSON → Model
      return SeoIntelligenceResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO INTELLIGENCE API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // CREDITS
  // ============================================================

  static Future<SeoTokenResponse> getSeoTokens() async {
    const endpoint = SeoApiEndpoint.tokens;

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: _base,
      );

      _log('SEO TOKENS API', endpoint, response.statusCode, response.body);

      return SeoTokenResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO TOKENS API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // LOCAL SEO: keyword jodo
  // ============================================================

  static Future<SeoActionResponse> trackKeywords({
    required List<String> keywords,
    String selfDomain = '',
    String selfHotelName = '',
  }) async {
    const endpoint = SeoApiEndpoint.track;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {
          'keywords': keywords,
          'selfDomain': selfDomain,
          'selfHotelName': selfHotelName,
        },
      );

      _log(
        'SEO TRACK KEYWORDS API',
        endpoint,
        response.statusCode,
        response.body,
      );

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO TRACK KEYWORDS API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // LOCAL SEO SETUP: keyword sujhao
  // ============================================================

  static Future<SeoSuggestionResponse> suggestKeywords({
    required String businessType,
    required String city,
    required String district,
    String state = '',
  }) async {
    const endpoint = SeoApiEndpoint.suggestKeywords;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {
          'businessType': businessType,
          'city': city,
          'district': district,
          'state': state,
        },
      );

      _log(
        'SEO SUGGEST KEYWORDS API',
        endpoint,
        response.statusCode,
        response.body,
      );

      return SeoSuggestionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO SUGGEST KEYWORDS API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // LOCAL SEO SETUP: property + location save
  // ============================================================

  static Future<SeoActionResponse> saveOnboarding({
    required String businessName,
    required double lat,
    required double lng,
    required int radiusKm,
    required String city,
    required String district,
    required String primaryKeyword,
    String state = '',
    String pincode = '',
    String selfDomain = '',
  }) async {
    const endpoint = SeoApiEndpoint.onboarding;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {
          'businessName': businessName,
          'lat': lat,
          'lng': lng,
          'radiusKm': radiusKm,
          'city': city,
          'district': district,
          'state': state,
          'pincode': pincode,
          'selfDomain': selfDomain,
          'selfHotelName': businessName,
          'primaryKeyword': primaryKeyword,
        },
      );

      _log('SEO ONBOARDING API', endpoint, response.statusCode, response.body);

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO ONBOARDING API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // LOCAL SEO: map coverage dobara scan
  // ============================================================

  static Future<SeoActionResponse> triggerGridScan() async {
    const endpoint = SeoApiEndpoint.triggerGridScan;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: const {},
      );

      _log('SEO GRID SCAN API', endpoint, response.statusCode, response.body);

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO GRID SCAN API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // LOCAL SEO: radius (2 / 5 / 10 km)
  // ============================================================

  static Future<SeoActionResponse> updateRadius({required int radiusKm}) async {
    const endpoint = SeoApiEndpoint.updateRadius;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {'radiusKm': radiusKm},
      );

      _log(
        'SEO UPDATE RADIUS API',
        endpoint,
        response.statusCode,
        response.body,
      );

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO UPDATE RADIUS API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // LOCAL SEO: map coverage kis keyword par
  // ============================================================

  static Future<SeoActionResponse> updateGridKeyword({
    required String keyword,
  }) async {
    const endpoint = SeoApiEndpoint.updateGridKeyword;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {'keyword': keyword},
      );

      _log(
        'SEO GRID KEYWORD API',
        endpoint,
        response.statusCode,
        response.body,
      );

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO GRID KEYWORD API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // WEBSITE SEO: website link lock (ek hi baar)
  // ============================================================

  static Future<SeoActionResponse> setWebsite({
    required String websiteUrl,
  }) async {
    const endpoint = SeoApiEndpoint.setWebsite;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {'websiteUrl': websiteUrl},
      );

      _log('SEO SET WEBSITE API', endpoint, response.statusCode, response.body);

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO SET WEBSITE API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // WEBSITE SEO: desh (IN / US / WORLD ...)
  // ============================================================

  static Future<SeoActionResponse> updateWebsiteCountry({
    required String country,
  }) async {
    const endpoint = SeoApiEndpoint.updateWebsiteCountry;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {'country': country},
      );

      _log(
        'SEO WEBSITE COUNTRY API',
        endpoint,
        response.statusCode,
        response.body,
      );

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO WEBSITE COUNTRY API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // WEBSITE SEO: keyword jodo
  // ============================================================

  static Future<SeoActionResponse> trackWebsiteKeywords({
    required List<String> keywords,
  }) async {
    const endpoint = SeoApiEndpoint.trackLink;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {'keywords': keywords},
      );

      _log('SEO TRACK LINK API', endpoint, response.statusCode, response.body);

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO TRACK LINK API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // DONO: ek keyword ka rank taaza karo
  // ============================================================

  static Future<SeoActionResponse> refreshKeyword({
    required String keyword,
  }) async {
    const endpoint = SeoApiEndpoint.refreshKeyword;

    try {
      final response = await ApiClient.post(
        endpoint,
        authenticated: true,
        baseUrl: _base,
        body: {'keyword': keyword},
      );

      _log(
        'SEO REFRESH KEYWORD API',
        endpoint,
        response.statusCode,
        response.body,
      );

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO REFRESH KEYWORD API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // DONO: keyword hatao
  // ============================================================

  static Future<SeoActionResponse> untrackKeyword({
    required String keyword,
  }) async {
    final endpoint = SeoApiEndpoint.untrack(keyword);

    try {
      final response = await ApiClient.delete(
        endpoint,
        authenticated: true,
        baseUrl: _base,
      );

      _log(
        'SEO UNTRACK KEYWORD API',
        endpoint,
        response.statusCode,
        response.body,
      );

      return SeoActionResponse.fromJson(_decode(response.body));
    } catch (e, stackTrace) {
      _logError('SEO UNTRACK KEYWORD API', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // LOCATION: lat/lng -> city, district, state, pincode
  // ============================================================

  static final Dio _dio = Dio();

  static Future<SeoAddress> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    const url = 'https://nominatim.openstreetmap.org/reverse';

    try {
      final response = await _dio.get(
        url,
        queryParameters: {'lat': lat, 'lon': lng, 'format': 'json', 'zoom': 14},
        // OpenStreetMap ko app ka naam chahiye
        options: Options(headers: {'User-Agent': 'com.eazotel.app'}),
      );

      final data = response.data;

      return data is Map
          ? SeoAddress.fromJson(Map<String, dynamic>.from(data))
          : const SeoAddress();
    } catch (e, stackTrace) {
      _logError('SEO REVERSE GEOCODE', e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  /// 402 (credit kam) -> "Not enough tokens. Need 4, have 2."
  /// Baaki error -> null
  static String? tokenShortage(Object error) {
    if (error is! ApiException || error.statusCode != 402) return null;

    final body = _errorBody(error);
    final required = body['required'];
    final available = body['available'];

    if (required == null || available == null) {
      return 'Not enough tokens. Please add more credits.';
    }

    return 'Not enough tokens. Need $required, have $available.';
  }

  /// API ka "error" / "message" text, warna [fallback]
  static String errorMessage(Object error, String fallback) {
    if (error is ApiException) {
      final body = _errorBody(error);
      final text = (body['error'] ?? body['message'] ?? '').toString();
      if (text.trim().isNotEmpty) return text;
    }
    return fallback;
  }

  static Map<String, dynamic> _errorBody(ApiException error) {
    try {
      final json = jsonDecode(error.responseBody ?? '');
      return json is Map ? Map<String, dynamic>.from(json) : {};
    } catch (_) {
      return {};
    }
  }

  // ============================================================
  // HELPERS (JSON + log)
  // ============================================================

  /// JSON decode (DELETE me body khali bhi ho sakti hai)
  static Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return {};

    final json = jsonDecode(body);
    return json is Map ? Map<String, dynamic>.from(json) : {'result': json};
  }

  static void _log(String title, String endpoint, int status, String body) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('🔎 $title');
    debugPrint('==================================================');
    debugPrint('URL: $_base$endpoint');
    debugPrint('STATUS: $status');
    debugPrint('BODY: $body');
    debugPrint('==================================================');
  }

  static void _logError(String title, Object e, StackTrace stackTrace) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('❌ $title ERROR');
    debugPrint('==================================================');
    debugPrint('ERROR: $e');
    debugPrint('STACK: $stackTrace');
    debugPrint('==================================================');
  }
}
