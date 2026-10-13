// ============================================================
// PROFILE SETTING SERVICE
//
// Settings > Profile tab ki API calls. Sirf yahi file server se baat karti hai.
//   changePassword : POST /eazotel/edit/password
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';

import '../models/change_password_result.dart';

/// Settings > Profile tab ki saari API calls yahan hain.
/// Controller sirf state sambhalta hai, server se baat ye class karti hai.
class ProfileSettingService {
  /// POST /eazotel/edit/password
  /// body: {"token": "..", "oldAccessId": "..", "newAccessId": ".."}
  Future<ChangePasswordResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      return const ChangePasswordResult.failure('Please log in again');
    }

    try {
      final response = await ApiClient.post(
        AuthApiEndpoint.changePassword,
        authenticated: false,
        body: {
          'token': token,
          'oldAccessId': currentPassword,
          'newAccessId': newPassword,
        },
      );

      return ChangePasswordResult.fromJson(_decode(response.body));
    } on ApiException catch (e) {
      final message = ChangePasswordResult.fromJson(
        _decode(e.responseBody ?? ''),
      ).message;

      return ChangePasswordResult.failure(message ?? e.message);
    }
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final data = jsonDecode(body);

      return data is Map ? Map<String, dynamic>.from(data) : {};
    } catch (_) {
      return {};
    }
  }
}
