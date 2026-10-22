import 'dart:convert';
import 'package:eazotel/core/local_storage/token_storage.dart';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/dashboard_screen/models/auth_user_model.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/analytics_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/models/callAnalytisResponceModel.dart';

class DashboardApiService {
  // Get user profile
  Future<ProfileResponseModel> getUserProfile(String token) async {
    final response = await ApiClient.get(
      '${AuthApiEndpoint.getUserProfile}/$token',
      authenticated: false,
    );

    final data = jsonDecode(response.body);

    return ProfileResponseModel.fromJson(data);
  }

  // ============================================================
  // LOGIN KIYA HUA USER (role, isAdmin, assigned_location)
  // GET https://nexon.eazotel.com/user/user-details  (Bearer token)
  // ============================================================

  Future<AuthUserModel?> getAuthUser({String? accessToken}) async {
    final response = await ApiClient.get(
      AuthApiEndpoint.userDetails,
      accessToken: accessToken,
      authenticated: true,
    );

    final data = jsonDecode(response.body);
    final user = data is Map ? data['User'] : null;

    return user is Map
        ? AuthUserModel.fromJson(Map<String, dynamic>.from(user))
        : null;
  }

  // ============================================================
  // OWNER: CLIENT ACCOUNTS
  // ============================================================

  /// GET /admin/get-all-clients
  Future<List<ClientAccountModel>> getAllClients() async {
    final response = await ApiClient.get(
      AuthApiEndpoint.allClients,
      accessToken: await TokenStorage.getOwnerAccessToken(),
      authenticated: true,
    );

    final data = jsonDecode(response.body);
    final list = data is Map ? data['data'] : null;

    return [
      if (list is List)
        for (final item in list)
          if (item is Map)
            ClientAccountModel.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  /// POST /admin/switch-account { Email } -> client ka naya token (null = fail)
  Future<String?> switchAccount(String email) async {
    final response = await ApiClient.post(
      AuthApiEndpoint.switchAccount,
      accessToken: await TokenStorage.getOwnerAccessToken(),
      body: {'Email': email},
      authenticated: true,
    );

    final data = jsonDecode(response.body);
    if (data is! Map || data['Status'] != true) return null;

    final token = '${data['Token'] ?? ''}'.trim();
    return token.isEmpty ? null : token;
  }

  // Get user details
  Future<UserResponseModel> getUserDetails(String token) async {
    final response = await ApiClient.get(
      '${AuthApiEndpoint.UserProfile}/$token',
      authenticated: false,
    );

    final data = jsonDecode(response.body);

    return UserResponseModel.fromJson(data);
  }

  // Get analytics
  Future<AnalyticsResponse> getAnalytics(String hotelId) async {
    final response = await ApiClient.get(
      '${analytics.getLeads}?hid=$hotelId&limit=500',
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );

    final data = jsonDecode(response.body);

    return AnalyticsResponse.fromJson(data);
  }

  // Get call analytics
  //
  // from / to are local DateTimes (start of first day, end of last day).
  // They are sent as UTC ISO strings, e.g. for 5 Oct - 6 Oct in IST:
  // from=2026-10-04T18:30:00.000Z  to=2026-10-06T18:29:59.999Z
  Future<CallAnalyticsResponse> getCallAnalytics({
    required String hotelId,
    required DateTime from,
    required DateTime to,
  }) async {
    final url =
        '${CallApiEndpoint.analytics}'
        '?hid=$hotelId'
        '&from=${Uri.encodeQueryComponent(from.toUtc().toIso8601String())}'
        '&to=${Uri.encodeQueryComponent(to.toUtc().toIso8601String())}';

    final response = await ApiClient.get(
      url,
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );
    final data = jsonDecode(response.body);

    return CallAnalyticsResponse.fromJson(data);
  }

  // Format date for API
}
