// lib/features/googleAnalytis/models/conversions_model.dart

int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

class ConversionsModel {
  final List<ConversionItem> conversions;
  final DashboardMetrics metrics;
  final List<EventItem> events;

  const ConversionsModel({
    required this.conversions,
    required this.metrics,
    required this.events,
  });

  factory ConversionsModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String k) =>
        ((json[k] as List?) ?? const []).whereType<Map<String, dynamic>>().toList();

    return ConversionsModel(
      conversions: list('conversions').map(ConversionItem.fromJson).toList(),
      metrics: DashboardMetrics.fromJson(
        (json['dashboardMetrics'] as Map<String, dynamic>?) ?? const {},
      ),
      events: list('events').map(EventItem.fromJson).toList(),
    );
  }
}

class EventItem {
  final String eventName;
  final int eventCount;
  final int users;

  const EventItem({
    required this.eventName,
    required this.eventCount,
    required this.users,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) => EventItem(
        eventName: (json['eventName'] ?? '').toString(),
        eventCount: _i(json['eventCount']),
        users: _i(json['users']),
      );

  /// Ek user ne average kitni baar trigger kiya
  double get perUser => users == 0 ? 0 : eventCount / users;
}

class DashboardMetrics {
  final int callClicks;
  final int formSubmissions;
  final int whatsappClicks;

  const DashboardMetrics({
    required this.callClicks,
    required this.formSubmissions,
    required this.whatsappClicks,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) =>
      DashboardMetrics(
        callClicks: _i(json['call_clicks']),
        formSubmissions: _i(json['form_submissions']),
        whatsappClicks: _i(json['whatsapp_clicks']),
      );

  int get total => callClicks + formSubmissions + whatsappClicks;
}

/// `conversions` abhi empty aa raha hai — shape pakka nahi,
/// isliye common keys tolerate kar rahe hain.
class ConversionItem {
  final String name;
  final int count;

  const ConversionItem({required this.name, required this.count});

  factory ConversionItem.fromJson(Map<String, dynamic> json) => ConversionItem(
        name: (json['eventName'] ??
                json['conversionName'] ??
                json['name'] ??
                '')
            .toString(),
        count: _i(json['conversions'] ??
            json['eventCount'] ??
            json['count'] ??
            json['keyEvents']),
      );
}