import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class AnalytisService {
  Future<Map<String, dynamic>> getAnalytics({
    required String hid,
    required String startDate,
    required String endDate,
  }) {
    return _get(
      '${AnalytisApiEndpoint.analytics_data}$hid'
      '?startDate=$startDate&endDate=$endDate',
      tag: 'ANALYTICS',
    );
  }

  Future<Map<String, dynamic>> getTrafficSources({
    required String hid,
    required String startDate,
    required String endDate,
  }) {
    return _get(
      '/${AnalytisApiEndpoint.traffic_sources}$hid'
      '?startDate=$startDate&endDate=$endDate',
      tag: 'TRAFFIC SOURCES',
    );
  }

  /// GET google/analytics-pages/{hid}?startDate=..&endDate=..
  Future<Map<String, dynamic>> getTopPages({
    required String hid,
    required String startDate,
    required String endDate,
  }) {
    return _get(
      '/${AnalytisApiEndpoint.analytics_pages}$hid'
      '?startDate=$startDate&endDate=$endDate',
      tag: 'TOP PAGES',
    );
  }

  /// GET google/analytics-conversions/{hid}?startDate=..&endDate=..
  /// events + dashboardMetrics + conversions
  Future<Map<String, dynamic>> getConversions({
    required String hid,
    required String startDate,
    required String endDate,
  }) {
    return _get(
      '/${AnalytisApiEndpoint.analytics_conversions}$hid'
      '?startDate=$startDate&endDate=$endDate',
      tag: 'CONVERSIONS',
    );
  }

  /// GET google/analytics-devices/{hid}?startDate=..&endDate=..
  Future<Map<String, dynamic>> getDevices({
    required String hid,
    required String startDate,
    required String endDate,
  }) {
    return _get(
      '/${AnalytisApiEndpoint.analytics_devices}$hid'
      '?startDate=$startDate&endDate=$endDate',
      tag: 'DEVICES',
    );
  }

  /// GET google/analytics-geo/{hid} — countries + cities
  Future<Map<String, dynamic>> getGeo({
    required String hid,
    required String startDate,
    required String endDate,
  }) {
    return _get(
      '/${AnalytisApiEndpoint.analytics_geo}$hid'
      '?startDate=$startDate&endDate=$endDate',
      tag: 'GEO',
    );
  }

  /// GET google/analytics-audience/{hid} — countries + devices
  Future<Map<String, dynamic>> getAudience({
    required String hid,
    required String startDate,
    required String endDate,
  }) {
    return _get(
      '/${AnalytisApiEndpoint.analytics_audience}$hid'
      '?startDate=$startDate&endDate=$endDate',
      tag: 'AUDIENCE',
    );
  }

  Future<Map<String, dynamic>> _get(String url, {required String tag}) async {
    try {
      final response = await ApiClient.get(
        url,
        authenticated: true,
        baseUrl: BaseUrl.production,
      );

      debugPrint('📊 $tag URL: $url');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ $tag API ERROR: $e');
      debugPrint('STACK: $stackTrace');
      rethrow;
    }
  }
}