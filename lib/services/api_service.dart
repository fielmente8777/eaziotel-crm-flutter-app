import 'dart:convert';

import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart' hide BaseUrl;
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:http/http.dart' as http;



class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();

  static Future<http.Response> get(
    String endpoint, {
    bool authenticated = true,
  }) async {
    return _send(
      method: 'GET',
      endpoint: endpoint,
      authenticated: authenticated,
    );
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    return _send(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
    );
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    return _send(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    bool authenticated = true,
  }) async {
    return _send(
      method: 'DELETE',
      endpoint: endpoint,
      authenticated: authenticated,
    );
  }

  static Future<http.Response> _send({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool authenticated = true,
    bool retry = true,
  }) async {
    String? accessToken;

    if (authenticated) {
      accessToken = await TokenStorage.getAccessToken();
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final url = Uri.parse(
      '${BaseUrl.production}$endpoint',
    );

    http.Response response;

    switch (method) {
      case 'GET':
        response = await _client.get(
          url,
          headers: headers,
        );
        break;

      case 'POST':
        response = await _client.post(
          url,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;

      case 'PUT':
        response = await _client.put(
          url,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;

      case 'DELETE':
        response = await _client.delete(
          url,
          headers: headers,
        );
        break;

      default:
        throw Exception('Unsupported HTTP method');
    }

    // Access token expired
    if (response.statusCode == 401 &&
        authenticated &&
        retry) {
      final refreshed = await _refreshAccessToken();

      if (refreshed) {
        // Retry original API once with new token
        return _send(
          method: method,
          endpoint: endpoint,
          body: body,
          authenticated: authenticated,
          retry: false,
        );
      }

      // Refresh failed
      await TokenStorage.clearTokens();
    }

    return response;
  }

  static Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken =
          await TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final url = Uri.parse(
        '${BaseUrl.production}${AuthApiEndpoint.refreshToken}',
      );

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body);

      final newAccessToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];

      if (newAccessToken == null) {
        return false;
      }

      await TokenStorage.saveTokens(
        accessToken: newAccessToken.toString(),
        refreshToken: newRefreshToken?.toString() ?? refreshToken,
      );

      return true;
    } catch (e) {
      return false;
    }
  }
  // ============================================================
// GOOGLE AUTH API
// ============================================================

static Future<http.Response> googleAuth(
  String idToken,
) async {
  print('🚀 Sending Google token to backend...');

  final url = Uri.parse(
    BaseUrl.googleAuthUrl,
  );

  final response = await _client.post(
    url,

    // Google ID token backend ko bhej rahe hain
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },

    // Backend empty JSON body expect karta hai
    body: jsonEncode({}),
  );

  // ==========================================================
  // API RESPONSE LOG
  // ==========================================================

  print('📡 API Status Code: ${response.statusCode}');
  print('📦 API Response: ${response.body}');

  return response;
}
}