// ============================================================
// PROFILE SETTING SERVICE
//
// Settings > Profile tab ki API calls. Sirf yahi file server se baat karti hai.
//   changePassword : POST /eazotel/edit/password
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:flutter/foundation.dart';

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

  // ============================================================
  // HOTEL LOCATIONS  (web dashboard jaisa)
  //   add    : POST   /api/v1/profile/hotels          { hotelId, local, ... }
  //   edit   : PUT    /api/v1/profile/hotels/<id>     { local, city, ... }
  //   delete : DELETE /api/v1/profile/hotels/<id>
  // Jawab me poori nayi list aati hai (null = list nahi aayi)
  // ============================================================

  Future<List<HotelModel>?> addHotel({
    required String hotelId,
    required Map<String, String> fields,
  }) => _hotelCall(
    'ADD HOTEL',
    () => ApiClient.post(
      AuthApiEndpoint.profileHotels,
      body: {'hotelId': hotelId, ...fields},
      baseUrl: BaseUrl.production2,
    ),
  );

  Future<List<HotelModel>?> updateHotel({
    required String hotelId,
    required Map<String, String> fields,
  }) => _hotelCall(
    'UPDATE HOTEL',
    () => ApiClient.put(
      AuthApiEndpoint.profileHotel(hotelId),
      body: fields,
      baseUrl: BaseUrl.production2,
    ),
  );

  Future<List<HotelModel>?> deleteHotel(String hotelId) => _hotelCall(
    'DELETE HOTEL',
    () => ApiClient.delete(
      AuthApiEndpoint.profileHotel(hotelId),
      baseUrl: BaseUrl.production2,
    ),
  );

  Future<List<HotelModel>?> _hotelCall(
    String tag,
    Future<dynamic> Function() call,
  ) async {
    final response = await call();

    debugPrint('');
    debugPrint('==================================================');
    debugPrint('🏨 $tag API');
    debugPrint('==================================================');
    debugPrint('URL: ${response.request?.url}');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('BODY: ${response.body}');
    debugPrint('==================================================');

    final json = _decode(response.body);

    // Kuch API 200 ke saath bhi success:false bhejti hain
    if (json['success'] == false) {
      throw Exception(
        '${json['responseMessage'] ?? json['message'] ?? 'Request failed'}',
      );
    }

    final result = json['result'];
    final hotels = result is Map ? result['hotels'] : null;
    if (hotels is! Map) return null;

    return [
      for (final entry in hotels.entries)
        if (entry.value is Map)
          HotelModel.fromJson(
            '${entry.key}',
            Map<String, dynamic>.from(entry.value as Map),
          ),
    ];
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
