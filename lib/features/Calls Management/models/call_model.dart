// GET /api/v1/call/getall?hid=..&page=..&limit=..

class CallsResponse {
  final List<CallModel> calls;
  final CallsPagination pagination;

  const CallsResponse({required this.calls, required this.pagination});

  factory CallsResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final docs = result is Map ? result['docs'] : null;
    final list = docs is Map ? docs['calls'] : null;
    final paging = result is Map ? result['pagination'] : null;

    return CallsResponse(
      calls: list is List
          ? list
                .whereType<Map>()
                .map((e) => CallModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      pagination: CallsPagination.fromJson(
        paging is Map ? Map<String, dynamic>.from(paging) : const {},
      ),
    );
  }
}

class CallsPagination {
  final int total;
  final int page;
  final int totalPages;
  final bool hasNextPage;

  const CallsPagination({
    this.total = 0,
    this.page = 1,
    this.totalPages = 1,
    this.hasNextPage = false,
  });

  factory CallsPagination.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, int fallback) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? fallback;

    return CallsPagination(
      total: toInt(json['total'], 0),
      page: toInt(json['page'], 1),
      totalPages: toInt(json['totalPages'], 1),
      hasNextPage: json['hasNextPage'] == true,
    );
  }
}

/// Call par jo fields dropdown se badle ja sakte hain (web table jaise).
enum CallField {
  segregation('Segregation', 'segregation', [
    'Payment',
    'Post Booking',
    'Pre Booking',
    'In Stay',
    'Post Stay',
    'Partnership',
    'Non Relevant',
  ]),
  guestType('Guest Type', 'guestType', [
    'Solo',
    'Couple',
    'Family',
    'Group',
    'Corporate',
  ]),
  priority('Priority', 'priority', ['Low', 'Medium', 'High']),
  stage('Stage', 'stage', ['Open', 'Follow Up', 'Closure']);

  const CallField(this.label, this.apiKey, this.options);

  final String label;

  /// Update API ke body me jane wala key
  final String apiKey;

  final List<String> options;

  /// Body me jane wali value. Segregation object me jata hai:
  /// {"label": "Partnership", "value": "Partnership"}, baaki seedha string.
  Object apiValue(String value) {
    return this == CallField.segregation
        ? {'label': value, 'value': value}
        : value;
  }

  /// Dropdown me dikhne wala text (segregation web jaise capital me)
  String display(String value) {
    return this == CallField.segregation ? value.toUpperCase() : value;
  }

  /// API ki value ko option list wali spelling me lao ("Follow up" -> "Follow Up")
  String? normalize(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    for (final option in options) {
      if (option.toLowerCase() == value.trim().toLowerCase()) return option;
    }

    return value.trim();
  }
}

class CallModel {
  final String id;
  final String sid;
  final String from;
  final String to;

  /// Hotel ka virtual number jisse call hui
  final String phoneNumber;

  /// inbound / outbound-dial / outbound-api
  final String direction;

  /// completed / no-answer / busy / failed
  final String status;

  final DateTime? startTime;
  final int durationSeconds;
  final String? recordingUrl;
  final String? callerName;

  final String? stage;
  final String? guestType;
  final String? priority;
  final String? segregation;

  final DateTime? followUpDate;

