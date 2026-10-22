part of '../whatsappController.dart';

// ============================================================
// WHATSAPP SOCKET MIXIN
//
// Live events from the socket:
//   WHATSAPP_NEW_MESSAGE      -> handleNewMessage
//   WHATSAPP_NEW_CONVERSATION -> handleNewConversation
//   WHATSAPP_MESSAGE_STATUS   -> handleMessageStatus
// ============================================================

mixin WhatsappSocketMixin
    on
        WhatsappStateMixin,
        WhatsappHelpersMixin,
        WhatsappConversationListMixin,
        WhatsappChatMixin {
  void handleSocketMessage(Map<String, dynamic> serverResponse) {
    try {
      final data = serverResponse['data'];
      if (data is! Map) return;

      final dataMap = Map<String, dynamic>.from(data);

      switch (serverResponse['event']) {
        case 'WHATSAPP_NEW_MESSAGE':
          handleNewMessage(dataMap);
        case 'WHATSAPP_NEW_CONVERSATION':
          handleNewConversation(dataMap);
        case 'WHATSAPP_MESSAGE_STATUS':
          handleMessageStatus(dataMap);
      }
    } catch (e) {
      debugPrint('SOCKET EVENT HANDLER ERROR: $e');
    }
  }

  // ============================================================
  // NEW MESSAGE
  //   1. NDID not in the lead list -> skip
  //   2. save the socket message (not twice)
  //   3. update the chat in the list / add a new one, both on top
  //   4. that same chat is open -> add it there too
  // ============================================================

  void handleNewMessage(Map<String, dynamic> raw) {
    try {
      final message = WhatsappSocketMessageModel.fromJson(raw);
      final conversationId = message.conversationId;

      if (conversationId == null || conversationId.isEmpty) return;

      // 1
      final ndid = _getSocketNdid(raw);
      if (ndid == null || !_isLeadNdid(ndid)) return;

      // 2
      final alreadyExists = socketMessages.any(
        (m) =>
            (message.messageId != null && m.messageId == message.messageId) ||
            (message.id != null && m.id == message.id),
      );

      if (!alreadyExists) socketMessages.add(message);

      latestSocketMessage.value = message;
      latestSocketMessagesByConversation[conversationId] = message;
      latestSocketMessagesByConversation.refresh();

      // 3
      _upsertConversationFromSocket(raw, message, ndid);

      // 3b. Notification (only for a customer's message, and only if the chat is not open)
      if (_isIncomingSocket(message) &&
          currentConversationId.value != conversationId) {
        final index = _conversationIndex(conversationId);
        if (index != -1) {
          onIncomingMessage?.call(conversations[index], message);
        }
      }

      // 4
      if (currentConversationId.value == conversationId) {
        _addSocketMessageToOpenChat(message);
      }

      update();
    } catch (e) {
      debugPrint('NEW MESSAGE ERROR: $e');
    }
  }

  void _upsertConversationFromSocket(
    Map<String, dynamic> raw,
    WhatsappSocketMessageModel message,
    String ndid,
  ) {
    final conversationId = message.conversationId ?? '';
    if (conversationId.isEmpty) return;

    final isOpen = currentConversationId.value == conversationId;
    final isIncoming = _isIncomingSocket(message);
    final lastMessage = _buildLastMessage(raw, message);

    int unread(int oldCount) => _resolveUnreadCount(
      oldCount: oldCount,
      raw: raw,
      isOpen: isOpen,
      isIncoming: isIncoming,
    );

    final index = _conversationIndex(conversationId);

    // Existing chat -> update + move to top
    if (index != -1) {
      final old = conversations[index];

      _updateConversation(index, {
        'name': _cleanString(raw['name']) ?? old.name,
        'unread_count': unread(old.unreadCount),
        'last_message': lastMessage,
        'updatedAt': lastMessage['updated_at'],
      }, toTop: true);
      return;
    }

    // New chat -> create it + put it on top.
    // Incoming: customer = from. Outgoing: customer = to.
    conversations.insert(
      0,
      WhatsappConversationModel.fromJson({
        '_id': conversationId,
        'hid': message.hid ?? hid,
        'ndid': ndid,
        'phone': (isIncoming ? message.from : message.to) ?? '',
        'phoneNumberId': (isIncoming ? message.to : message.from) ?? '',
        'name': _cleanString(raw['name']),
        'unread_count': unread(0),
        'status': 'ACTIVE',
        'markAsLead': false,
        'notes': [],
        'handling': {
          'mode': 'AI',
          'assignedTo': null,
          'assignedAt': null,
          'assignedBy': null,
        },
        'last_message': lastMessage,
        'createdAt': message.createdAt ?? DateTime.now().toIso8601String(),
        'updatedAt': lastMessage['updated_at'],
      }),
    );
    conversations.refresh();
  }

  void _addSocketMessageToOpenChat(WhatsappSocketMessageModel message) {
    if (isMessagesLoading.value || messagesResponse.value == null) return;

    final old = _openMessages;

    // If the open chat belongs to another conversation, do nothing
    final otherChat = old.any(
      (m) =>
          m.conversationId != null &&
          m.conversationId!.isNotEmpty &&
          m.conversationId != message.conversationId,
    );

    final exists = old.any(
      (m) =>
          (message.messageId != null && m.messageId == message.messageId) ||
          (message.id != null && m.id == message.id),
    );

    if (otherChat || exists) return;

    _setOpenMessages([...old, _socketToApiMessage(message)]);
  }

  WhatsappMessageModel _socketToApiMessage(WhatsappSocketMessageModel m) {
    final media = m.media;

    return WhatsappMessageModel(
      id: m.id,
      conversationId: m.conversationId,
      messageId: m.messageId,
      sender: m.sender,
      from: m.from,
      to: m.to,
      direction: m.direction,
      messageType: m.messageType,
      body: m.body,
      status: m.status,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      media: media is WhatsappMediaModel
          ? media
          : media is Map
          ? WhatsappMediaModel.fromJson(Map<String, dynamic>.from(media))
          : null,
      interactive: m.interactive,
      location: m.location,
      contacts: m.contacts,
    );
  }

  // ============================================================
  // NEW CONVERSATION
  //   NDID not in the lead list -> skip
  //   in the list -> update + move to top, otherwise new + top
  // ============================================================

  void handleNewConversation(Map<String, dynamic> data) {
    try {
      final ndid = _getSocketNdid(data);
      if (ndid == null || !_isLeadNdid(ndid)) return;

      final conversationId = data['_id']?.toString();
      if (conversationId == null || conversationId.isEmpty) return;

      final lastMessage = _asMap(data['last_message']);
      final now = DateTime.now().toIso8601String();
      final index = _conversationIndex(conversationId);

      if (index != -1) {
        final old = conversations[index];

        _updateConversation(index, {
          'ndid': ndid,
          'phone': _cleanString(data['phone']) ?? old.phone,
          'phoneNumberId':
              _cleanString(data['phoneNumberId']) ?? old.phoneNumberId,
          'name': _cleanString(data['name']) ?? old.name,
          'status': _cleanString(data['status']) ?? old.status,
          if (data['unread_count'] != null)
            'unread_count': data['unread_count'],
          if (lastMessage != null) 'last_message': lastMessage,
          'updatedAt': _cleanString(data['updatedAt']) ?? now,
        }, toTop: true);
        return;
      }

      conversations.insert(
        0,
        WhatsappConversationModel.fromJson({
          '_id': conversationId,
          'hid': _cleanString(data['hid']) ?? hid,
          'ndid': ndid,
          'phone': data['phone'],
          'phoneNumberId': data['phoneNumberId'],
          'name': data['name'],
          'last_message': lastMessage,
          'status': data['status'] ?? 'ACTIVE',
          'unread_count': data['unread_count'] ?? 1,
          'markAsLead': data['markAsLead'] ?? false,
          'notes': data['notes'] ?? [],
          'handling': _asMap(data['handling']),
          'createdAt': data['createdAt'] ?? now,
          'updatedAt': data['updatedAt'] ?? now,
        }),
      );
      conversations.refresh();
    } catch (e) {
      debugPrint('NEW CONVERSATION ERROR: $e');
    }
  }

  // ============================================================
  // MESSAGE STATUS (sent / delivered / read)
  // Changes three places: the open chat, socket messages, the list's last_message
  // ============================================================

  void handleMessageStatus(Map<String, dynamic> data) {
    try {
      final messageId = data['messageId']?.toString();
      final status = data['status']?.toString();

      if (messageId == null ||
          messageId.isEmpty ||
          status == null ||
          status.isEmpty) {
        return;
      }

      final now = DateTime.now().toIso8601String();

      bool matches(String? mId, String? id) =>
          mId == messageId || id == messageId;

      // 1. Khuli chat
      if (messagesResponse.value != null) {
        final messages = [..._openMessages];
        final index = messages.indexWhere((m) => matches(m.messageId, m.id));

        if (index != -1) {
          messages[index] = _copyMessage(
            messages[index],
            status: status,
            updatedAt: now,
          );
          _setOpenMessages(messages);
        }
      }

      // 2. Socket messages
      final socketIndex = socketMessages.indexWhere(
        (m) => matches(m.messageId, m.id),
      );

      if (socketIndex != -1) {
        final updated = _copySocketMessage(
          socketMessages[socketIndex],
          status: status,
          updatedAt: now,
        );

        socketMessages[socketIndex] = updated;

        final latest = latestSocketMessage.value;
        if (matches(latest?.messageId, latest?.id)) {
          latestSocketMessage.value = updated;
        }

        final convId = updated.conversationId;
        if (convId != null &&
            latestSocketMessagesByConversation[convId]?.messageId ==
                messageId) {
          latestSocketMessagesByConversation[convId] = updated;
          latestSocketMessagesByConversation.refresh();
        }
      }

      // 3. The list's last_message (only when its message_id is saved)
      final convIndex = _conversationIndexByLastMessageId(messageId);

      if (convIndex != -1) {
        _updateConversation(convIndex, {
          'last_message': {
            ...?conversations[convIndex].lastMessage?.toJson(),
            'status': status,
          },
        });
      }

      update();
    } catch (e) {
      debugPrint('MESSAGE STATUS ERROR: $e');
    }
  }
}
