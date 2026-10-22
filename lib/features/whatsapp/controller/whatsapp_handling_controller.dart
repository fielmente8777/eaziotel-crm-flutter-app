// ============================================================
// WHATSAPP HANDLING CONTROLLER  (ek khuli chat: kaun reply karega)
//
// Web dashboard (ChatPanel) jaisa:
//   AI on + koi aur team member reply kar raha  -> "A teammate is replying"
//   AI on + AI reply kar raha                   -> "The AI is replying" [Take over]
//   automated flow (form) chal raha             -> "An automated flow..." [Take over]
//   warna                                       -> message box
//                                                  (+ "Hand back to AI" agar maine liya)
//
// Har chat ka apna controller (tag = conversation id).
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
  /// Abhi pata nahi (load ho raha hai)
  loading,

  /// AI reply kar raha hai -> Take over
  ai,

  /// Koi aur team member reply kar raha hai -> likh nahi sakte
  teammate,

  /// Automated flow (form) chal raha hai -> Take over
  flow,

  /// Main reply kar raha hoon (AI on hai to "Hand back to AI" bhi)
  me,

  /// AI band hai: sab likh sakte hain
  open,
}

class WhatsappHandlingController extends GetxController {
  WhatsappHandlingController({required this.chat});

  final WhatsappConversationModel chat;

  /// AI on / off: pichhla jawab (chat khulte hi turant dikhe), par har
  /// baar server se dobara poochte hain (Settings me badla ho sakta hai)
  static final Map<String, bool> _aiCache = {};

  /// Login kiye hue user ka email (/user/user-details), ek baar hi laate hain
  static String _myEmail = '';

  final WhatsappController whatsapp = Get.find<WhatsappController>();

  final RxBool isLoading = true.obs;
  final RxBool aiEnabled = false.obs;
  final RxBool flowActive = false.obs;

  /// Take over / hand back / stop flow chal raha hai
  final RxBool isChanging = false.obs;

  /// Server se mila naya handling (list wala purana ho sakta hai)
  final Rxn<WhatsappHandlingModel> _handling = Rxn<WhatsappHandlingModel>();

  // ============================================================
  // GETTERS
  // ============================================================

  String get userEmail {
    if (_myEmail.isNotEmpty) return _myEmail;
    if (!Get.isRegistered<DashboardController>()) return '';

    // App khulte hi aaya hua login user (user-details)
    final authEmail =
        Get.find<DashboardController>().authUser.value?.email ?? '';
    if (authEmail.isNotEmpty) return authEmail;
    return Get.find<DashboardController>().user.value?.userEmail ?? '';
  }

  /// Sabse taaza handling: pehle mera badla hua, phir list wala, phir chat ka
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
    // "AI" / "ai" / "HUMAN" / "human" sab chalein
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

    // Pehle pichhla jawab (agar hai), phir server ka taaza
    if (_aiCache.containsKey(hid)) aiEnabled.value = _aiCache[hid]!;

    try {
      final enabled = await WhatsappHandlingService.isAiEnabled(hid: hid);
      _aiCache[hid] = enabled;
      aiEnabled.value = enabled;
    } catch (_) {
      // Pata na chale to pichhla jawab rakho, woh bhi na ho to AI band
      aiEnabled.value = _aiCache[hid] ?? false;
    }
  }

  Future<void> _loadEmail() async {
    if (_myEmail.isNotEmpty) return;

    try {
      _myEmail = await WhatsappHandlingService.getMyEmail();
    } catch (_) {
      // Take over dabane par dobara koshish hogi
    }
  }

  /// Is chat ka TAAZA handling (AI ya kaun insaan) server se.
  /// App me chat list app khulne par ek baar aati hai; tab se web par
  /// kisi ne take over / hand back kiya ho to purana dikhta tha.
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

  /// Logout par (naya user = naya email) aur AI setting badalne par
  static void clearCache() {
    _aiCache.clear();
    _myEmail = '';
  }

  // ============================================================
  // TAKE OVER (AI se)
  // ============================================================

  Future<void> takeOver() async {
    // Email abhi tak nahi aaya to ek baar aur laao
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
  // TAKE OVER (automated flow se)
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

    // Chat list me bhi wahi dikhe
    whatsapp.setConversationHandling(chat.id, value);
  }

  /// Server ka message (ho to), warna [fallback]
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
