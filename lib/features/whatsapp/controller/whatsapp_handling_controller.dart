// ============================================================
// WHATSAPP HANDLING CONTROLLER  (one open chat: who will reply)
//
// Same as the web dashboard (ChatPanel):
//   AI on + another team member is replying  -> "A teammate is replying"
//   AI on + AI is replying                   -> "The AI is replying" [Take over]
//   an automated flow (form) is running        -> "An automated flow..." [Take over]
//   otherwise                                -> message box
//                                                  (+ "Hand back to AI" if I took over)
//
// Each chat has its own controller (tag = conversation id).
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/setting_screen/whatsapp/models/whatsapp_action_response.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/services/whatsappConversation.dart';
import 'package:eazotel/features/whatsapp/services/whatsapp_handling_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum WaReplyMode {
  /// Not known yet (loading)
  loading,

  /// AI is replying -> Take over
  ai,

  /// Another team member is replying -> cannot type
  teammate,

  /// An automated flow (form) is running -> Take over
  flow,

  /// I am replying ("Hand back to AI" too if AI is on)
  me,

  /// AI is off: everyone can type
  open,
}

class WhatsappHandlingController extends GetxController {
  WhatsappHandlingController({required this.chat});

  final WhatsappConversationModel chat;

  /// AI on / off: the previous answer (shows right away when the chat opens), but
  /// each time we ask the server again (it may have changed in Settings)
  static final Map<String, bool> _aiCache = {};

  /// Email of the logged-in user (/user/user-details), fetched only once
  static String _myEmail = '';

  final WhatsappController whatsapp = Get.find<WhatsappController>();

  final RxBool isLoading = true.obs;
  final RxBool aiEnabled = false.obs;
  final RxBool flowActive = false.obs;

  /// Take over / hand back / stop flow is running
  final RxBool isChanging = false.obs;

  /// Fresh handling from the server (the list's one can be old)
  final Rxn<WhatsappHandlingModel> _handling = Rxn<WhatsappHandlingModel>();

  // ============================================================
  // GETTERS
  // ============================================================

  String get userEmail {
    if (_myEmail.isNotEmpty) return _myEmail;
    if (!Get.isRegistered<DashboardController>()) return '';

    // The logged-in user loaded when the app opened (user-details)
    final authEmail =
        Get.find<DashboardController>().authUser.value?.email ?? '';
    if (authEmail.isNotEmpty) return authEmail;
    return Get.find<DashboardController>().user.value?.userEmail ?? '';
  }

  /// The freshest handling: my change first, then the list's, then the chat's
  WhatsappHandlingModel? get handling {
    if (_handling.value != null) return _handling.value;

    final latest = whatsapp.conversations.firstWhereOrNull(
      (c) => c.id == chat.id,
    );
    return latest?.handling ?? chat.handling;
  }

  WaReplyMode get mode {
    if (isLoading.value) return WaReplyMode.loading;

    final h = handling;
    // "AI" / "ai" / "HUMAN" / "human" all work
    final handlingMode = (h?.mode ?? '').trim().toUpperCase();
    final byHuman = handlingMode == 'HUMAN';
    final byAi = !byHuman;
    final mine =
        (h?.assignedTo ?? '').trim().toLowerCase() ==
        userEmail.trim().toLowerCase();

    if (aiEnabled.value && byHuman && !mine) return WaReplyMode.teammate;
    if (aiEnabled.value && byAi) return WaReplyMode.ai;
    if (flowActive.value) return WaReplyMode.flow;
    if (aiEnabled.value && byHuman && mine) return WaReplyMode.me;
    return WaReplyMode.open;
  }

  // ============================================================
  // LOAD
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;

