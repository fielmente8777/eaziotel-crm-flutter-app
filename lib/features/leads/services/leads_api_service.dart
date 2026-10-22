// ============================================================
// LEADS API SERVICE  (Leads feature)
//
//   getLeads : GET /leads?hid=&page=&limit=&search=&source=&stage=&from=&to=
//
// This used to be in DashboardApiService; the code was moved here as is.
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/leads/models/leads_responce_modle.dart';

class LeadsApiService {
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
