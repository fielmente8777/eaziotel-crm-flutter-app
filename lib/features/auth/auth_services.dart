import 'dart:convert';

import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/services/api_service.dart';



class AuthService {
  AuthService._();

  static Future<bool> login({
    required String email,
    required String accessKey,
  }) async {
    try {
      final response = await ApiClient.post(
        AuthApiEndpoint.login,
        authenticated: false,
        body: {
          'register': 'false',
          'emailId': email,
          'userName': '',
          'accesskey': accessKey,
        },
      );

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN RESPONSE: ${response.body}');

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return false;
      }

      final data = jsonDecode(response.body);

      /*
       * Change these keys according to
       * your actual API response.
       */

      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      if (accessToken == null ||
          accessToken.toString().isEmpty) {
        return false;
      }

      await TokenStorage.saveTokens(
        accessToken: accessToken.toString(),
        refreshToken: refreshToken?.toString(),
      );

      return true;
    } catch (e) {
      print('LOGIN ERROR: $e');

      return false;
    }
  }

  static Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}