// ============================================================
// GOOGLE ADS DEVICE RESPONSE
// GET /api/v1/google-ads/metrics/devices/<id>?level=&startDate=&endDate=
//   result.devices : [{"device": 2, "clicks": 120}, ...]
// ============================================================

import 'google_ads_common.dart';

class GoogleAdsDeviceResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final GoogleAdsRequest? request;
  final List<GoogleAdsDevice> devices;

  GoogleAdsDeviceResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.devices = const [],
  });

  /// Add up clicks by device name (dropping zeros) -> donut chart
  List<GoogleAdsDevice> get grouped {
    final map = <String, double>{};

    for (final d in devices) {
      map[d.name] = (map[d.name] ?? 0) + d.clicks;
    }

    return [
      for (final e in map.entries)
        if (e.value > 0) GoogleAdsDevice(device: e.key, clicks: e.value),
    ];
  }

  factory GoogleAdsDeviceResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final rows = result is Map ? result['devices'] : null;

    return GoogleAdsDeviceResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: GoogleAdsRequest.tryParse(json['request']),
      devices: rows is List
          ? rows
                .whereType<Map>()
                .map(
                  (e) => GoogleAdsDevice.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'devices': devices.map((d) => d.toJson()).toList(),
    };
  }
}

class GoogleAdsDevice {
  /// Google's number ("2") or name ("Mobile")
  final String device;
  final double clicks;

  const GoogleAdsDevice({required this.device, required this.clicks});

  static const Map<String, String> _names = {
    '2': 'Mobile',
    '3': 'Tablet',
    '4': 'Desktop',
    '5': 'Smart TV',
    '6': 'Other',
  };

  /// "2" -> "Mobile" (keeps the name if it already has one)
  String get name =>
      _names[device] ?? (_names.containsValue(device) ? device : 'Other');

  factory GoogleAdsDevice.fromJson(Map<String, dynamic> json) {
    return GoogleAdsDevice(
      device: adsStr(json['device']),
      clicks: adsNum(json['clicks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'device': device, 'clicks': clicks};
  }
}
