// lib/features/googleAnalytis/models/top_pages_model.dart

double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;
int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

class TopPagesModel {
  final List<TopPage> pages;

  const TopPagesModel({required this.pages});

  factory TopPagesModel.fromJson(Map<String, dynamic> json) {
    final list = (json['topPages'] as List?) ?? const [];
    return TopPagesModel(
      pages: list
          .whereType<Map<String, dynamic>>()
          .map(TopPage.fromJson)
          .toList(),
    );
  }
}

class TopPage {
  final String pageName;
  final String pagePath;
  final String fullUrl;
  final int views;
  final int users;

  /// Seconds
  final double avgDuration;

  /// 0.0 – 1.0 (the API sends a fraction)
  final double bounceRate;

  const TopPage({
    required this.pageName,
    required this.pagePath,
    required this.fullUrl,
    required this.views,
    required this.users,
    required this.avgDuration,
    required this.bounceRate,
  });

  factory TopPage.fromJson(Map<String, dynamic> json) => TopPage(
        pageName: (json['pageName'] ?? '').toString(),
        pagePath: (json['pagePath'] ?? '').toString(),
        fullUrl: (json['fullUrl'] ?? '').toString(),
        views: _i(json['views']),
        users: _i(json['users']),
        avgDuration: _d(json['avgDuration']),
        bounceRate: _d(json['bounceRate']),
      );

  /// "app.eazotel.com/career" – with https:// removed
  String get displayUrl =>
      fullUrl.replaceFirst(RegExp(r'^https?://'), '');

  /// "1m 9s", "0m 18s" – like the screenshot
  String get avgTimeLabel {
    final t = avgDuration.round();
    return '${t ~/ 60}m ${t % 60}s';
  }

  double get bouncePercent => bounceRate * 100;
}