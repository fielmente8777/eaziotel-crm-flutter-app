// ============================================================
// QUICK REPLY RESPONSE
// GET /api/v1/quick-reply?hid=
//
//   result.docs: [
//     { _id, title, shortcut,
//       items: [
//         { type: "text",  text: "Hello 👋 ..." },
//         { type: "image", media: [{ url, fileName, mimeType, size }] },
//         { type: "video", media: [...] },
//         { type: "document", media: [...] }
//       ] }
//   ]
// ============================================================

class QuickReplyListResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final List<QuickReply> replies;

  QuickReplyListResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.replies = const [],
  });

  factory QuickReplyListResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final docs = result is Map ? result['docs'] : null;

    return QuickReplyListResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage']?.toString(),
      replies: docs is List
          ? docs
                .whereType<Map>()
                .map((e) => QuickReply.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'responseStatusCode': responseStatusCode,
    'responseMessage': responseMessage,
    'result': {'docs': replies.map((r) => r.toJson()).toList()},
  };
}

class QuickReply {
  final String id;
  final String title;
  final String shortcut;
  final List<QuickReplyItem> items;

  const QuickReply({
    required this.id,
    required this.title,
    this.shortcut = '',
    this.items = const [],
  });

  /// Message text ('' = attachment only)
  String get text => items
      .firstWhere((i) => i.type == 'text', orElse: QuickReplyItem.empty)
      .text;

  List<QuickReplyMedia> mediaOf(String type) => [
    for (final item in items.where((i) => i.type == type)) ...item.media,
  ];

  List<QuickReplyMedia> get images => mediaOf('image');
  List<QuickReplyMedia> get videos => mediaOf('video');
  List<QuickReplyMedia> get documents => mediaOf('document');

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    return q.isEmpty ||
        title.toLowerCase().contains(q) ||
        text.toLowerCase().contains(q) ||
        shortcut.toLowerCase().contains(q);
  }

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    final items = json['items'];

    return QuickReply(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      shortcut: (json['shortcut'] ?? '').toString(),
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (e) => QuickReplyItem.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'shortcut': shortcut,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

class QuickReplyItem {
  /// text / image / video / document
  final String type;
  final String text;
  final List<QuickReplyMedia> media;

  const QuickReplyItem({
    required this.type,
    this.text = '',
    this.media = const [],
  });

  static QuickReplyItem empty() => const QuickReplyItem(type: '');

  factory QuickReplyItem.fromJson(Map<String, dynamic> json) {
    final media = json['media'];

    return QuickReplyItem(
      type: (json['type'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      media: media is List
          ? media
                .whereType<Map>()
                .map(
                  (e) => QuickReplyMedia.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (text.isNotEmpty) 'text': text,
    if (media.isNotEmpty) 'media': media.map((m) => m.toJson()).toList(),
  };
}

class QuickReplyMedia {
  final String url;
  final String fileName;
  final String mimeType;
  final int size;

  const QuickReplyMedia({
    required this.url,
    required this.fileName,
    this.mimeType = '',
    this.size = 0,
  });

  factory QuickReplyMedia.fromJson(Map<String, dynamic> json) {
    return QuickReplyMedia(
      url: (json['url'] ?? '').toString(),
      fileName: (json['fileName'] ?? json['name'] ?? 'file').toString(),
      mimeType: (json['mimeType'] ?? '').toString(),
      size: num.tryParse('${json['size'] ?? 0}')?.toInt() ?? 0,
    );
  }

  /// On Edit it goes back in the "media" field (to keep the old file)
  Map<String, dynamic> toJson() => {
    'url': url,
    'fileName': fileName,
    'mimeType': mimeType,
    'size': size,
  };
}
