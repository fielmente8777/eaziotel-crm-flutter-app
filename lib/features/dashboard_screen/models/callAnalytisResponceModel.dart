// lib/features/dashboard_screen/models/callAnalytisResponceModel.dart
//
// GET /api/v1/call/analytics?hid=..&from=..&to=..

// ###################################################################
// MODEL
// ###################################################################

double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;
int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

class CallAnalyticsResponse {
  final bool success;
  final String? message;
  final CallAnalyticsDoc? doc;

  const CallAnalyticsResponse({required this.success, this.message, this.doc});

  factory CallAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;
    final doc = result?['doc'] as Map<String, dynamic>?;
    return CallAnalyticsResponse(
      success: json['success'] == true,
      message: json['responseMessage']?.toString(),
      doc: doc == null ? null : CallAnalyticsDoc.fromJson(doc),
    );
  }
}

class CallAnalyticsDoc {
  final CallSummary summary;
  final List<CallTrendPoint> trend;
  final List<CallCount> statusDistribution;
  final List<CallCount> directionDistribution;
  final List<CallCount> stageDistribution;
  final List<TopCaller> topCallers;

  const CallAnalyticsDoc({
    required this.summary,
    required this.trend,
    required this.statusDistribution,
    required this.directionDistribution,
    required this.stageDistribution,
    required this.topCallers,
  });

  factory CallAnalyticsDoc.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String k) =>
        ((json[k] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();

    return CallAnalyticsDoc(
      summary: CallSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? const {},
      ),
      trend: list('trend').map(CallTrendPoint.fromJson).toList(),
      statusDistribution: list(
        'statusDistribution',
      ).map((e) => CallCount.fromJson(e, 'status')).toList(),
      directionDistribution: list(
        'directionDistribution',
      ).map((e) => CallCount.fromJson(e, 'direction')).toList(),
      stageDistribution: list(
        'stageDistribution',
      ).map((e) => CallCount.fromJson(e, 'stage')).toList(),
      topCallers: list('topCallers').map(TopCaller.fromJson).toList(),
    );
  }
}

class CallMetric {
  final double value;
  final double previous;
  final double change; // %
  final String trend; // up / down / neutral

  const CallMetric({
    required this.value,
    required this.previous,
    required this.change,
    required this.trend,
  });

  static const empty = CallMetric(
    value: 0,
    previous: 0,
    change: 0,
    trend: 'neutral',
  );

  factory CallMetric.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return empty;
    return CallMetric(
      value: _d(json['value']),
      previous: _d(json['previous']),
      change: _d(json['change']),
      trend: (json['trend'] ?? 'neutral').toString(),
    );
  }
}

class CallSummary {
  final CallMetric totalCalls;
  final CallMetric successfulCalls;
  final CallMetric missedCalls;
  final CallMetric followUps;
  final CallMetric totalTalkTime; // seconds
  final CallMetric averageDuration; // seconds
  final double successRate;
  final double missedRate;

  const CallSummary({
    required this.totalCalls,
    required this.successfulCalls,
    required this.missedCalls,
    required this.followUps,
    required this.totalTalkTime,
    required this.averageDuration,
    required this.successRate,
    required this.missedRate,
  });

  factory CallSummary.fromJson(Map<String, dynamic> json) => CallSummary(
    totalCalls: CallMetric.fromJson(json['totalCalls']),
    successfulCalls: CallMetric.fromJson(json['successfulCalls']),
    missedCalls: CallMetric.fromJson(json['missedCalls']),
    followUps: CallMetric.fromJson(json['followUps']),
    totalTalkTime: CallMetric.fromJson(json['totalTalkTime']),
    averageDuration: CallMetric.fromJson(json['averageDuration']),
    successRate: _d(json['successRate']),
    missedRate: _d(json['missedRate']),
  );
}

class CallTrendPoint {
  final DateTime date;
  final int totalCalls;
  final int successfulCalls;
  final int missedCalls;

  const CallTrendPoint({
    required this.date,
    required this.totalCalls,
    required this.successfulCalls,
    required this.missedCalls,
  });

  factory CallTrendPoint.fromJson(Map<String, dynamic> json) => CallTrendPoint(
    date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    totalCalls: _i(json['totalCalls']),
    successfulCalls: _i(json['successfulCalls']),
    missedCalls: _i(json['missedCalls']),
  );
}

class CallCount {
  final String key;
  final int count;

  const CallCount({required this.key, required this.count});

  factory CallCount.fromJson(Map<String, dynamic> json, String keyName) =>
      CallCount(
        key: (json[keyName] ?? '').toString().trim(),
        count: _i(json['count']),
      );
}

class TopCaller {
  final String phoneNumber;
  final int totalCalls;
  final int totalTalkTime; // seconds
  final double averageDuration; // seconds
  final DateTime? lastCall;

  const TopCaller({
    required this.phoneNumber,
    required this.totalCalls,
    required this.totalTalkTime,
    required this.averageDuration,
    this.lastCall,
  });

  factory TopCaller.fromJson(Map<String, dynamic> json) => TopCaller(
    phoneNumber: (json['phoneNumber'] ?? '').toString(),
    totalCalls: _i(json['totalCalls']),
    totalTalkTime: _i(json['totalTalkTime']),
    averageDuration: _d(json['averageDuration']),
    lastCall: DateTime.tryParse((json['lastCall'] ?? '').toString()),
  );
}
