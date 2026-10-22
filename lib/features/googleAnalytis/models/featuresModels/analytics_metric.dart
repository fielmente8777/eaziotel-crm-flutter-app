import 'package:flutter/material.dart';

enum AnalyticsMetric {
  activeUsers,
  newUsers,
  sessions,
  pageViews,
  events,
  avgDuration,
}

double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;

extension AnalyticsMetricX on AnalyticsMetric {
  String get label {
    switch (this) {
      case AnalyticsMetric.activeUsers:
        return 'ACTIVE USERS';
      case AnalyticsMetric.newUsers:
        return 'NEW USERS';
      case AnalyticsMetric.sessions:
        return 'SESSIONS';
      case AnalyticsMetric.pageViews:
        return 'PAGE VIEWS';
      case AnalyticsMetric.events:
        return 'EVENTS';
      case AnalyticsMetric.avgDuration:
        return 'AVG DURATION';
    }
  }

  IconData get icon {
    switch (this) {
      case AnalyticsMetric.activeUsers:
        return Icons.people_outline;
      case AnalyticsMetric.newUsers:
        return Icons.trending_up;
      case AnalyticsMetric.sessions:
        return Icons.show_chart;
      case AnalyticsMetric.pageViews:
        return Icons.remove_red_eye_outlined;
      case AnalyticsMetric.events:
        return Icons.show_chart;
      case AnalyticsMetric.avgDuration:
        return Icons.access_time;
    }
  }

  bool get isDuration => this == AnalyticsMetric.avgDuration;

  /// This metric's value from one chart point (one day)
  double valueOf(dynamic p) {
    switch (this) {
      case AnalyticsMetric.activeUsers:
        return _n(p.users);
      case AnalyticsMetric.newUsers:
        return _n(p.newUsers);
      case AnalyticsMetric.sessions:
        return _n(p.sessions);
      case AnalyticsMetric.pageViews:
        return _n(p.pageViews);
      case AnalyticsMetric.events:
        return _n(p.eventCount);
      case AnalyticsMetric.avgDuration:
        return _n(p.avgSessionDuration);
    }
  }

  /// Total shown on the tab
  double total(List points) {
    if (points.isEmpty) return 0;
    if (isDuration) {
      // weighted average by sessions
      double weighted = 0, sessions = 0;
      for (final p in points) {
        weighted += _n(p.avgSessionDuration) * _n(p.sessions);
        sessions += _n(p.sessions);
      }
      return sessions == 0 ? 0 : weighted / sessions;
    }
    return points.fold<double>(0, (s, p) => s + valueOf(p));
  }

  String format(double v) {
    if (isDuration) {
      final total = v.round();
      final m = total ~/ 60;
      final s = total % 60;
      return m > 0 ? '${m}m ${s}s' : '${s}s';
    }
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.round().toString();
  }
}