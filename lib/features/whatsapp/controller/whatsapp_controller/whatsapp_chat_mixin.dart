part of '../whatsappController.dart';

// ============================================================
// WHATSAPP CHAT MIXIN
//
// Khuli hui chat: messages load, bheja hua message jodna,
// temp id -> asli id, select + delete.
// ============================================================

mixin WhatsappChatMixin
    on WhatsappStateMixin, WhatsappHelpersMixin, WhatsappConversationListMixin {
  // ============================================================
  // OPEN / LOAD
  // ============================================================

  void setCurrentConversation(String conversationId) =>
      currentConversationId.value = conversationId;

  @override
  void clearCurrentConversation() => currentConversationId.value = '';

  Future<void> getConversationMessages({required String conversationId}) async {
    try {
      isMessagesLoading.value = true;
      messagesErrorMessage.value = '';

      setCurrentConversation(conversationId);

      messagesResponse.value = await WhatsappService.getConversationMessages(
        conversationId: conversationId,
      );
    } catch (e) {
      messagesErrorMessage.value = e.toString();
    } finally {
      isMessagesLoading.value = false;
    }
  }

  List<WhatsappSocketMessageModel> get currentSocketMessages {
    final id = currentConversationId.value;
    if (id.isEmpty) return [];

    return socketMessages.where((m) => m.conversationId == id).toList();
  }

  // ============================================================
  // ADD SENT MESSAGE (text / image / template / flow)
  //
  // conversationId do to wahi chat badalti hai, warna khuli hui chat.
  // ============================================================

  void addSentMessageToCurrentConversation({
    required String phone,
    required String text,
    String? messageId,
    String messageType = 'text', // 'text' ya 'image'
    String? caption, // image ke saath bheja gaya text
    Map<String, dynamic>? media, // {'id': ..., 'mimeType': ...}
    String? conversationId,
  }) {
    final convId = (conversationId != null && conversationId.isNotEmpty)
        ? conversationId
        : currentConversationId.value;

    if (convId.isEmpty) return;

    final now = DateTime.now().toIso8601String();
    final caption0 = (caption ?? '').trim();

    // 1. Khuli chat me message jodo (pehle se ho to nahi)
    if (messagesResponse.value != null &&
        convId == currentConversationId.value) {
      final old = _openMessages;

      final alreadyExists =
          messageId != null &&
          messageId.isNotEmpty &&
          old.any((m) => m.messageId == messageId || m.id == messageId);

      if (!alreadyExists) {
        _setOpenMessages([
          ...old,
          WhatsappMessageModel(
            id: messageId,
            conversationId: convId,
            messageId: messageId,
            sender: 'business',
            from: phone,
            to: phone,
            direction: 'outbound',
            messageType: messageType,
            body: messageType == 'text'
                ? text
                : (caption0.isEmpty ? null : caption0),
            status: 'sent',
            createdAt: now,
            updatedAt: now,
            media: media == null ? null : WhatsappMediaModel.fromJson(media),
            interactive: null,
            location: null,
          ),
        ]);
      }
    }

    // 2. List me chat upar le jao, last message badlo (apne message par unread nahi badhta)
    final index = _conversationIndex(convId);

    if (index != -1) {
      _updateConversation(index, {
        'last_message': {
          'sender': 'business',
          'text': text,
          'type': messageType,
          'created_at': now,
          'updated_at': now,
        },
        'updatedAt': now,
        'unread_count': conversations[index].unreadCount,
      }, toTop: true);
    }
  }

  // ============================================================
  // TEMP ID -> ASLI ID
  //
  // Local message ka id "temp_xxxxx" hota hai. API se asli messageId
  // milne par badalte hain, taaki status (tick) sahi message par lage.
  // ============================================================

  void updateMessageId({required String tempId, required String realId}) {
    if (tempId.isEmpty || realId.isEmpty || tempId == realId) return;

    // 1. Khuli chat
    if (messagesResponse.value != null) {
      final messages = [..._openMessages];
      final index = messages.indexWhere(
        (m) => m.messageId == tempId || m.id == tempId,
      );

      if (index != -1) {
        messages[index] = _copyMessage(
          messages[index],
          id: realId,
          messageId: realId,
        );
        _setOpenMessages(messages);
      }
    }

    // 2. Conversation list ka last_message
    final convIndex = _conversationIndexByLastMessageId(tempId);

    if (convIndex != -1) {
      _updateConversation(convIndex, {
        'last_message': {
          ...?conversations[convIndex].lastMessage?.toJson(),
          'message_id': realId,
        },
      });
    }

    update();
  }

  // ============================================================
  // SELECT + DELETE
  // ============================================================

  final RxSet<String> selectedMessageIds = <String>{}.obs;
  final RxBool isDeleting = false.obs;

  bool get isSelectionMode => selectedMessageIds.isNotEmpty;

  void toggleMessageSelection(String id) {
    if (id.isEmpty) return;
    if (!selectedMessageIds.remove(id)) selectedMessageIds.add(id);
  }

  void clearSelection() => selectedMessageIds.clear();

  /// Success par true
  Future<bool> deleteSelectedMessages() =>
      deleteMessages(selectedMessageIds.toList());

  Future<bool> deleteMessages(List<String> allIds) async {
    if (allIds.isEmpty || isDeleting.value) return false;

    // "temp_" wale server par nahi hote, sirf local se hatao
    final apiIds = allIds.where((id) => !id.startsWith('temp_')).toList();

    try {
      isDeleting.value = true;

      if (apiIds.isNotEmpty) await WhatsappDeleteChat.deleteChats(ids: apiIds);

      _removeMessagesLocally(allIds.toSet());
      selectedMessageIds.removeAll(allIds);

      return true;
    } catch (e) {
      debugPrint('DELETE MESSAGES ERROR: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  void _removeMessagesLocally(Set<String> ids) {
    bool removed(String? messageId, String? id) =>
        ids.contains(messageId) || ids.contains(id);

    _setOpenMessages(
      _openMessages.where((m) => !removed(m.messageId, m.id)).toList(),
    );

    socketMessages.removeWhere((m) => removed(m.messageId, m.id));

    latestSocketMessagesByConversation.removeWhere(
      (_, m) => removed(m.messageId, m.id),
    );
    latestSocketMessagesByConversation.refresh();

    final latest = latestSocketMessage.value;
    if (removed(latest?.messageId, latest?.id)) {
      latestSocketMessage.value = null;
    }

    update();
  }
}
