import 'dart:convert';
import 'dart:io';

import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/whatsapp/services/markConversationAsRead.dart';
import 'package:eazotel/features/whatsapp/services/whatsappMessegSand.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
import 'package:image_picker/image_picker.dart';

class WhatsappConversationDetailController extends GetxController {
  final dynamic chat;

  final WhatsappController whatsappController;

  WhatsappConversationDetailController({
    required this.chat,
    required this.whatsappController,
  });

  // ============================================================
  // ATTACHMENT (GALLERY / IMAGE UPLOAD)
  // ============================================================

  final ImagePicker _picker = ImagePicker();
  final Rx<File?> pickedImage = Rx<File?>(null);
  final RxBool isUploading = false.obs;

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
  // FLOW SENDING
  // ============================================================

  final RxBool isFlowSending = false.obs;

  // ============================================================
  // SOCKET WORKER
  // ============================================================

  late Worker _socketWorker;

  // ============================================================
  // GETTERS
  // ============================================================

  String get conversationId => chat.id ?? '';

  int get totalUnreadCount => initialUnreadCount.value + newIncomingCount.value;

  // ============================================================
  // SAFE MESSAGE (snackbar crash na ho)
  // ============================================================

  void _showMessage(String title, String message) {
    try {
      if (Get.overlayContext != null) {
        Get.snackbar(title, message);
      } else {
        debugPrint('$title: $message');
      }
    } catch (e) {
      debugPrint('SNACKBAR ERROR: $e | $title: $message');
    }
  }

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

    selectedTemplateParamsHeader.assignAll(templateParamsHeader);

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

      _showMessage('Error', 'Customer phone number not found');

