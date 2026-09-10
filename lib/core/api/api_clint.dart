import 'dart:convert';


import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart' hide BaseUrl;
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();

  // GET
  static Future<http.Response> get(
    String endpoint, {
    bool authenticated = true,
  }) async {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      authenticated: authenticated,
    );
  }

  // POST
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    return _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
    );
  }

  // PUT
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    return _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
    );
  }

  // DELETE
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    return _request(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
    );
  }

  // Main request
  static Future<http.Response> _request({
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

    late http.Response response;

    try {
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
            body: body == null ? null : jsonEncode(body),
          );
          break;

        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      rethrow;
    }

    // Access token expired
    if (response.statusCode == 401 &&
        authenticated &&
        retry) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        return _request(
          method: method,
          endpoint: endpoint,
          body: body,
          authenticated: true,
          retry: false,
        );
      }

      await TokenStorage.clearTokens();
    }

    return response;
  }

  // Refresh token
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken =
          await TokenStorage.getRefreshToken();

      if (refreshToken == null ||
          refreshToken.isEmpty) {
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

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return false;
      }

      final data = jsonDecode(response.body);

      final newAccessToken =
          data['accessToken'] ??
          data['access_token'] ??
          data['token'];

      final newRefreshToken =
          data['refreshToken'] ??
          data['refresh_token'];

      if (newAccessToken == null ||
          newAccessToken.toString().isEmpty) {
        return false;
      }

      await TokenStorage.saveTokens(
        accessToken: newAccessToken.toString(),
        refreshToken:
            newRefreshToken?.toString() ?? refreshToken,
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}