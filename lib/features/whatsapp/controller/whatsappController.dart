import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/services/whatsappConversation.dart';
import 'package:eazotel/features/whatsapp/services/whatsapp_socket_services.dart';
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

  // ============================================================
  // SOCKET MESSAGES
  // ============================================================

  final RxList<WhatsappSocketMessageModel> socketMessages =
      <WhatsappSocketMessageModel>[].obs;

  final Rxn<WhatsappSocketMessageModel> latestSocketMessage =
      Rxn<WhatsappSocketMessageModel>();

  // Latest socket message for every conversation
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
  // HID
  // ============================================================

  static const String hid = '41913874';

  // static const String hid = '40526487';
  // static const String hid = '11974255';

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    getConversations();

    WhatsappSocketService.connect(onMessage: handleSocketMessage);
  }

  @override
  void onClose() {
    WhatsappSocketService.disconnect();

    super.onClose();
  }

  // ============================================================
  // OPEN CONVERSATION
  // ============================================================

  void setCurrentConversation(String conversationId) {
    currentConversationId.value = conversationId;

    print('');
    print('==============================================');
    print('💬 CURRENT WHATSAPP CONVERSATION');
    print('==============================================');
    print('Conversation ID: $conversationId');
    print('==============================================');
  }

  void clearCurrentConversation() {
    currentConversationId.value = '';
  }

  // ============================================================
  // SOCKET EVENT HANDLER
  // ============================================================

  void handleSocketMessage(Map<String, dynamic> serverResponse) {
    final event = serverResponse['event'];

    final data = serverResponse['data'];

    if (data == null || data is! Map) {
      return;
    }

    final dataMap = Map<String, dynamic>.from(data);

    print('');
    print('==============================================');
    print('📡 SOCKET EVENT HANDLED');
    print('==============================================');
    print('EVENT: $event');
    print('==============================================');

    // ------------------------------------------------------------
    // NEW MESSAGE
    // ------------------------------------------------------------

    if (event == 'WHATSAPP_NEW_MESSAGE') {
      handleNewMessage(dataMap);
      return;
    }

    // ------------------------------------------------------------
    // NEW CONVERSATION
    // ------------------------------------------------------------

    if (event == 'WHATSAPP_NEW_CONVERSATION') {
      handleNewConversation(dataMap);
      return;
    }

    // ------------------------------------------------------------
    // MESSAGE STATUS
    // ------------------------------------------------------------

    if (event == 'WHATSAPP_MESSAGE_STATUS') {
      handleMessageStatus(dataMap);
      return;
    }
  }

  // ============================================================
  // WHATSAPP_NEW_MESSAGE
  // ============================================================
  void handleNewMessage(Map<String, dynamic> data) {
    try {
      final message = WhatsappSocketMessageModel.fromJson(data);

      print('');
      print('==============================================');
      print('📩 NEW WHATSAPP MESSAGE');
      print('==============================================');
      print('Conversation ID: ${message.conversationId}');
      print('Message ID: ${message.messageId}');
      print('Sender: ${message.sender}');
      print('Direction: ${message.direction}');
      print('Body: ${message.body}');
      print('Status: ${message.status}');
      print('Name: ${message.name}');
      print('==============================================');

      // Socket message list
      final alreadyExists = socketMessages.any(
        (item) => item.messageId == message.messageId || item.id == message.id,
      );

      if (!alreadyExists) {
        socketMessages.add(message);
      }

      latestSocketMessage.value = message;

      final conversationId = message.conversationId;

      if (conversationId != null && conversationId.isNotEmpty) {
        latestSocketMessagesByConversation[conversationId] = message;
        latestSocketMessagesByConversation.refresh();

        // IMPORTANT:
        // Agar ye wahi conversation hai jo currently open hai,
        // to socket message ko API messages list me add karo.
        if (currentConversationId.value == conversationId) {
          _addSocketMessageToCurrentConversation(message);
        }

        _updateConversationFromSocket(message);
      }
    } catch (e) {
      print('❌ NEW MESSAGE SOCKET ERROR: $e');
    }
  }

  void _addSocketMessageToCurrentConversation(
    WhatsappSocketMessageModel socketMessage,
  ) {
    final response = messagesResponse.value;

    if (response == null) {
      print('⚠️ messagesResponse is null');
      return;
    }

    final result = response.result;

    if (result == null) {
      print('⚠️ messages result is null');
      return;
    }

    final messages = result.messages;

    if (messages == null) {
      print('⚠️ messages list is null');
      return;
    }

    // Duplicate check
    final exists = messages.any(
      (message) =>
          message.messageId == socketMessage.messageId ||
          message.id == socketMessage.id,
    );

    if (exists) {
      print('⚠️ Socket message already exists');
      return;
    }

    // Yahan IMPORTANT hai:
    // Aapke actual message model ka constructor use hoga.
    //
    // Agar API message model aur socket model same nahi hain,
    // to yahan socket -> API message model conversion karna padega.
  }
  // ============================================================
  // UPDATE CONVERSATION FROM SOCKET
  // ============================================================

  void _updateConversationFromSocket(WhatsappSocketMessageModel message) {
    final conversationId = message.conversationId;

    if (conversationId == null || conversationId.isEmpty) {
      return;
    }

    final index = conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );

    if (index == -1) {
      print(
        '⚠️ Conversation not found in current conversation list: '
        '$conversationId',
      );

      return;
    }

    /*
     * IMPORTANT:
     *
     * WhatsappConversationModel ka exact constructor / copyWith
     * current code me available nahi hai.
     *
     * Isliye yahan existing model ko blindly recreate nahi kar rahe.
     *
     * Latest socket message already:
     *
     * latestSocketMessagesByConversation[conversationId]
     *
     * me available hai.
     *
     * Conversation List UI is map ko use karke latest message
     * immediately show kar sakti hai.
     */

    latestSocketMessagesByConversation[conversationId] = message;

    latestSocketMessagesByConversation.refresh();

    print('');
    print('==============================================');
    print('🔄 CONVERSATION LIST SOCKET UPDATE');
    print('==============================================');
    print('Conversation ID: $conversationId');
    print('Latest message: ${message.body}');
    print('Unread count: ${message.unreadCount}');
    print('Created at: ${message.createdAt}');
    print('==============================================');
  }

  // ============================================================
  // WHATSAPP_NEW_CONVERSATION
  // ============================================================

  void handleNewConversation(Map<String, dynamic> data) {
    try {
      final conversationId = data['_id']?.toString();

      if (conversationId == null || conversationId.isEmpty) {
        return;
      }

      // ----------------------------------------------------------
      // DUPLICATE CHECK
      // ----------------------------------------------------------

      final exists = conversations.any(
        (conversation) => conversation.id == conversationId,
      );

      if (exists) {
        return;
      }

      // ----------------------------------------------------------
      // CREATE CONVERSATION
      // ----------------------------------------------------------

      final newConversation = WhatsappConversationModel.fromJson({
        '_id': data['_id'],
        'phone': data['phone'],
        'name': data['name'],
        'profile_image': data['profile_image'],
        'last_message': data['last_message'],
        'status': data['status'] ?? 'open',
        'unread_count': data['unread_count'] ?? 1,
        'updatedAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'createdAt': data['createdAt'],
      });

      // ----------------------------------------------------------
      // INSERT AT TOP
      // ----------------------------------------------------------

      conversations.insert(0, newConversation);

      print('');
      print('==============================================');
      print('🆕 NEW WHATSAPP CONVERSATION');
      print('==============================================');
      print('Conversation ID: $conversationId');
      print('Phone: ${data['phone']}');
      print('Name: ${data['name']}');
      print('==============================================');
    } catch (e) {
      print('');
      print('==============================================');
      print('❌ NEW CONVERSATION ERROR');
      print('==============================================');
      print(e);
      print('==============================================');
    }
  }

  // ============================================================
  // WHATSAPP_MESSAGE_STATUS
  // ============================================================

  void handleMessageStatus(Map<String, dynamic> data) {
    try {
      final messageId = data['messageId']?.toString();

      final status = data['status']?.toString();

      final phoneNumberId = data['phoneNumberId']?.toString();

      if (messageId == null || messageId.isEmpty) {
        return;
      }

      if (status == null || status.isEmpty) {
        return;
      }

      print('');
      print('==============================================');
      print('📨 WHATSAPP MESSAGE STATUS');
      print('==============================================');
      print('Message ID: $messageId');
      print('Status: $status');
      print('Phone Number ID: $phoneNumberId');
      print('==============================================');

      // ----------------------------------------------------------
      // UPDATE SOCKET MESSAGE
      // ----------------------------------------------------------

      final index = socketMessages.indexWhere(
        (message) => message.messageId == messageId || message.id == messageId,
      );

      if (index == -1) {
        print('⚠️ Socket message not found for status update');

        return;
      }

      final oldMessage = socketMessages[index];

      /*
       * Agar WhatsappSocketMessageModel immutable hai,
       * to status update ke liye copyWith hona chahiye.
       *
       * Neeche temporary model recreation nahi ki gayi hai,
       * kyunki exact model constructor already available nahi hai.
       */

      print('Old status: ${oldMessage.status}');

      print('New status: $status');

      // ----------------------------------------------------------
      // CURRENT OPEN CHAT
      // ----------------------------------------------------------

      if (currentConversationId.value.isNotEmpty) {
        print(
          'Current conversation: '
          '${currentConversationId.value}',
        );
      }
    } catch (e) {
      print('');
      print('==============================================');
      print('❌ MESSAGE STATUS ERROR');
      print('==============================================');
      print(e);
      print('==============================================');
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
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GET CONVERSATION MESSAGES
  // ============================================================

  Future<void> getConversationMessages({required String conversationId}) async {
    try {
      isMessagesLoading.value = true;

      messagesErrorMessage.value = '';

      // Current conversation remember karo
      setCurrentConversation(conversationId);

      final WhatsappMessagesResponseModel response =
          await WhatsappService.getConversationMessages(
            conversationId: conversationId,
          );

      messagesResponse.value = response;

      // ----------------------------------------------------------
      // API MESSAGES LOAD HO GAYE
      // ----------------------------------------------------------

      print('');
      print('==============================================');
      print('💬 WHATSAPP MESSAGES LOADED');
      print('==============================================');
      print('Conversation ID: $conversationId');
      print('==============================================');
    } catch (e) {
      messagesErrorMessage.value = e.toString();
    } finally {
      isMessagesLoading.value = false;
    }
  }

  // ============================================================
  // GET SOCKET MESSAGES FOR CURRENT CONVERSATION
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
  // GET LATEST SOCKET MESSAGE FOR CONVERSATION
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
  // ACTIVE COUNT
  // ============================================================

  int get activeCount {
    return conversations
        .where((item) => item.status.toUpperCase() == 'ACTIVE')
        .length;
  }

  // ============================================================
  // INACTIVE COUNT
  // ============================================================

  int get inactiveCount {
    return conversations
        .where((item) => item.status.toUpperCase() != 'ACTIVE')
        .length;
  }

  // ============================================================
  // FILTERED CHATS
  // ============================================================

  List<WhatsappConversationModel> get filteredChats {
    List<WhatsappConversationModel> list;

    if (selectedTab.value == 0) {
      list = conversations
          .where((item) => item.status.toUpperCase() == 'ACTIVE')
          .toList();
    } else {
      list = conversations
          .where((item) => item.status.toUpperCase() != 'ACTIVE')
          .toList();
    }

    final searchValue = searchText.value.trim().toLowerCase();

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
}
