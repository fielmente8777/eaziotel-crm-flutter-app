import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eazotel/core/api/apiexception/api_exception.dart';
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
    String? baseUrl,
  }) {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // POST
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) {
    return _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // PUT
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) {
    return _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // DELETE
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) {
    return _request(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  static Future<http.Response> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool authenticated = true,
    bool retry = true,
    String? baseUrl,
  }) async {
    try {
      final token = authenticated ? await TokenStorage.getAccessToken() : null;

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final server = baseUrl ?? BaseUrl.production;
      final url = Uri.parse('$server$endpoint');

      // 🚀 API REQUEST
      print('🚀 $method $url');

      if (body != null) {
        print('📦 Body: $body');
      }

      final response = await _sendRequest(
        method: method,
        url: url,
        headers: headers,
        body: body,
      );

      // 📡 API RESPONSE
      print('📡 Status: ${response.statusCode}');

      // 🔄 Access token expired
      if (response.statusCode == 401 && authenticated && retry) {
        print('🔄 Token expired, refreshing...');

        final refreshed = await _refreshToken();

        if (refreshed) {
          print('✅ Token refreshed');

          return _request(
            method: method,
            endpoint: endpoint,
            body: body,
            authenticated: true,
            retry: false,
            baseUrl: baseUrl,
          );
        }

        print('❌ Token refresh failed');

        await TokenStorage.clearTokens();

        throw ApiException(
          message: 'Session expired. Please login again.',
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );
      }

      // ❌ HTTP error
      if (response.statusCode >= 400) {
        print('❌ API Error: ${response.statusCode}');
        throw _handleHttpError(response);
      }

      return response;
    } on SocketException {
      print('🌐 No internet connection');

      throw ApiException(
        message: 'No internet connection. Please check your network.',
        type: ApiExceptionType.noInternet,
      );
    } on TimeoutException {
      print('⏰ Request timeout');

      throw ApiException(
        message: 'Request timed out. Please try again.',
        type: ApiExceptionType.timeout,
      );
    } on http.ClientException {
      print('❌ Connection error');

      throw ApiException(
        message: 'Unable to connect to server.',
        type: ApiExceptionType.connection,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      print('❌ API Error: $e');

      throw ApiException(
        message: 'Something went wrong. Please try again.',
        type: ApiExceptionType.unknown,
      );
    }
  }

  static Future<http.Response> _sendRequest({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    final encodedBody = body == null ? null : jsonEncode(body);

    switch (method) {
      case 'GET':
        return _client
            .get(url, headers: headers)
            .timeout(const Duration(seconds: 30));

      case 'POST':
        return _client
            .post(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 30));

      case 'PUT':
        return _client
            .put(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 30));

      case 'DELETE':
        return _client
            .delete(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 30));

      default:
        throw ApiException(
          message: 'Unsupported HTTP method: $method',
          type: ApiExceptionType.unknown,
        );
    }
  }

  static ApiException _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return ApiException(
          message: 'Bad request. Please check your data.',
          statusCode: 400,
          type: ApiExceptionType.badRequest,
        );

      case 401:
        return ApiException(
          message: 'Unauthorized. Please login again.',
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );

      case 403:
        return ApiException(
          message: 'You do not have permission to perform this action.',
          statusCode: 403,
          type: ApiExceptionType.forbidden,
        );

      case 404:
        return ApiException(
          message: 'Requested resource was not found.',
          statusCode: 404,
          type: ApiExceptionType.notFound,
        );

      case 408:
        return ApiException(
          message: 'Request timeout. Please try again.',
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );

      case 429:
        return ApiException(
          message: 'Too many requests. Please try again later.',
          statusCode: 429,
          type: ApiExceptionType.tooManyRequests,
        );

      case 500:
        return ApiException(
          message: 'Internal server error.',
          statusCode: 500,
          type: ApiExceptionType.serverError,
        );

      case 502:
      case 503:
      case 504:
        return ApiException(
          message: 'Server is temporarily unavailable.',
          statusCode: response.statusCode,
          type: ApiExceptionType.serverError,
        );

      default:
        return ApiException(
          message: 'Something went wrong. Please try again.',
          statusCode: response.statusCode,
          type: ApiExceptionType.unknown,
        );
    }
  }

  static Future<http.Response> googleAuth(String idToken) async {
    try {
      final response = await _client
          .post(
            Uri.parse(BaseUrl.googleAuthUrl),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 400) {
        throw _handleHttpError(response);
      }

      return response;
    } on SocketException {
      throw ApiException(
        message: 'No internet connection. Please check your network.',
        type: ApiExceptionType.noInternet,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timed out. Please try again.',
        type: ApiExceptionType.timeout,
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Unable to connect to server.',
        type: ApiExceptionType.connection,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Google Login Error: $e');

      throw ApiException(
        message: 'Google login failed. Please try again.',
        type: ApiExceptionType.unknown,
      );
    }
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final url = Uri.parse(
        '${BaseUrl.production}${AuthApiEndpoint.refreshToken}',
      );

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

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
      print('Refresh Token Error: $e');
      return false;
    }
  }
}