      return false;
    }

    final finalTemplateName = templateName?.trim().isNotEmpty == true
        ? templateName!.trim()
        : selectedTemplateName.value.trim();

    if (finalTemplateName.isEmpty) {
      debugPrint('TEMPLATE SEND: TEMPLATE NAME EMPTY');

      _showMessage('Error', 'Please select a WhatsApp template');

      return false;
    }

    final finalLanguage = templateLanguage?.trim().isNotEmpty == true
        ? templateLanguage!.trim()
        : selectedTemplateLanguage.value.trim();

    final finalParams = templateParams ?? selectedTemplateParams.toList();

    final finalHeaderParams =
        templateParamsHeader ?? selectedTemplateParamsHeader.toList();

    final finalPreview = preview ?? selectedTemplatePreview.value;

    isTemplateSending.value = true;

    final tempMessageId =
        'temp_template_${DateTime.now().microsecondsSinceEpoch}';

    // LOCAL UI FIRST
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

    // API CALL
    try {
      final response = await WhatsappMessageSand.sendWhatsappTemplate(
        hid: whatsappController.hid,
        phone: phone,
        templateName: finalTemplateName,
        templateLanguage: finalLanguage,
        templateParams: finalParams,
        templateParamsHeader: finalHeaderParams,
      );

      debugPrint('TEMPLATE SEND SUCCESS: ${response.body}');

      try {
        final decoded = jsonDecode(response.body);

        final realMessageId = decoded['result']?['docs']?['messageId']
            ?.toString();

        debugPrint('TEMPLATE REAL MESSAGE ID: $realMessageId');

        // TEMP ID -> REAL ID
        if (realMessageId != null && realMessageId.isNotEmpty) {
          whatsappController.updateMessageId(
            tempId: tempMessageId,
            realId: realMessageId,
          );
        }
      } catch (e) {
        debugPrint('TEMPLATE RESPONSE PARSE ERROR: $e');
      }

      clearSelectedTemplate();

      return true;
    } catch (e, stackTrace) {
      debugPrint('TEMPLATE SEND ERROR: $e');

      debugPrintStack(stackTrace: stackTrace);

      return false;
    } finally {
      isTemplateSending.value = false;
    }
  }

  // ============================================================
  // SEND FLOW MESSAGE
  // (local list update + API + temp id -> real id
  //  WhatsappController.sendFlowMessage me hota hai)
  // ============================================================

  Future<bool> sendFlowMessage({
    required String flowId,
    required String body,
    String header = '',
    String footer = '',
    String ctaText = 'Fill Details',
  }) async {
    if (isFlowSending.value) return false;

    final phone = chat.phone?.toString().trim() ?? '';

    if (phone.isEmpty) {
      _showMessage('Error', 'Customer phone number not found');
      return false;
    }

    if (flowId.trim().isEmpty) {
      _showMessage('Error', 'Please select a flow');
      return false;
    }

    if (body.trim().isEmpty) {
      _showMessage('Error', 'Flow message body is required');
      return false;
    }

    isFlowSending.value = true;

    try {
      final ok = await whatsappController.sendFlowMessage(
        conversationId: conversationId,
        phone: phone,
        flowId: flowId,
        body: body,
        header: header,
        footer: footer,
        ctaText: ctaText,
      );

      if (ok) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isClosed) scrollToBottom();
        });
      } else {
        _showMessage('Error', 'Flow send nahi hua, dobara try karein');
      }

      return ok;
    } finally {
      isFlowSending.value = false;
    }
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  Future<void> markConversationAsRead() async {
    try {
      final id = chat.id?.toString() ?? '';

      if (id.isEmpty) {
        debugPrint('❌ Conversation ID is empty');
        return;
      }

      isMarkingAsRead.value = true;

      final response = await MarkConversationAsRead.markConversationAsRead(
        conversationId: id,
      );

      debugPrint('📥 MARK AS READ RESPONSE: ${response.body}');

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        markAsReadResponse.value = decoded;

        debugPrint('✅ MARK AS READ SUCCESS: ${decoded['success']}');

        if (decoded['success'] == true) {
          clearUnread();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Mark conversation as read failed: $e');

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isMarkingAsRead.value = false;
    }
  }

  // ============================================================
  // GALLERY PICK
  // (Android Photo Picker use hota hai, isliye storage permission
  //  manifest me daalne ki zarurat nahi)
  // ============================================================

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (x == null) return;

      pickedImage.value = File(x.path);
    } catch (e, st) {
      debugPrint('PICK IMAGE ERROR: $e');
      debugPrintStack(stackTrace: st);

      _showMessage('Error', 'Image select nahi ho payi');
    }
  }

  // ============================================================
  // LOCATION (permission + send as Google Maps link)
  // ============================================================

  Future<void> pickCurrentLocation() async {
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();

      if (!serviceOn) {
        _showMessage('Location off', 'Please GPS on karein');

        await Geolocator.openLocationSettings();

        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showMessage('Permission', 'Location permission chahiye');

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Permission',
          'Settings se location permission allow karein',
        );

        await Geolocator.openAppSettings();

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final link =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      await _sendText('📍 My location\n$link');
    } catch (e) {
      debugPrint('LOCATION ERROR: $e');

      _showMessage('Error', 'Location nahi mil paayi');
    }
  }

  // ============================================================
  // IMAGE CACHE HELPERS
  // WhatsappMediaController ye file naam expect karta hai:
  //   <documents>/whatsapp_image_<safeMessageId>.<ext>
  // ============================================================

  Future<File> _cachedImageFile(String messageId, String extension) async {
    final dir = await getApplicationDocumentsDirectory();

    final safeId = (messageId.isEmpty ? 'unknown' : messageId).replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );

    return File('${dir.path}/whatsapp_image_$safeId.$extension');
  }

  String _imageExtension(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';

    return 'jpg';
  }

  String _mimeFromExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ============================================================
  // SEND PICKED IMAGE
  // ============================================================

  Future<void> _sendPickedImage() async {
    final file = pickedImage.value;

    if (file == null) return;

    final phone = chat.phone?.toString().trim() ?? '';

    if (phone.isEmpty) {
      _showMessage('Error', 'Customer phone number not found');

      return;
    }

    final caption = textController.text.trim();

    final extension = _imageExtension(file.path);

    final mimeType = _mimeFromExtension(extension);

    final tempMessageId = 'temp_img_${DateTime.now().microsecondsSinceEpoch}';

    isUploading.value = true;

    File? cachedFile;

    try {
      // 1) Image ko app storage me copy karo (temp id ke naam se)
      final target = await _cachedImageFile(tempMessageId, extension);

      cachedFile = await file.copy(target.path);

      // 2) Turant chat me dikhao (WhatsApp jaisa)
      whatsappController.addSentMessageToCurrentConversation(
        phone: phone,
        text: caption.isNotEmpty ? caption : '📷 Photo',
        messageId: tempMessageId,
        messageType: 'image',
        caption: caption,
        media: {'id': tempMessageId, 'mimeType': mimeType},
      );

      pickedImage.value = null;

      textController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          scrollToBottom();
        }
      });

      // 3) Server par upload
      final response = await WhatsappMessageSand.sendWhatsappImage(
        hid: whatsappController.hid,
        phone: phone,
        file: file,
        caption: caption,
      );

      debugPrint('IMAGE SEND SUCCESS: ${response.body}');

      // 4) Real message id mila -> file rename, phir id replace
      String? realMessageId;

      try {
        final decoded = jsonDecode(response.body);

        realMessageId = decoded['result']?['docs']?['messageId']?.toString();
      } catch (e) {
        debugPrint('IMAGE RESPONSE PARSE ERROR: $e');
      }

      if (realMessageId != null && realMessageId.isNotEmpty) {
        try {
          final realFile = await _cachedImageFile(realMessageId, extension);

          if (await realFile.exists()) {
            await realFile.delete();
          }

          await cachedFile.rename(realFile.path);
        } catch (e) {
          debugPrint('IMAGE CACHE RENAME ERROR: $e');
        }

        whatsappController.updateMessageId(
          tempId: tempMessageId,
          realId: realMessageId,
        );
      }
    } catch (e, st) {
      debugPrint('IMAGE SEND ERROR: $e');
      debugPrintStack(stackTrace: st);

      // Fail hua -> chat se message hatao, image wapas preview me
      try {
        await whatsappController.deleteMessages([tempMessageId]);
      } catch (_) {}

      try {
        if (cachedFile != null && await cachedFile.exists()) {
          await cachedFile.delete();
        }
      } catch (_) {}

      pickedImage.value = file;

      if (caption.isNotEmpty) {
        textController.text = caption;
      }

      final message = e is ApiException
          ? e.message
          : 'Image send nahi hui, dobara try karein';

      _showMessage('Error', message);
    } finally {
      isUploading.value = false;
    }
  }

  // ============================================================
  // SEND BUTTON HANDLER (image ho to image, warna text)
  // ============================================================

  Future<void> sendMessage() async {
    if (isUploading.value) return;

    if (pickedImage.value != null) {
      await _sendPickedImage();

      return;
    }

    final text = textController.text.trim();

    if (text.isEmpty) {
      return;
    }

    textController.clear();

    await _sendText(text);
  }

  // ============================================================
  // SEND NORMAL TEXT MESSAGE
  // ============================================================

  Future<void> _sendText(String text) async {
    final phone = chat.phone?.toString() ?? '';

    if (phone.isEmpty) {
      return;
    }

    final tempMessageId = 'temp_${DateTime.now().microsecondsSinceEpoch}';

    // UI FIRST
    whatsappController.addSentMessageToCurrentConversation(
      phone: phone,
      text: text,
      messageId: tempMessageId,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        scrollToBottom();
      }
    });

    // API
    try {
      final response = await WhatsappMessageSand.sendWhatsappMessage(
        hid: whatsappController.hid,
        phone: phone,
        text: text,
      );

      debugPrint('WHATSAPP SEND SUCCESS: ${response.body}');

      try {
        final decoded = jsonDecode(response.body);

        final realMessageId = decoded['result']?['docs']?['messageId']
            ?.toString();

        debugPrint('REAL MESSAGE ID: $realMessageId');

        if (realMessageId != null && realMessageId.isNotEmpty) {
          whatsappController.updateMessageId(
            tempId: tempMessageId,
            realId: realMessageId,
          );
        }
      } catch (e) {
        debugPrint('MESSAGE ID PARSE ERROR: $e');
      }
    } catch (e) {
      debugPrint('SEND MESSAGE ERROR: $e');
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

  // ============================================================
  // CLOSE
  // ============================================================

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