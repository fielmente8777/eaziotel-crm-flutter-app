class AnalyticsModel {
  final String? activePropertyId;
  final List<ChartData>? chartData;
  final String? email;

  AnalyticsModel({
    this.activePropertyId,
    this.chartData,
    this.email,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      activePropertyId: json['activePropertyId'] as String?,
      chartData: (json['chartData'] as List<dynamic>?)
          ?.map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activePropertyId': activePropertyId,
      'chartData': chartData?.map((e) => e.toJson()).toList(),
      'email': email,
    };
  }
}

class ChartData {
  final double? avgSessionDuration;
  final double? bounceRate;
  final String? date;
  final int? eventCount;
  final int? newUsers;
  final int? pageViews;
  final int? sessions;
  final int? users;

  ChartData({
    this.avgSessionDuration,
    this.bounceRate,
    this.date,
    this.eventCount,
    this.newUsers,
    this.pageViews,
    this.sessions,
    this.users,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      avgSessionDuration:
          (json['avgSessionDuration'] as num?)?.toDouble(),

      bounceRate:
          (json['bounceRate'] as num?)?.toDouble(),

      date: json['date'] as String?,

      eventCount:
          (json['eventCount'] as num?)?.toInt(),

      newUsers:
          (json['newUsers'] as num?)?.toInt(),

      pageViews:
          (json['pageViews'] as num?)?.toInt(),

      sessions:
          (json['sessions'] as num?)?.toInt(),

      users:
          (json['users'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgSessionDuration': avgSessionDuration,
      'bounceRate': bounceRate,
      'date': date,
      'eventCount': eventCount,
      'newUsers': newUsers,
      'pageViews': pageViews,
      'sessions': sessions,
      'users': users,
    };
  }
}