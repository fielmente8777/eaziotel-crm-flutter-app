import 'dart:convert';

import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart' hide BaseUrl;
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();

  // ============================================================
  // GET
  // ============================================================

  static Future<http.Response> get(
    String endpoint, {
    bool authenticated = true,
    String? baseUrl,
  }) async {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // ============================================================
  // POST
  // ============================================================

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) async {
    return _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // ============================================================
  // PUT
  // ============================================================

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) async {
    return _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) async {
    return _request(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // ============================================================
  // MAIN REQUEST
  // ============================================================

  static Future<http.Response> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool authenticated = true,
    bool retry = true,
    String? baseUrl,
  }) async {
    String? accessToken;

    // ============================================================
    // TOKEN
    // ============================================================

    if (authenticated) {
      accessToken = await TokenStorage.getAccessToken();
    }

    // ============================================================
    // HEADERS
    // ============================================================

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    // ============================================================
    // BASE URL
    // ============================================================

    final server = baseUrl ?? BaseUrl.production;

    final url = Uri.parse('$server$endpoint');

    print('');
    print('========================================');
    print('🌐 API REQUEST');
    print('========================================');
    print('METHOD: $method');
    print('URL: $url');
    print('AUTH: $authenticated');
    print('TOKEN: ${accessToken != null}');
    print('========================================');

    late http.Response response;

    // ============================================================
    // REQUEST
    // ============================================================

    switch (method) {
      case 'GET':
        response = await _client.get(url, headers: headers);
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
          body: body == null ? null : jsonEncode(body),
        );
        break;

      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // ============================================================
    // RESPONSE
    // ============================================================

    print('📡 STATUS: ${response.statusCode}');
    print('📦 RESPONSE: ${response.body}');

    // ============================================================
    // TOKEN EXPIRED
    // ============================================================

    if (response.statusCode == 401 && authenticated && retry) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        return _request(
          method: method,
          endpoint: endpoint,
          body: body,
          authenticated: true,
          retry: false,
          baseUrl: baseUrl,
        );
      }

      await TokenStorage.clearTokens();
    }

    return response;
  }

  // ============================================================
  // GOOGLE AUTH
  // ============================================================

  static Future<http.Response> googleAuth(String idToken) async {
    print('🚀 Sending Google token to backend...');

    final url = Uri.parse(BaseUrl.googleAuthUrl);

    final response = await _client.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({}),
    );

    print('📡 API Status Code: ${response.statusCode}');
    print('📦 API Response: ${response.body}');

    return response;
  }

  // ============================================================
  // REFRESH TOKEN
  // ============================================================

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final url = Uri.parse(
        '${BaseUrl.production}'
        '${AuthApiEndpoint.refreshToken}',
      );

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final data = jsonDecode(response.body);

      final newAccessToken =
          data['accessToken'] ?? data['access_token'] ?? data['token'];

      final newRefreshToken = data['refreshToken'] ?? data['refresh_token'];

      if (newAccessToken == null || newAccessToken.toString().isEmpty) {
        return false;
      }

      await TokenStorage.saveTokens(
        accessToken: newAccessToken.toString(),
        refreshToken: newRefreshToken?.toString() ?? refreshToken,
      );

      return true;
    } catch (e) {
      print('❌ Refresh token error: $e');
      return false;
    }
  }
}
