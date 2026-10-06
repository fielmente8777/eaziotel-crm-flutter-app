int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

class TrafficChannel {
  final String channel;
  final int sessions;
  final int users;

  const TrafficChannel({
    required this.channel,
    required this.sessions,
    required this.users,
  });

  factory TrafficChannel.fromJson(Map<String, dynamic> json) => TrafficChannel(
        channel: (json['channel'] ?? '').toString(),
        sessions: _int(json['sessions']),
        users: _int(json['users']),
      );
}

class TrafficSource {
  final String source;
  final String medium;
  final int sessions;
  final int users;

  const TrafficSource({
    required this.source,
    required this.medium,
    required this.sessions,
    required this.users,
  });

  factory TrafficSource.fromJson(Map<String, dynamic> json) => TrafficSource(
        source: (json['source'] ?? '').toString(),
        medium: (json['medium'] ?? '').toString(),
        sessions: _int(json['sessions']),
        users: _int(json['users']),
      );
}

class TrafficSourcesModel {
  final List<TrafficChannel> channels;
  final List<TrafficSource> sources;

  const TrafficSourcesModel({required this.channels, required this.sources});

  factory TrafficSourcesModel.fromJson(Map<String, dynamic> json) =>
      TrafficSourcesModel(
        channels: (json['channels'] as List? ?? [])
            .map((e) => TrafficChannel.fromJson(e as Map<String, dynamic>))
            .toList(),
        sources: (json['sources'] as List? ?? [])
            .map((e) => TrafficSource.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  int get totalSessions => channels.fold(0, (s, c) => s + c.sessions);
  bool get isEmpty => channels.isEmpty && sources.isEmpty;
}