import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/services/whatsappConversation.dart';
import 'package:eazotel/features/whatsapp/services/whatsapp_api.dart';
import 'package:eazotel/features/whatsapp/services/whatsapp_socket_services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class WhatsappController extends GetxController {
  // ============================================================
  // CONVERSATIONS
  // ============================================================

  final RxList<WhatsappConversationModel> conversations =
      <WhatsappConversationModel>[].obs;

  final RxInt selectedTab = 0.obs;

  final RxString searchText = ''.obs;

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  final RxBool isIntegrationLoading = false.obs;

  final RxString integrationErrorMessage = ''.obs;

  /// API ka complete response yahan store hoga.
  /// Iske liye koi model required nahi hai.
  final Rxn<Map<String, dynamic>> whatsappIntegration =
      Rxn<Map<String, dynamic>>();

  // ============================================================
  // LEAD RESPONSE
  // ============================================================

  final Rxn<LeadResponseModel> leadResponse = Rxn<LeadResponseModel>();

  /// Lead response se nikale gaye saare NDID (cache).
  Set<String> _leadNdids = <String>{};

  Worker? _leadWorker;

  // ============================================================
  // SOCKET MESSAGES
  // ============================================================

  final RxList<WhatsappSocketMessageModel> socketMessages =
      <WhatsappSocketMessageModel>[].obs;

  final Rxn<WhatsappSocketMessageModel> latestSocketMessage =
      Rxn<WhatsappSocketMessageModel>();

  final RxMap<String, WhatsappSocketMessageModel>
  latestSocketMessagesByConversation =
      <String, WhatsappSocketMessageModel>{}.obs;

  // ============================================================
  // CURRENT OPEN CONVERSATION
  // ============================================================

  final RxString currentConversationId = ''.obs;

  // ============================================================
  // API MESSAGES
  // ============================================================

  final RxBool isMessagesLoading = false.obs;

  final RxString messagesErrorMessage = ''.obs;

  final Rxn<WhatsappMessagesResponseModel> messagesResponse =
      Rxn<WhatsappMessagesResponseModel>();

  // ============================================================
  // HID (dynamic - screen se pass hota hai)
  // ============================================================

  final String hid;

  WhatsappController({required this.hid});

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    // leadResponse kahin bhi set ho (setLeadResponse ya .value = ...),
    // NDID cache apne aap update ho jayega.
    _leadWorker = ever<LeadResponseModel?>(leadResponse, (_) {
      _rebuildLeadNdids();
    });
    // WhatsApp integration API
    getWhatsappIntegration();

    getConversations();

    WhatsappSocketService.connect(onMessage: handleSocketMessage);
  }

  @override
  void onClose() {
    _leadWorker?.dispose();

    WhatsappSocketService.disconnect();

    super.onClose();
  }

  bool get whatsappIntegrationSuccess {
    final data = whatsappIntegration.value;

    if (data == null) {
      return false;
    }

    final result = data['result'];

    if (result is! Map) {
      return false;
    }

    final docs = result['docs'];

    if (docs is! Map) {
      return false;
    }

    return docs.isNotEmpty;
  }

  Future<void> getWhatsappIntegration() async {
    try {
      isIntegrationLoading.value = true;
      integrationErrorMessage.value = '';

      final dynamic decoded = await WhatsappApiService.getWhatsappIntegration(
        hid: hid,
      );

      if (decoded is Map) {
        whatsappIntegration.value = Map<String, dynamic>.from(decoded);
      } else {
        debugPrint('❌ WHATSAPP INTEGRATION: Response Map nahi hai');
      }
    } catch (e, stackTrace) {
      integrationErrorMessage.value = e.toString();

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP INTEGRATION API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');
    } finally {
      isIntegrationLoading.value = false;
    }
  }

  // ============================================================
  // LEAD NDIDS
  // ============================================================

  void setLeadResponse(LeadResponseModel response) {
    leadResponse.value = response;

    _rebuildLeadNdids();

    debugPrint('LEAD RESPONSE UPDATED - NDID COUNT: ${_leadNdids.length}');
  }

  void _rebuildLeadNdids() {
    final Set<String> ndids = <String>{};

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

  /// JSON ke andar recursively "ndid" key dhoondta hai.
  void _collectNdids(dynamic value, Set<String> result) {
    if (value == null) return;

    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key?.toString().toLowerCase();

        if (key == 'ndid') {
          final text = entry.value?.toString().trim();

          if (text != null && text.isNotEmpty && text != 'null') {
            result.add(text);
          }
        }

        _collectNdids(entry.value, result);
      }

      return;
    }

    if (value is Iterable) {
      for (final item in value) {
        _collectNdids(item, result);
      }
    }
  }

  /// Socket ka NDID allowed hai ya nahi.
  ///
  /// 1) leadResponse set hai  -> sirf lead NDID se match (strict).
  /// 2) leadResponse set NAHI -> already load hui conversations ke NDID se
  ///    match (fallback), taaki UI band na ho.
  bool _isLeadNdid(String ndid) {
    final String value = ndid.trim();

    if (leadResponse.value != null) {
      if (_leadNdids.isEmpty) _rebuildLeadNdids();

      if (_leadNdids.isNotEmpty) {
        return _leadNdids.contains(value);
      }
    }

    debugPrint(
      'WARNING: leadResponse set nahi hai -> fallback: '
      'loaded conversations ke NDID se match',
    );

    return conversations.any(
      (conversation) => conversation.ndid.trim() == value,
    );
  }

  String? _getSocketNdid(Map<String, dynamic> data) {
    final value = data['ndid']?.toString().trim();

    if (value == null || value.isEmpty || value == 'null') {
      return null;
    }

    return value;
  }

  // ============================================================
  // OPEN CONVERSATION
  // ============================================================

  void setCurrentConversation(String conversationId) {
    currentConversationId.value = conversationId;

    debugPrint('CURRENT WHATSAPP CONVERSATION: $conversationId');
  }

  void clearCurrentConversation() {
    currentConversationId.value = '';
  }

  // ============================================================
  // SOCKET EVENT HANDLER
  // ============================================================

  void handleSocketMessage(Map<String, dynamic> serverResponse) {
    try {
      final event = serverResponse['event'];

      final data = serverResponse['data'];

      if (data == null || data is! Map) {
        debugPrint('SOCKET DATA IS NULL OR INVALID');
        return;
      }

      final dataMap = Map<String, dynamic>.from(data);

      debugPrint('SOCKET EVENT RECEIVED: $event');

      if (event == 'WHATSAPP_NEW_MESSAGE') {
        handleNewMessage(dataMap);
        return;
      }

      if (event == 'WHATSAPP_NEW_CONVERSATION') {
        handleNewConversation(dataMap);
        return;
      }

      if (event == 'WHATSAPP_MESSAGE_STATUS') {
        handleMessageStatus(dataMap);
        return;
      }
    } catch (e) {
      debugPrint('SOCKET EVENT HANDLER ERROR: $e');
    }
  }

  // ============================================================
  // WHATSAPP_NEW_MESSAGE
  //
  // STEP 1  -> NDID lead list mein hai? Nahi to DISCARD.
  // STEP 2  -> socket message save (dedupe).
  // STEP 3  -> conversation id list mein hai?
  //              haan  -> usi conversation ko update karke TOP par
  //              nahi  -> nayi conversation banake TOP par
  // STEP 4  -> conversation abhi open hai? To messages response
  //            mein message add karo.
  // ============================================================

  void handleNewMessage(Map<String, dynamic> rawMessage) {
    try {
      final WhatsappSocketMessageModel message =
          WhatsappSocketMessageModel.fromJson(rawMessage);

      final String? conversationId = message.conversationId;

      if (conversationId == null || conversationId.isEmpty) {
        debugPrint('SOCKET MESSAGE DISCARDED: CONVERSATION ID EMPTY');
        return;
      }

      // ==========================================================
      // STEP 1: NDID CHECK (lead response se match)
      // ==========================================================

      final String? socketNdid = _getSocketNdid(rawMessage);

      debugPrint(
        'NEW MESSAGE -> conv: $conversationId | ndid: $socketNdid | '
        'leadNdids: ${_leadNdids.length} | '
        'loadedConversations: ${conversations.length}',
      );

      if (socketNdid == null) {
        debugPrint('SOCKET MESSAGE DISCARDED: NDID EMPTY');
        return;
      }

      if (!_isLeadNdid(socketNdid)) {
        debugPrint('SOCKET MESSAGE DISCARDED: NDID NOT IN LEADS ($socketNdid)');
        return;
      }

      debugPrint('NDID MATCHED -> processing message');

      // ==========================================================
      // STEP 2: SAVE SOCKET MESSAGE
      // ==========================================================

      final bool alreadyExists = socketMessages.any(
        (item) =>
            (message.messageId != null &&
                item.messageId == message.messageId) ||
            (message.id != null && item.id == message.id),
      );

      if (!alreadyExists) {
        socketMessages.add(message);
      }

      latestSocketMessage.value = message;

      latestSocketMessagesByConversation[conversationId] = message;
      latestSocketMessagesByConversation.refresh();

      // ==========================================================
      // STEP 3: CONVERSATION LIST (update ya new, dono TOP par)
      // ==========================================================

      _upsertConversationFromSocket(
        rawMessage: rawMessage,
        socketMessage: message,
        socketNdid: socketNdid,
      );

      // ==========================================================
      // STEP 4: OPEN CONVERSATION KE MESSAGES RESPONSE MEIN ADD
      // ==========================================================

      if (currentConversationId.value == conversationId) {
        _addSocketMessageToMessagesResponse(message);
      }

      update();
    } catch (e, stack) {
      debugPrint('handleNewMessage ERROR: $e');
      debugPrint('$stack');
    }
  }

  // ============================================================
  // UPDATE / INSERT CONVERSATION (socket message se)
  // ============================================================

  void _upsertConversationFromSocket({
    required Map<String, dynamic> rawMessage,
    required WhatsappSocketMessageModel socketMessage,
    required String socketNdid,
  }) {
    final String conversationId = socketMessage.conversationId ?? '';

    if (conversationId.isEmpty) return;

    final bool isOpen = currentConversationId.value == conversationId;
    final bool isIncoming = _isIncomingSocket(socketMessage);

    final Map<String, dynamic> lastMessage = _buildLastMessage(
      rawMessage,
      socketMessage,
    );

    final int index = conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );

    // ----------------------------------------------------------
    // EXISTING CONVERSATION -> UPDATE + MOVE TO TOP
    // ----------------------------------------------------------

    if (index != -1) {
      final old = conversations[index];

      final Map<String, dynamic> json = {
        // Purani conversation ka saara data (notes, handling, status...)
        ...old.toJson(),

        // Sirf ye fields socket ke hisaab se update honge
        'name': _cleanString(rawMessage['name']) ?? old.name,

        'unread_count': _resolveUnreadCount(
          oldCount: old.unreadCount,
          raw: rawMessage,
          isOpen: isOpen,
          isIncoming: isIncoming,
        ),

        'last_message': lastMessage,

        'updatedAt': lastMessage['updated_at'],
      };

      final updated = WhatsappConversationModel.fromJson(json);

      conversations.removeAt(index);
      conversations.insert(0, updated);
      conversations.refresh();

      debugPrint('CONVERSATION UPDATED -> TOP: $conversationId');

      return;
    }

    // ----------------------------------------------------------
    // NEW CONVERSATION -> CREATE + TOP
    // ----------------------------------------------------------

    final String now = DateTime.now().toIso8601String();

    final newConversation = WhatsappConversationModel.fromJson({
      '_id': conversationId,
      'hid': socketMessage.hid ?? hid,
      'ndid': socketNdid,

      // Incoming message: customer = from. Outgoing: customer = to.
      'phone': (isIncoming ? socketMessage.from : socketMessage.to) ?? '',
      'phoneNumberId':
          (isIncoming ? socketMessage.to : socketMessage.from) ?? '',

      'name': _cleanString(rawMessage['name']),

      'unread_count': _resolveUnreadCount(
        oldCount: 0,
        raw: rawMessage,
        isOpen: isOpen,
        isIncoming: isIncoming,
      ),

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

      'createdAt': socketMessage.createdAt ?? now,
      'updatedAt': lastMessage['updated_at'],
    });

    conversations.insert(0, newConversation);
    conversations.refresh();

    debugPrint('NEW CONVERSATION INSERTED -> TOP: $conversationId');
  }

  // ============================================================
  // ADD SOCKET MESSAGE TO OPEN CONVERSATION (messages response)
  // ============================================================

  void _addSocketMessageToMessagesResponse(
    WhatsappSocketMessageModel socketMessage,
  ) {
    // API abhi load ho rahi hai -> response purani conversation ka ho
    // sakta hai. Socket message merger se waise bhi dikh jayega.
    if (isMessagesLoading.value) {
      return;
    }

    final response = messagesResponse.value;

    if (response == null) {
      return;
    }

    final List<WhatsappMessageModel> oldMessages =
        response.result?.messages ?? const <WhatsappMessageModel>[];

    // Safety: response isi conversation ka hona chahiye.
    final bool belongsToOtherConversation = oldMessages.any(
      (m) =>
          m.conversationId != null &&
          m.conversationId!.isNotEmpty &&
          m.conversationId != socketMessage.conversationId,
    );

    if (belongsToOtherConversation) {
      return;
    }

    final bool exists = oldMessages.any(
      (m) =>
          (socketMessage.messageId != null &&
              m.messageId == socketMessage.messageId) ||
          (socketMessage.id != null && m.id == socketMessage.id),
    );

    if (exists) {
      return;
    }

    final WhatsappMessageModel newMessage = _socketToApiMessage(socketMessage);

    // Nayi list + nayi response banate hain (const list par add nahi
    // karte) taaki Obx sahi se rebuild ho.
    messagesResponse.value = WhatsappMessagesResponseModel(
      success: response.success,
      responseStatusCode: response.responseStatusCode,
      responseMessage: response.responseMessage,
      request: response.request,
      result: WhatsappMessagesResultModel(
        messages: [...oldMessages, newMessage],
      ),
    );

    debugPrint('SOCKET MESSAGE ADDED TO MESSAGES RESPONSE');
  }

  WhatsappMessageModel _socketToApiMessage(WhatsappSocketMessageModel m) {
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
      media: _mediaFromSocket(m.media),
      interactive: m.interactive,
      location: m.location,
      contacts: m.contacts,
    );
  }

  WhatsappMediaModel? _mediaFromSocket(dynamic media) {
    if (media is WhatsappMediaModel) return media;

    if (media is Map) {
      return WhatsappMediaModel.fromJson(Map<String, dynamic>.from(media));
    }

    return null;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _isIncomingSocket(WhatsappSocketMessageModel message) {
    return message.direction?.toLowerCase() == 'inbound' ||
        message.sender?.toLowerCase() == 'contact';
  }

  String _socketSender(Map<String, dynamic> rawMessage) {
    final sender = rawMessage['sender']?.toString();

    if (sender == null || sender.isEmpty) {
      return 'contact';
    }

    return sender;
  }

  String? _cleanString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }

    return text;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  int _resolveUnreadCount({
    required int oldCount,
    required Map<String, dynamic> raw,
    required bool isOpen,
    required bool isIncoming,
  }) {
    // Server unread_count bheje to wahi sahi hai.
    final fromServer = raw['unread_count'];

    if (fromServer != null) {
      final parsed = fromServer is int
          ? fromServer
          : int.tryParse(fromServer.toString());

      if (parsed != null) return parsed;
    }

    // Chat abhi open hai -> unread nahi.
    if (isOpen) return 0;

    // Naya incoming message -> +1
    if (isIncoming) return oldCount + 1;

    return oldCount;
  }

  Map<String, dynamic> _buildLastMessage(
    Map<String, dynamic> raw,
    WhatsappSocketMessageModel m,
  ) {
    final String now = DateTime.now().toIso8601String();

    return {
      'sender': _socketSender(raw),
      'text': _lastMessageText(m),
      'type': m.messageType ?? 'text',
      'created_at': m.createdAt ?? now,
      'updated_at': m.updatedAt ?? m.createdAt ?? now,
    };
  }

  String _lastMessageText(WhatsappSocketMessageModel m) {
    final body = m.body?.trim() ?? '';

    if (body.isNotEmpty) return body;

    switch ((m.messageType ?? '').toLowerCase()) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎥 Video';
      case 'audio':
      case 'voice':
        return '🎵 Audio';
      case 'document':
        return '📄 Document';
      case 'sticker':
        return 'Sticker';
      case 'location':
        return '📍 Location';
      case 'contacts':
        return '👤 Contact';
      case 'interactive':
        return 'Interactive message';
      default:
        return '';
    }
  }

  // ============================================================
  // WHATSAPP_NEW_CONVERSATION
  //
  // NDID lead list mein na ho -> discard.
  // Conversation id list mein ho -> update + top. Warna new + top.
  // ============================================================

  void handleNewConversation(Map<String, dynamic> data) {
    try {
      final String? socketNdid = _getSocketNdid(data);

      final String? conversationId = data['_id']?.toString();

      // --------------------------------------------------------
      // NDID CHECK FIRST
      // --------------------------------------------------------

      if (socketNdid == null) {
        debugPrint('NEW CONVERSATION DISCARDED: NDID EMPTY');
        return;
      }

      if (!_isLeadNdid(socketNdid)) {
        debugPrint('NEW CONVERSATION DISCARDED: NDID NOT IN LEADS');
        return;
      }

      if (conversationId == null || conversationId.isEmpty) {
        return;
      }

      final Map<String, dynamic>? lastMessage = _asMap(data['last_message']);

      final int index = conversations.indexWhere(
        (conversation) => conversation.id == conversationId,
      );

      // --------------------------------------------------------
      // EXISTING -> UPDATE + TOP
      // --------------------------------------------------------

      if (index != -1) {
        final old = conversations[index];

        final Map<String, dynamic> json = {
          ...old.toJson(),
          'ndid': socketNdid,
          'phone': _cleanString(data['phone']) ?? old.phone,
          'phoneNumberId':
              _cleanString(data['phoneNumberId']) ?? old.phoneNumberId,
          'name': _cleanString(data['name']) ?? old.name,
          'status': _cleanString(data['status']) ?? old.status,
          if (data['unread_count'] != null)
            'unread_count': data['unread_count'],
          if (lastMessage != null) 'last_message': lastMessage,
          'updatedAt':
              _cleanString(data['updatedAt']) ??
              DateTime.now().toIso8601String(),
        };

        conversations.removeAt(index);
        conversations.insert(0, WhatsappConversationModel.fromJson(json));
        conversations.refresh();

        return;
      }

      // --------------------------------------------------------
      // NEW -> CREATE + TOP
      // --------------------------------------------------------

      final String now = DateTime.now().toIso8601String();

      final newConversation = WhatsappConversationModel.fromJson({
        '_id': conversationId,
        'hid': _cleanString(data['hid']) ?? hid,
        'ndid': socketNdid,
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
      });

      conversations.insert(0, newConversation);
      conversations.refresh();
    } catch (e) {
      debugPrint('NEW CONVERSATION ERROR: $e');
    }
  }

  // ============================================================
  // MESSAGE STATUS
  // ============================================================

  void handleMessageStatus(Map<String, dynamic> data) {
    try {
      final String? messageId = data['messageId']?.toString();

      final String? status = data['status']?.toString();

      if (messageId == null ||
          messageId.isEmpty ||
          status == null ||
          status.isEmpty) {
        return;
      }

      final int index = socketMessages.indexWhere(
        (message) => message.messageId == messageId || message.id == messageId,
      );

      if (index == -1) {
        return;
      }

      debugPrint('MESSAGE STATUS: $messageId -> $status');
    } catch (e) {
      debugPrint('MESSAGE STATUS ERROR: $e');
    }
  }

  // ============================================================
  // GET CONVERSATIONS
  // ============================================================

  Future<void> getConversations() async {
    try {
      isLoading.value = true;

      errorMessage.value = '';

      final response = await WhatsappService.getConversations(hid: hid);

      final result = response['result'];

      if (result == null) {
        conversations.clear();
        return;
      }

      final conversationList = result['conversations'];

      if (conversationList is! List) {
        conversations.clear();
        return;
      }

      conversations.assignAll(
        conversationList
            .map(
              (item) => WhatsappConversationModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(),
      );

      _restoreSocketConversationOrder();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // RESTORE SOCKET ORDER
  // ============================================================

  void _restoreSocketConversationOrder() {
    if (latestSocketMessagesByConversation.isEmpty) {
      return;
    }

    final List<WhatsappConversationModel> matched = [];

    for (final entry in latestSocketMessagesByConversation.entries) {
      final conversationId = entry.key;

      final index = conversations.indexWhere(
        (conversation) => conversation.id == conversationId,
      );

      if (index != -1) {
        matched.add(conversations.removeAt(index));
      }
    }

    if (matched.isNotEmpty) {
      conversations.insertAll(0, matched);

      conversations.refresh();
    }
  }

  // ============================================================
  // GET CONVERSATION MESSAGES
  // ============================================================

  Future<void> getConversationMessages({required String conversationId}) async {
    try {
      isMessagesLoading.value = true;

      messagesErrorMessage.value = '';

      setCurrentConversation(conversationId);

      final response = await WhatsappService.getConversationMessages(
        conversationId: conversationId,
      );

      messagesResponse.value = response;

      debugPrint('MESSAGES LOADED: $conversationId');
    } catch (e) {
      messagesErrorMessage.value = e.toString();
    } finally {
      isMessagesLoading.value = false;
    }
  }

  // ============================================================
  // CURRENT SOCKET MESSAGES
  // ============================================================

  List<WhatsappSocketMessageModel> get currentSocketMessages {
    final conversationId = currentConversationId.value;

    if (conversationId.isEmpty) {
      return [];
    }

    return socketMessages
        .where((message) => message.conversationId == conversationId)
        .toList();
  }

  // ============================================================
  // LATEST MESSAGE
  // ============================================================

  WhatsappSocketMessageModel? latestMessageForConversation(
    String conversationId,
  ) {
    return latestSocketMessagesByConversation[conversationId];
  }

  // ============================================================
  // TAB
  // ============================================================

  void changeTab(int index) {
    selectedTab.value = index;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void search(String value) {
    searchText.value = value;
  }

  // ============================================================
  // COUNTS
  // ============================================================

  int get activeCount {
    return conversations.where((conversation) {
      return !is24HoursCompleted(conversation);
    }).length;
  }

  int get inactiveCount {
    return conversations.where((conversation) {
      return is24HoursCompleted(conversation);
    }).length;
  }

  int get convertedCount {
    return conversations
        .where((item) => item.status.toUpperCase() == 'CONVERTED')
        .length;
  }

  // ============================================================
  // FILTERED CHATS
  // ============================================================

  List<WhatsappConversationModel> get filteredChats {
    List<WhatsappConversationModel> list;

    if (selectedTab.value == 0) {
      // ACTIVE
      list = conversations.where((conversation) {
        return !is24HoursCompleted(conversation);
      }).toList();
    } else if (selectedTab.value == 1) {
      // INACTIVE
      list = conversations.where((conversation) {
        return is24HoursCompleted(conversation);
      }).toList();
    } else {
      // CONVERTED
      list = conversations.where((conversation) {
        return conversation.status.toUpperCase() == 'CONVERTED';
      }).toList();
    }

    final String searchValue = searchText.value.trim().toLowerCase();

    if (searchValue.isEmpty) {
      return list;
    }

    return list.where((chat) {
      return (chat.name ?? '').toLowerCase().contains(searchValue) ||
          chat.phone.toLowerCase().contains(searchValue) ||
          (chat.lastMessage?.text ?? '').toLowerCase().contains(searchValue);
    }).toList();
  }

  // ============================================================
  // TOTAL UNREAD
  // ============================================================

  int get totalUnreadCount {
    return conversations.fold(0, (total, item) => total + item.unreadCount);
  }

  // ============================================================
  // 24 HOURS CHECK
  // Active   = last message 24 ghante ke andar
  // Inactive = last message 24 ghante se purana
  // ============================================================

  bool is24HoursCompleted(WhatsappConversationModel conversation) {
    final String? dateString =
        conversation.lastMessage?.updatedAt ??
        conversation.updatedAt ??
        conversation.createdAt;

    if (dateString == null || dateString.isEmpty) {
      return true;
    }

    final DateTime? date = DateTime.tryParse(dateString);

    if (date == null) {
      return true;
    }

    final Duration difference = DateTime.now().difference(date.toLocal());

    return difference > const Duration(hours: 24);
  }
}
