import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
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
