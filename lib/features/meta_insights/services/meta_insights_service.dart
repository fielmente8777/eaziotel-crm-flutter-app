// ============================================================
// META INSIGHTS SERVICE
//   getPageOverview : GET /api/v1/meta/page/overview?hid=&period=
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import '../models/meta_overview_response.dart';

class MetaInsightsService {
  MetaInsightsService._();

  static Future<MetaOverviewResponse> getPageOverview({
    required String hid,
    required String period,
  }) async {
    final endpoint = '${MetaApiEndpoint.pageOverview}?hid=$hid&period=$period';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📘 META PAGE OVERVIEW API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // JSON → Model
      return MetaOverviewResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ META PAGE OVERVIEW API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
