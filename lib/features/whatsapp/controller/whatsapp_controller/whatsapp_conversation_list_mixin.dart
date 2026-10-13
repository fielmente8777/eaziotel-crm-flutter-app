part of '../whatsappController.dart';

// ============================================================
// WHATSAPP CONVERSATION LIST MIXIN
//
// Conversation list: integration, load, tab, search, ginti,
// select + delete, read mark.
// ============================================================

mixin WhatsappConversationListMixin
    on WhatsappStateMixin, WhatsappHelpersMixin {
  // ============================================================
  // INTEGRATION
  // ============================================================

  Future<void> getWhatsappIntegration() async {
    try {
      isIntegrationLoading.value = true;
      integrationErrorMessage.value = '';

      final dynamic decoded = await WhatsappApiService.getWhatsappIntegration(
        hid: hid,
      );

      if (decoded is Map) {
        whatsappIntegration.value = Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      integrationErrorMessage.value = e.toString();
      debugPrint('WHATSAPP INTEGRATION ERROR: $e');
    } finally {
      isIntegrationLoading.value = false;
    }
  }

  /// result.docs me kuch ho = WhatsApp juda hai
  bool get whatsappIntegrationSuccess {
    final result = whatsappIntegration.value?['result'];
    final docs = result is Map ? result['docs'] : null;

    return docs is Map && docs.isNotEmpty;
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> getConversations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await WhatsappService.getConversations(hid: hid);
      final result = response['result'];
      final list = result == null ? null : result['conversations'];

      if (list is! List) {
        conversations.clear();
        return;
      }

      conversations.assignAll(
        list.map(
          (item) => WhatsappConversationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        ),
      );

      _restoreSocketConversationOrder();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// List dobara aane par socket se aayi chats ko phir upar rakho
  void _restoreSocketConversationOrder() {
    final matched = <WhatsappConversationModel>[];

    for (final id in latestSocketMessagesByConversation.keys) {
      final index = _conversationIndex(id);
      if (index != -1) matched.add(conversations.removeAt(index));
    }

    if (matched.isNotEmpty) {
      conversations.insertAll(0, matched);
      conversations.refresh();
    }
  }

  // ============================================================
  // SELECT + DELETE
  // ============================================================

  final RxSet<String> selectedConversationIds = <String>{}.obs;
  final RxBool isConversationSelectMode = false.obs;
  final RxBool isDeletingConversations = false.obs;

  void startConversationSelection() => isConversationSelectMode.value = true;

  void toggleConversationSelection(String id) {
    if (id.isEmpty) return;

    if (!selectedConversationIds.remove(id)) selectedConversationIds.add(id);

    // Aakhri selection hataya to selection mode band
    isConversationSelectMode.value = selectedConversationIds.isNotEmpty;
  }

  void clearConversationSelection() {
    selectedConversationIds.clear();
    isConversationSelectMode.value = false;
  }

  /// Current tab me jo chats dikh rahi hain, sab select karo
  void selectAllConversations() {
    isConversationSelectMode.value = true;
    selectedConversationIds.assignAll(filteredChats.map((c) => c.id));
  }

  Future<bool> deleteSelectedConversations() async {
    if (selectedConversationIds.isEmpty || isDeletingConversations.value) {
      return false;
    }

    final ids = selectedConversationIds.toSet();

    try {
      isDeletingConversations.value = true;

      await Whatsappleade.deleteLeads(hid: hid, conversationIds: ids.toList());

      conversations.removeWhere((c) => ids.contains(c.id));
      conversations.refresh();

      socketMessages.removeWhere((m) => ids.contains(m.conversationId));

      latestSocketMessagesByConversation.removeWhere(
        (id, _) => ids.contains(id),
      );
      latestSocketMessagesByConversation.refresh();

      if (ids.contains(currentConversationId.value)) clearCurrentConversation();

      clearConversationSelection();
      update();

      return true;
    } catch (e) {
      debugPrint('DELETE CONVERSATIONS ERROR: $e');
      return false;
    } finally {
      isDeletingConversations.value = false;
    }
  }

  // ============================================================
  // MARK AS READ (API + local)
  // ============================================================

  Future<void> markConversationAsReadLocally(String conversationId) async {
    try {
      await MarkConversationAsRead.markConversationAsRead(
        conversationId: conversationId,
      );

      final socketMessage = latestSocketMessagesByConversation[conversationId];

      if (socketMessage != null) {
        latestSocketMessagesByConversation[conversationId] = _copySocketMessage(
          socketMessage,
          unreadCount: 0,
        );
        latestSocketMessagesByConversation.refresh();
      }

      final index = _conversationIndex(conversationId);
      if (index != -1) _updateConversation(index, {'unread_count': 0});
    } catch (e) {
      debugPrint('MARK AS READ ERROR: $e');
    }
  }

  // ============================================================
  // TAB / SEARCH / LATEST
  // ============================================================

  void changeTab(int index) => selectedTab.value = index;

  void search(String value) => searchText.value = value;

  WhatsappSocketMessageModel? latestMessageForConversation(String id) =>
      latestSocketMessagesByConversation[id];

  // ============================================================
  // COUNTS
  // ============================================================

  bool _isConverted(WhatsappConversationModel c) =>
      c.status.toUpperCase() == 'CONVERTED';

  int get activeCount =>
      conversations.where((c) => !is24HoursCompleted(c)).length;

  int get inactiveCount => conversations.where(is24HoursCompleted).length;

  int get convertedCount => conversations.where(_isConverted).length;

  int get totalUnreadCount =>
      conversations.fold(0, (total, c) => total + c.unreadCount);

  // ============================================================
  // FILTERED CHATS  (tab -> search -> nayi pehle)
  //   tab 0 = Active, 1 = Inactive, 2 = Converted
  // ============================================================

  List<WhatsappConversationModel> get filteredChats {
    final tab = selectedTab.value;

    var list = conversations.where((c) {
      if (tab == 0) return !is24HoursCompleted(c);
      if (tab == 1) return is24HoursCompleted(c);
      return _isConverted(c);
    }).toList();

    final query = searchText.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      list = list.where((chat) {
        return (chat.name ?? '').toLowerCase().contains(query) ||
            chat.phone.toLowerCase().contains(query) ||
            (chat.lastMessage?.text ?? '').toLowerCase().contains(query);
      }).toList();
    }

    list.sort((a, b) {
      final dateA = DateTime.tryParse(a.lastMessage?.createdAt ?? a.createdAt);
      final dateB = DateTime.tryParse(b.lastMessage?.createdAt ?? b.createdAt);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    return list;
  }

  /// Active = last message 24 ghante ke andar, warna Inactive
  bool is24HoursCompleted(WhatsappConversationModel conversation) {
    final date = DateTime.tryParse(
      conversation.lastMessage?.updatedAt ?? conversation.updatedAt,
    );

    if (date == null) return true;

    return DateTime.now().difference(date.toLocal()) >
        const Duration(hours: 24);
  }
}
