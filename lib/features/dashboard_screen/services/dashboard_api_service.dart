import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/models/analytics_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/models/callAnalytisResponceModel.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';

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

  // Get leads
  Future<LeadResponseModel> getLeads({
    required String hotelId,
    required int page,
    required int limit,
    String? search,
    List<String>? sources,
    List<String>? stages,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var url =
        '${LeadsApiEndpoint.getLeads}'
        '?hid=$hotelId'
        '&page=$page'
        '&limit=$limit';

    if (search != null && search.trim().isNotEmpty) {
      url += '&search=${Uri.encodeQueryComponent(search.trim())}';
    }

    for (final source in sources ?? []) {
      if (source.trim().isNotEmpty) {
        url += '&source=${Uri.encodeQueryComponent(source.trim())}';
      }
    }

    for (final stage in stages ?? []) {
      if (stage.trim().isNotEmpty) {
        url += '&stage=${Uri.encodeQueryComponent(stage.trim())}';
      }
    }

    if (startDate != null) {
      url += '&from=${Uri.encodeQueryComponent(_formatApiDate(startDate))}';
    }

    if (endDate != null) {
      url += '&to=${Uri.encodeQueryComponent(_formatApiDate(endDate))}';
    }

    final response = await ApiClient.get(
      url,
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );

    final data = jsonDecode(response.body);

    return LeadResponseModel.fromJson(data);
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
  String _formatApiDate(DateTime date) {
    final localDate = date.toLocal();

    final weekday = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ][localDate.weekday - 1];

    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][localDate.month - 1];

    final day = localDate.day.toString().padLeft(2, '0');
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    final second = localDate.second.toString().padLeft(2, '0');

    final offset = localDate.timeZoneOffset;
    final offsetHours = offset.inHours;
    final offsetMinutes = offset.inMinutes.abs() % 60;
    final sign = offset.isNegative ? '-' : '+';

    final offsetString =
        'GMT$sign'
        '${offsetHours.abs().toString().padLeft(2, '0')}'
        '${offsetMinutes == 0 ? '' : ':'}'
        '${offsetMinutes == 0 ? '' : offsetMinutes.toString().padLeft(2, '0')}';

    return '$weekday $month $day '
        '${localDate.year} '
        '$hour:$minute:$second '
        '$offsetString';
  }
}
