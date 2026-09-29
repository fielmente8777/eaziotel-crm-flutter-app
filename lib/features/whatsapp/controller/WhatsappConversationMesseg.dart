import 'dart:convert';

import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/services/markConversationAsRead.dart';
import 'package:eazotel/features/whatsapp/services/whatsappMessegSand.dart';
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

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final ScrollController scrollController = ScrollController();

  final TextEditingController textController = TextEditingController();

  // ============================================================
  // UNREAD
  // ============================================================

  final RxInt initialUnreadCount = 0.obs;

  final RxBool isSending = false.obs;

  final RxInt newIncomingCount = 0.obs;

  final Set<String> _countedMessageIds = {};

  final Set<String> _knownSocketMessageIds = {};

  // ============================================================
  // MARK AS READ
  // ============================================================

  final Rxn<Map<String, dynamic>> markAsReadResponse =
      Rxn<Map<String, dynamic>>();

  final RxBool isMarkingAsRead = false.obs;

  // ============================================================
  // TEMPLATE SENDING
  // ============================================================

  final RxBool isTemplateSending = false.obs;

  final RxString selectedTemplateName = ''.obs;

  final RxString selectedTemplateLanguage = 'en_US'.obs;

  final RxList<String> selectedTemplateParams = <String>[].obs;

  final RxList<String> selectedTemplateParamsHeader = <String>[].obs;

  final RxString selectedTemplatePreview = ''.obs;

  // ============================================================
  // SOCKET WORKER
  // ============================================================

  late Worker _socketWorker;

  // ============================================================
  // GETTERS
  // ============================================================

  String get conversationId => chat.id ?? '';

  int get totalUnreadCount =>
      initialUnreadCount.value + newIncomingCount.value;

  // ============================================================
  // INIT
  // ============================================================

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

    markConversationAsRead();
  }

  // ============================================================
  // SOCKET MESSAGE PROCESS
  // ============================================================

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
          message.direction == 'inbound' ||
          message.sender == 'contact';

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

  // ============================================================
  // SELECT TEMPLATE
  // ============================================================

  void selectTemplate({
    required String templateName,
    required String templateLanguage,
    List<String> templateParams = const [],
    List<String> templateParamsHeader = const [],
    String preview = '',
  }) {
    selectedTemplateName.value = templateName;

    selectedTemplateLanguage.value = templateLanguage;

    selectedTemplateParams.assignAll(templateParams);

    selectedTemplateParamsHeader.assignAll(
      templateParamsHeader,
    );

    selectedTemplatePreview.value = preview;

    debugPrint('==================================================');
    debugPrint('TEMPLATE SELECTED');
    debugPrint('NAME: $templateName');
    debugPrint('LANGUAGE: $templateLanguage');
    debugPrint('BODY PARAMS: $templateParams');
    debugPrint('HEADER PARAMS: $templateParamsHeader');
    debugPrint('PREVIEW: $preview');
    debugPrint('==================================================');
  }

  // ============================================================
  // CLEAR SELECTED TEMPLATE
  // ============================================================

  void clearSelectedTemplate() {
    selectedTemplateName.value = '';

    selectedTemplateLanguage.value = 'en_US';

    selectedTemplateParams.clear();

    selectedTemplateParamsHeader.clear();

    selectedTemplatePreview.value = '';
  }

  // ============================================================
  // SEND TEMPLATE MESSAGE
  // ============================================================

  Future<bool> sendTemplateMessage({
    String? templateName,
    String? templateLanguage,
    List<String>? templateParams,
    List<String>? templateParamsHeader,
    String? preview,
  }) async {
    final phone = chat.phone?.toString().trim() ?? '';

    if (phone.isEmpty) {
      debugPrint('TEMPLATE SEND: PHONE EMPTY');

      Get.snackbar(
        'Error',
        'Customer phone number not found',
      );

      return false;
    }

    final finalTemplateName =
        templateName?.trim().isNotEmpty == true
            ? templateName!.trim()
            : selectedTemplateName.value.trim();

    if (finalTemplateName.isEmpty) {
      debugPrint('TEMPLATE SEND: TEMPLATE NAME EMPTY');

      Get.snackbar(
        'Error',
        'Please select a WhatsApp template',
      );

      return false;
    }

    final finalLanguage =
        templateLanguage?.trim().isNotEmpty == true
            ? templateLanguage!.trim()
            : selectedTemplateLanguage.value.trim();

    final finalParams =
        templateParams ?? selectedTemplateParams.toList();

    final finalHeaderParams =
        templateParamsHeader ??
        selectedTemplateParamsHeader.toList();

    final finalPreview =
        preview ?? selectedTemplatePreview.value;

    isTemplateSending.value = true;

    // ==========================================================
    // TEMP MESSAGE ID
    // ==========================================================

    final tempMessageId =
        'temp_template_${DateTime.now().microsecondsSinceEpoch}';

    // ==========================================================
    // LOCAL UI FIRST
    // ==========================================================

    final localText = finalPreview.trim().isNotEmpty
        ? finalPreview.trim()
        : 'Template: $finalTemplateName';

    whatsappController.addSentMessageToCurrentConversation(
      phone: phone,
      text: localText,
      messageId: tempMessageId,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        scrollToBottom();
      }
    });

    // ==========================================================
    // API CALL
    // ==========================================================

    try {
      final response =
          await WhatsappMessageSand.sendWhatsappTemplate(
        hid: whatsappController.hid,
        phone: phone,
        templateName: finalTemplateName,
        templateLanguage: finalLanguage,
        templateParams: finalParams,
        templateParamsHeader: finalHeaderParams,
      );

      debugPrint(
        'TEMPLATE SEND SUCCESS: ${response.body}',
      );

      // ========================================================
      // RESPONSE DECODE
      // ========================================================

      try {
        final decoded = jsonDecode(response.body);

        debugPrint(
          'TEMPLATE RESPONSE DECODED: $decoded',
        );

        final realMessageId =
            decoded['result']?['docs']?['messageId']
                ?.toString();

        debugPrint(
          'TEMPLATE REAL MESSAGE ID: $realMessageId',
        );

        // ======================================================
        // TEMP ID -> REAL ID
        // ======================================================

        if (realMessageId != null &&
            realMessageId.isNotEmpty) {
          whatsappController.updateMessageId(
            tempId: tempMessageId,
            realId: realMessageId,
          );
        }
      } catch (e) {
        debugPrint(
          'TEMPLATE RESPONSE PARSE ERROR: $e',
        );
      }

      clearSelectedTemplate();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'TEMPLATE SEND ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    } finally {
      isTemplateSending.value = false;
    }
  }

  // ============================================================
  // MARK AS READ RESPONSE
  // ============================================================

  Future<void> markConversationAsRead() async {
    try {
      final id = chat.id?.toString() ?? '';

      if (id.isEmpty) {
        debugPrint('❌ Conversation ID is empty');
        return;
      }

      isMarkingAsRead.value = true;

      final response =
          await MarkConversationAsRead.markConversationAsRead(
        conversationId: id,
      );

      debugPrint(
        '📥 MARK AS READ RESPONSE: ${response.body}',
      );

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        markAsReadResponse.value = decoded;

        debugPrint(
          '✅ MARK AS READ SUCCESS: ${decoded['success']}',
        );

        debugPrint(
          '📌 MARK AS READ MESSAGE: '
          '${decoded['responseMessage']}',
        );

        debugPrint(
          '📌 MARK AS READ STATUS: '
          '${decoded['responseStatusCode']}',
        );

        final docs = decoded['result']?['docs'];

        if (docs is Map<String, dynamic>) {
          debugPrint(
            '📌 Conversation ID: ${docs['_id']}',
          );

          debugPrint(
            '📌 Unread Count: ${docs['unread_count']}',
          );

          debugPrint(
            '📌 Conversation Status: ${docs['status']}',
          );

          debugPrint(
            '📌 Last Message: ${docs['last_message']}',
          );
        }

        if (decoded['success'] == true) {
          clearUnread();
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Mark conversation as read failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      isMarkingAsRead.value = false;
    }
  }

  // ============================================================
  // SEND NORMAL TEXT MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
    final text = textController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final phone = chat.phone?.toString() ?? '';

    if (phone.isEmpty) {
      return;
    }

    final tempMessageId =
        'temp_${DateTime.now().microsecondsSinceEpoch}';

    // ==========================================================
    // UI FIRST
    // ==========================================================

    whatsappController.addSentMessageToCurrentConversation(
      phone: phone,
      text: text,
      messageId: tempMessageId,
    );

    textController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        scrollToBottom();
      }
    });

    // ==========================================================
    // API
    // ==========================================================

    try {
      final response =
          await WhatsappMessageSand.sendWhatsappMessage(
        hid: whatsappController.hid,
        phone: phone,
        text: text,
      );

      debugPrint(
        'WHATSAPP SEND SUCCESS: ${response.body}',
      );

      try {
        final decoded = jsonDecode(response.body);

        final realMessageId =
            decoded['result']?['docs']?['messageId']
                ?.toString();

        debugPrint(
          'REAL MESSAGE ID: $realMessageId',
        );

        if (realMessageId != null &&
            realMessageId.isNotEmpty) {
          whatsappController.updateMessageId(
            tempId: tempMessageId,
            realId: realMessageId,
          );
        }
      } catch (e) {
        debugPrint(
          'MESSAGE ID PARSE ERROR: $e',
        );
      }
    } catch (e) {
      debugPrint(
        'SEND MESSAGE ERROR: $e',
      );
    }
  }

  // ============================================================
  // UNREAD
  // ============================================================

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

  // ============================================================
  // SCROLL
  // ============================================================

  void scrollToBottom({
    bool animated = true,
  }) {
    if (!scrollController.hasClients) {
      return;
    }

    if (animated) {
      scrollController.animateTo(
        0,
        duration: const Duration(
          milliseconds: 250,
        ),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.jumpTo(0);
    }
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _socketWorker.dispose();

    if (whatsappController.currentConversationId.value ==
        conversationId) {
      whatsappController.setCurrentConversation('');
    }

    scrollController.dispose();

    textController.dispose();

    super.onClose();
  }
}