  const CallModel({
    required this.id,
    required this.sid,
    required this.from,
    required this.to,
    required this.phoneNumber,
    required this.direction,
    required this.status,
    required this.startTime,
    required this.durationSeconds,
    this.recordingUrl,
    this.callerName,
    this.stage,
    this.guestType,
    this.priority,
    this.segregation,
    this.followUpDate,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString().trim() ?? '';

    String? optional(String key) {
      final value = str(key);
      return value.isEmpty ? null : value;
    }

    // Segregation {"label": .., "value": ..} ya seedha string aa sakta hai
    String? segregation() {
      final raw = json['segregation'];

      if (raw is! Map) return optional('segregation');

      final value = (raw['value'] ?? raw['label'])?.toString().trim() ?? '';

      return value.isEmpty ? null : value;
    }

    final duration = json['duration'];

    return CallModel(
      id: str('_id'),
      sid: str('sid'),
      from: str('from'),
      to: str('to'),
      phoneNumber: str('phoneNumberSid'),
      direction: str('direction'),
      status: str('status'),
      startTime: _parseTime(json['startTime'] ?? json['dateCreated']),
      durationSeconds: duration is num
          ? duration.toInt()
          : int.tryParse(duration?.toString() ?? '') ?? 0,
      recordingUrl: optional('recordingUrl'),
      callerName: optional('callerName'),
      stage: optional('stage'),
      guestType: optional('guestType'),
      priority: optional('priority'),
      segregation: segregation(),
      followUpDate: _parseTime(json['followUpDate']),
    );
  }

  // ============================================================
  // EDITABLE FIELDS
  // ============================================================

  String? valueOf(CallField field) {
    switch (field) {
      case CallField.segregation:
        return field.normalize(segregation);
      case CallField.guestType:
        return field.normalize(guestType);
      case CallField.priority:
        return field.normalize(priority);
      case CallField.stage:
        return field.normalize(stage) ?? 'Open';
    }
  }

  /// Ek field badal kar nayi copy
  CallModel withField(
    CallField field,
    String? value, {
    DateTime? followUpDate,
  }) {
    return CallModel(
      id: id,
      sid: sid,
      from: from,
      to: to,
      phoneNumber: phoneNumber,
      direction: direction,
      status: status,
      startTime: startTime,
      durationSeconds: durationSeconds,
      recordingUrl: recordingUrl,
      callerName: callerName,
      stage: field == CallField.stage ? value : stage,
      guestType: field == CallField.guestType ? value : guestType,
      priority: field == CallField.priority ? value : priority,
      segregation: field == CallField.segregation ? value : segregation,
      followUpDate: followUpDate ?? this.followUpDate,
    );
  }

  /// API do format bhejti hai:
  ///   "2026-05-02T13:43:14.000Z"  -> UTC
  ///   "2026-10-07 15:00:35"       -> local time (timezone nahi)
  static DateTime? _parseTime(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;

    return DateTime.tryParse(text)?.toLocal();
  }

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  bool get isIncoming => direction.toLowerCase().startsWith('inbound');

  String get directionLabel => isIncoming ? 'Incoming' : 'Outgoing';

  /// Guest ka number: incoming me "from", outgoing me "to"
  String get customerNumber => isIncoming ? from : to;

  bool get isSuccessful => status.toLowerCase() == 'completed';

  bool get isFailed => status.toLowerCase() == 'failed';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Call was successful';
      case 'no-answer':
        return 'Client Unanswered';
      case 'busy':
        return 'Client Busy';
      case 'failed':
        return 'Failed';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  /// "0m 35s" (0 second ho to "-")
  String get durationLabel {
    if (durationSeconds <= 0) return '-';

    return '${durationSeconds ~/ 60}m ${durationSeconds % 60}s';
  }

  bool get hasRecording => recordingUrl != null && recordingUrl!.isNotEmpty;

  /// "20 minutes ago", "1 hour ago", "5 months ago"
  String get timeAgo {
    final time = startTime;
    if (time == null) return '-';

    final diff = DateTime.now().difference(time);

    String unit(int value, String name) =>
        '$value $name${value == 1 ? '' : 's'} ago';

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return unit(diff.inMinutes, 'minute');
    if (diff.inHours < 24) return unit(diff.inHours, 'hour');
    if (diff.inDays < 30) return unit(diff.inDays, 'day');
    if (diff.inDays < 365) return unit(diff.inDays ~/ 30, 'month');

    return unit(diff.inDays ~/ 365, 'year');
  }
}
