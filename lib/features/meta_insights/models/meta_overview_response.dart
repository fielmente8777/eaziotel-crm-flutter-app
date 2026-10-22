// ============================================================
// META OVERVIEW RESPONSE
// GET /api/v1/meta/page/overview?hid=&period=   (period: day / week /
//                                                28_days / 90_days)
//
//   result.doc.cards               : followers, newFollowers, reach,
//                                    impressions, videoViews
//                                    -> { value, trend: up/down, growth: % }
//   result.doc.performanceOverview : reach[], engagements[] -> { date, value }
//   result.doc.topPosts            : best post (photo, caption, likes ...)
// ============================================================

double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> _maps(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

class MetaOverviewResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final MetaOverview result;

  MetaOverviewResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.result = const MetaOverview(),
  });

  factory MetaOverviewResponse.fromJson(Map<String, dynamic> json) {
    return MetaOverviewResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage']?.toString(),
      result: MetaOverview.fromJson(_map(_map(json['result'])['doc'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'responseStatusCode': responseStatusCode,
    'responseMessage': responseMessage,
    'result': {'doc': result.toJson()},
  };
}

class MetaOverview {
  /// Cards in this order (same as web)
  final List<MetaCard> cards;
  final List<MetaDayPoint> reach;
  final List<MetaDayPoint> engagements;
  final List<MetaPost> topPosts;

  const MetaOverview({
    this.cards = const [],
    this.reach = const [],
    this.engagements = const [],
    this.topPosts = const [],
  });

  factory MetaOverview.fromJson(Map<String, dynamic> json) {
    final cards = _map(json['cards']);
    final performance = _map(json['performanceOverview']);

    return MetaOverview(
      cards: [
        for (final e in cards.entries) MetaCard.fromJson(e.key, _map(e.value)),
      ],
      reach: _maps(performance['reach']).map(MetaDayPoint.fromJson).toList(),
      engagements: _maps(
        performance['engagements'],
      ).map(MetaDayPoint.fromJson).toList(),
      topPosts: _maps(json['topPosts']).map(MetaPost.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'cards': {for (final c in cards) c.key: c.toJson()},
    'performanceOverview': {
      'reach': reach.map((p) => p.toJson()).toList(),
      'engagements': engagements.map((p) => p.toJson()).toList(),
    },
    'topPosts': topPosts.map((p) => p.toJson()).toList(),
  };
}

class MetaCard {
  /// followers / newFollowers / reach / impressions / videoViews
  final String key;
  final double value;

  /// up / down (or nothing)
  final String trend;

  /// % change (null = the server did not send it)
  final double? growth;

  const MetaCard({
    required this.key,
    required this.value,
    this.trend = '',
    this.growth,
  });

  static const labels = {
    'followers': 'Followers',
    'newFollowers': 'New Followers',
    'reach': 'Reach',
    'impressions': 'Impressions',
    'videoViews': 'Video Views',
  };

  String get label => labels[key] ?? key;

  factory MetaCard.fromJson(String key, Map<String, dynamic> json) {
    return MetaCard(
      key: key,
      value: _num(json['value']),
      trend: (json['trend'] ?? '').toString(),
      growth: json['growth'] == null ? null : _num(json['growth']),
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'trend': trend,
    'growth': growth,
  };
}

class MetaDayPoint {
  final String date;
  final double value;

  const MetaDayPoint({required this.date, required this.value});

  DateTime? get day => DateTime.tryParse(date);

  factory MetaDayPoint.fromJson(Map<String, dynamic> json) => MetaDayPoint(
    date: (json['date'] ?? '').toString(),
    value: _num(json['value']),
  );

  Map<String, dynamic> toJson() => {'date': date, 'value': value};
}

class MetaPost {
  final String id;
  final String message;
  final String picture;
  final String createdTime;
  final double reactions;
  final double comments;
  final double reach;
  final double engagement;

  /// Link to the post on Facebook ('' if none)
  final String permalink;

  const MetaPost({
    required this.id,
    this.message = '',
    this.picture = '',
    this.createdTime = '',
    this.reactions = 0,
    this.comments = 0,
    this.reach = 0,
    this.engagement = 0,
    this.permalink = '',
  });

  DateTime? get created => DateTime.tryParse(createdTime)?.toLocal();

  factory MetaPost.fromJson(Map<String, dynamic> json) {
    return MetaPost(
      id: (json['id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      picture: (json['full_picture'] ?? '').toString(),
      createdTime: (json['created_time'] ?? '').toString(),
      reactions: _num(_map(_map(json['likes'])['summary'])['total_count']),
      comments: _num(_map(_map(json['comments'])['summary'])['total_count']),
      reach: _num(json['reach']),
      engagement: _num(json['engagement']),
      permalink: (json['permalink_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'full_picture': picture,
    'created_time': createdTime,
    'likes': {
      'summary': {'total_count': reactions},
    },
    'comments': {
      'summary': {'total_count': comments},
    },
    'reach': reach,
    'engagement': engagement,
    'permalink_url': permalink,
  };
}
