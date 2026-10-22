part of '../whatsappController.dart';

// ============================================================
// WHATSAPP HELPERS MIXIN
//
// Small helpers shared by the other mixins:
//   - clean text / map, count unread, build the last message
//   - read / change the open chat's messages
//   - copy a message / socket message / conversation
//   - lead NDID cache
// ============================================================

mixin WhatsappHelpersMixin on WhatsappStateMixin {
  // ============================================================
  // TEXT / MAP
  // ============================================================

  bool _isIncomingSocket(WhatsappSocketMessageModel message) =>
      message.direction?.toLowerCase() == 'inbound' ||
      message.sender?.toLowerCase() == 'contact';

  String _socketSender(Map<String, dynamic> raw) {
    final sender = raw['sender']?.toString();
    return (sender == null || sender.isEmpty) ? 'contact' : sender;
  }

  /// null / empty / "null" -> null
  String? _cleanString(dynamic value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty || text == 'null') ? null : text;
  }

  Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String? _getSocketNdid(Map<String, dynamic> data) =>
      _cleanString(data['ndid']);

  /// The server's unread_count -> otherwise 0 if the chat is open -> +1 on incoming
  int _resolveUnreadCount({
    required int oldCount,
    required Map<String, dynamic> raw,
    required bool isOpen,
    required bool isIncoming,
  }) {
    final fromServer = raw['unread_count'];

    if (fromServer != null) {
      final parsed = fromServer is int
          ? fromServer
          : int.tryParse(fromServer.toString());
      if (parsed != null) return parsed;
    }

    if (isOpen) return 0;
    return isIncoming ? oldCount + 1 : oldCount;
  }

  Map<String, dynamic> _buildLastMessage(
    Map<String, dynamic> raw,
    WhatsappSocketMessageModel m,
  ) {
    final now = DateTime.now().toIso8601String();

    return {
      'sender': _socketSender(raw),
      'text': _lastMessageText(m),
      'type': m.messageType ?? 'text',
      'created_at': m.createdAt ?? now,
      'updated_at': m.updatedAt ?? m.createdAt ?? now,
    };
  }

  static const Map<String, String> _mediaLabels = {
    'image': '📷 Photo',
    'video': '🎥 Video',
    'audio': '🎵 Audio',
    'voice': '🎵 Audio',
    'document': '📄 Document',
    'sticker': 'Sticker',
    'location': '📍 Location',
    'contacts': '👤 Contact',
    'interactive': 'Interactive message',
  };

  /// The body if there is one, otherwise the type's label (like "📷 Photo")
  String _lastMessageText(WhatsappSocketMessageModel m) {
    final body = m.body?.trim() ?? '';
    if (body.isNotEmpty) return body;

    return _mediaLabels[(m.messageType ?? '').toLowerCase()] ?? '';
  }

  // ============================================================
  // MESSAGES OF THE OPEN CHAT (messagesResponse)
  // ============================================================

  List<WhatsappMessageModel> get _openMessages =>
      messagesResponse.value?.result?.messages ??
      const <WhatsappMessageModel>[];

  /// Keep everything else in messagesResponse the same, change only the messages
  void _setOpenMessages(List<WhatsappMessageModel> messages) {
    final response = messagesResponse.value;
    if (response == null) return;

    messagesResponse.value = WhatsappMessagesResponseModel(
      success: response.success,
      responseStatusCode: response.responseStatusCode,
      responseMessage: response.responseMessage,
      request: response.request,
      result: WhatsappMessagesResultModel(messages: messages),
    );
  }

  // ============================================================
  // COPIES
  // ============================================================

  WhatsappMessageModel _copyMessage(
    WhatsappMessageModel m, {
    String? id,
    String? messageId,
    String? status,
    String? updatedAt,
  }) {
    return WhatsappMessageModel(
      id: id ?? m.id,
      conversationId: m.conversationId,
      messageId: messageId ?? m.messageId,
      sender: m.sender,
      from: m.from,
      to: m.to,
      direction: m.direction,
      messageType: m.messageType,
      body: m.body,
      status: status ?? m.status,
      createdAt: m.createdAt,
      updatedAt: updatedAt ?? m.updatedAt,
      media: m.media,
      interactive: m.interactive,
      location: m.location,
      contacts: m.contacts,
    );
  }

  WhatsappSocketMessageModel _copySocketMessage(
    WhatsappSocketMessageModel m, {
    String? status,
    String? updatedAt,
    int? unreadCount,
  }) {
    return WhatsappSocketMessageModel(
      hid: m.hid,
      conversationId: m.conversationId,
      messageId: m.messageId,
      sender: m.sender,
      from: m.from,
      to: m.to,
      direction: m.direction,
      messageType: m.messageType,
      body: m.body,
      media: m.media,
      template: m.template,
      interactive: m.interactive,
      location: m.location,
      contacts: m.contacts,
      status: status ?? m.status,
      adSourceId: m.adSourceId,
      id: m.id,
      createdAt: m.createdAt,
      updatedAt: updatedAt ?? m.updatedAt,
      ndid: m.ndid,
      name: m.name,
      unreadCount: unreadCount ?? m.unreadCount,
      context: m.context,
    );
  }

  // ============================================================
  // CONVERSATION LIST
  // ============================================================

  int _conversationIndex(String id) =>
      conversations.indexWhere((c) => c.id == id);

  /// The conversation whose last_message has this message_id
  int _conversationIndexByLastMessageId(String messageId) =>
      conversations.indexWhere(
        (c) => c.lastMessage?.toJson()['message_id']?.toString() == messageId,
      );

  /// Change some fields of a conversation. [toTop] = move it to the top of the list.
  void _updateConversation(
    int index,
    Map<String, dynamic> changes, {
    bool toTop = false,
  }) {
    final updated = WhatsappConversationModel.fromJson({
      ...conversations[index].toJson(),
      ...changes,
    });

    if (toTop) {
      conversations.removeAt(index);
      conversations.insert(0, updated);
    } else {
      conversations[index] = updated;
    }

    conversations.refresh();
  }

  // ============================================================
  // LEAD NDIDS
  // ============================================================

  void setLeadResponse(LeadResponseModel response) {
    leadResponse.value = response;
    _rebuildLeadNdids();
  }

  void _rebuildLeadNdids() {
    final ndids = <String>{};
    final dynamic response = leadResponse.value;

    if (response != null) {
      try {
        dynamic json;
        try {
          json = response.toJson();
        } catch (_) {
          json = response;
        }
        _collectNdids(json, ndids);
      } catch (e) {
        debugPrint('LEAD NDID EXTRACTION ERROR: $e');
      }
    }

    _leadNdids = ndids;
  }

  /// Looks for the "ndid" key everywhere inside the JSON
  void _collectNdids(dynamic value, Set<String> result) {
    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key?.toString().toLowerCase() == 'ndid') {
          final text = _cleanString(entry.value);
          if (text != null) result.add(text);
        }
        _collectNdids(entry.value, result);
      }
    } else if (value is Iterable) {
      for (final item in value) {
        _collectNdids(item, result);
      }
    }
  }

  /// Whether the socket's NDID is allowed.
  ///   leadResponse is set -> match only the lead NDIDs
  ///   otherwise           -> match the NDIDs of the loaded conversations
  bool _isLeadNdid(String ndid) {
    final value = ndid.trim();

    if (leadResponse.value != null) {
      if (_leadNdids.isEmpty) _rebuildLeadNdids();
      if (_leadNdids.isNotEmpty) return _leadNdids.contains(value);
    }

    return conversations.any((c) => c.ndid.trim() == value);
  }
}
