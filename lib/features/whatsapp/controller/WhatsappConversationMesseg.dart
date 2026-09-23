import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';

class WhatsappConversationDetailController extends GetxController {
  final dynamic chat;
  final WhatsappController whatsappController;
  WhatsappConversationDetailController({
    required this.chat,
    required this.whatsappController,
  });
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  final RxInt initialUnreadCount = 0.obs;
  final RxInt newIncomingCount = 0.obs;
  final Set<String> _countedMessageIds = {};
  final Set<String> _knownSocketMessageIds = {};
  late Worker _socketWorker;
  String get conversationId => chat.id ?? '';
  int get totalUnreadCount => initialUnreadCount.value + newIncomingCount.value;
  @override
  void onInit() {
    super.onInit();
    initialUnreadCount.value = chat.unreadCount ?? 0;
    whatsappController.setCurrentConversation(conversationId);
    _socketWorker = ever<List<WhatsappSocketMessageModel>>(
      whatsappController.socketMessages,
      (_) {
        _processSocketMessages();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(animated: false);
    });
  }

  void _processSocketMessages() {
    final messages = whatsappController.socketMessages;
    bool hasNewMessage = false;
    for (final message in messages) {
      if (message.conversationId != conversationId) {
        continue;
      }
      final messageId = message.messageId ?? message.id;
      if (messageId == null || messageId.isEmpty) {
        continue;
      }
      if (_knownSocketMessageIds.contains(messageId)) {
        continue;
      }
      _knownSocketMessageIds.add(messageId);
      hasNewMessage = true;
      final isIncoming =
          message.direction == 'inbound' || message.sender == 'contact';
      if (isIncoming) {
        _countUnreadMessage(messageId);
      }
    }
    if (hasNewMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isClosed) return;
        scrollToBottom();
      });
    }
  }

  void _countUnreadMessage(String messageId) {
    if (_countedMessageIds.contains(messageId)) {
      return;
    }
    _countedMessageIds.add(messageId);
    newIncomingCount.value++;
  }

  void clearUnread() {
    initialUnreadCount.value = 0;
    newIncomingCount.value = 0;
  }

  void scrollToBottom({bool animated = true}) {
    if (!scrollController.hasClients) {
      return;
    }
    if (animated) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.jumpTo(0);
    }
  }

  @override
  void onClose() {
    _socketWorker.dispose();
    if (whatsappController.currentConversationId.value == conversationId) {
      whatsappController.setCurrentConversation('');
    }
    scrollController.dispose();
    textController.dispose();
    super.onClose();
  }
}