    try {
      await Future.wait([
        _loadAi(),
        _loadFlow(),
        _loadEmail(),
        _loadHandling(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAi() async {
    final hid = whatsapp.hid;

    // The previous answer first (if any), then the server's fresh one
    if (_aiCache.containsKey(hid)) aiEnabled.value = _aiCache[hid]!;

    try {
      final enabled = await WhatsappHandlingService.isAiEnabled(hid: hid);
      _aiCache[hid] = enabled;
      aiEnabled.value = enabled;
    } catch (_) {
      // If unknown, keep the previous answer; if there is none, AI off
      aiEnabled.value = _aiCache[hid] ?? false;
    }
  }

  Future<void> _loadEmail() async {
    if (_myEmail.isNotEmpty) return;

    try {
      _myEmail = await WhatsappHandlingService.getMyEmail();
    } catch (_) {
      // It will try again when Take over is pressed
    }
  }

  /// This chat's FRESH handling (AI or which person) from the server.
  /// In the app the chat list loads once when the app opens; since then, if
  /// someone took over / handed back on the web, the old state showed.
  Future<void> _loadHandling() async {
    try {
      final json = await WhatsappService.getConversations(hid: whatsapp.hid);
      final result = json['result'];
      final list = result is Map ? result['conversations'] : null;
      if (list is! List) return;

      for (final item in list) {
        if (item is! Map || '${item['_id']}' != chat.id) continue;

        final raw = item['handling'];
        final fresh = raw is Map
            ? WhatsappHandlingModel.fromJson(Map<String, dynamic>.from(raw))
            : WhatsappHandlingModel(mode: 'AI');

        _setHandling(fresh);
        return;
      }
    } catch (e) {
      debugPrint('HANDLING REFRESH ERROR: $e');
    }
  }

  Future<void> _loadFlow() async {
    if (chat.ndid.isEmpty || chat.phone.isEmpty) return;

    try {
      flowActive.value = await WhatsappHandlingService.isFlowActive(
        hid: whatsapp.hid,
        ndid: chat.ndid,
        phone: chat.phone,
      );
    } catch (_) {
      flowActive.value = false;
    }
  }

  /// On logout (new user = new email) and when the AI setting changes
  static void clearCache() {
    _aiCache.clear();
    _myEmail = '';
  }

  // ============================================================
  // TAKE OVER (from AI)
  // ============================================================

  Future<void> takeOver() async {
    // If the email has not come yet, fetch it once more
    if (userEmail.isEmpty) {
      isChanging.value = true;
      await _loadEmail();
      isChanging.value = false;
    }

    final email = userEmail;

    if (email.isEmpty) {
      _toast(
        'Could not take over',
        'Your account email was not found. Please log in again.',
        error: true,
      );
      return;
    }

    isChanging.value = true;

    try {
      final result = await WhatsappHandlingService.takeOver(
        conversationId: chat.id,
        userEmail: email,
      );

      _setHandling(
        result ?? WhatsappHandlingModel(mode: 'HUMAN', assignedTo: email),
      );

      _toast(
        'You are replying now',
        'The AI will stop replying to this guest.',
      );
    } catch (e) {
      _toast(
        'Could not take over',
        _errorText(e, 'Someone else may already be replying.'),
        error: true,
      );
    } finally {
      isChanging.value = false;
    }
  }

  // ============================================================
  // HAND BACK TO AI
  // ============================================================

  Future<void> handBack(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hand back to AI?'),
        content: const Text('The AI will resume replying to this guest.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hand back'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    isChanging.value = true;

    try {
      final result = await WhatsappHandlingService.handBack(
        conversationId: chat.id,
        userEmail: userEmail,
      );

      _setHandling(result ?? WhatsappHandlingModel(mode: 'AI'));

      _toast('Handed back to AI', 'The AI will reply to this guest now.');
    } catch (e) {
      _toast(
        'Could not hand back',
        _errorText(e, 'Please try again.'),
        error: true,
      );
    } finally {
      isChanging.value = false;
    }
  }

  // ============================================================
  // TAKE OVER (from an automated flow)
  // ============================================================

  Future<void> stopFlow() async {
    isChanging.value = true;

    try {
      await WhatsappHandlingService.stopFlow(
        hid: whatsapp.hid,
        ndid: chat.ndid,
        phone: chat.phone,
      );

      await _loadFlow();

      if (!flowActive.value) {
        _toast('You can reply now', 'The automated flow has been stopped.');
      }
    } catch (e) {
      _toast(
        'Could not take over',
        _errorText(e, 'Could not stop the automated flow.'),
        error: true,
      );
    } finally {
      isChanging.value = false;
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _setHandling(WhatsappHandlingModel value) {
    _handling.value = value;

    // Show the same in the chat list too
    whatsapp.setConversationHandling(chat.id, value);
  }

  /// The server's message (if any), otherwise [fallback]
  String _errorText(Object e, String fallback) =>
      WhatsappActionResponse.errorOf(e, fallback);

  void _toast(String title, String message, {bool error = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      backgroundColor: error
          ? const Color(0xFFEF4444)
          : const Color(0xFF008069),
      colorText: Colors.white,
    );
  }
}
