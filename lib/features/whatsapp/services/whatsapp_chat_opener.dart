import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/screen/whatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/addcontect/addContect.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Kisi bhi page (Calls, Lead details ...) se phone number ki
/// app ke andar wali WhatsApp chat kholne ke liye.
///
/// - Number ki conversation mil gayi  -> chat page
/// - Nahi mili                        -> Add Contact sheet (number bhara hua)
class WhatsappChatOpener {
  WhatsappChatOpener._();

  static bool _busy = false;

  /// Kitni khuli chat / sheet humare banaye WhatsappController par chal rahi hain
  static int _openCount = 0;
  static bool _ownsController = false;

  static String _last10(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  static void _message(String text) {
    Get.snackbar('WhatsApp', text, snackPosition: SnackPosition.BOTTOM);
  }

  static Future<void> open(
    BuildContext context, {
    required String phone,
    required String hid,
    VoidCallback? onLoaded,
  }) async {
    final number = _last10(phone);

    if (_busy) return;

    if (number.isEmpty) {
      _message('Phone number is not available');
      return;
    }

    if (hid.isEmpty) {
      _message('No hotel selected');
      return;
    }

    _busy = true;
    _openCount++;

    try {
      // WhatsApp tab khula nahi hai to controller yahin banao
      if (!Get.isRegistered<WhatsappController>()) {
        Get.put<WhatsappController>(WhatsappController(hid: hid));
        _ownsController = true;
      }

      final whatsapp = Get.find<WhatsappController>();

      if (whatsapp.whatsappIntegration.value == null) {
        await whatsapp.getWhatsappIntegration();
      }

      if (!whatsapp.whatsappIntegrationSuccess) {
        _message('WhatsApp is not connected for this hotel.');
        return;
      }

      if (whatsapp.conversations.isEmpty) {
        await whatsapp.getConversations();
      }

      if (!context.mounted) return;

      final chat = whatsapp.conversations.firstWhereOrNull(
        (c) => _last10(c.phone) == number,
      );

      _busy = false;
      onLoaded?.call();

      // Conversation nahi hai -> template bhej kar shuru karo
      if (chat == null) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddContect(initialPhone: phone),
        );
        return;
      }

      whatsapp.getConversationMessages(conversationId: chat.id);
      whatsapp.markConversationAsReadLocally(chat.id);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WhatsappConversationMesseg(
            chat: chat,
            whatsapptemplate: whatsapp.templateController,
          ),
        ),
      );
    } catch (e) {
      debugPrint('WHATSAPP CHAT OPEN ERROR: $e');

      _message('Unable to open the WhatsApp chat');
    } finally {
      _busy = false;
      _openCount--;
      onLoaded?.call();

      _releaseController();
    }
  }

  /// Chat / sheet band hone ke baad humara banaya controller hata do,
  /// warna hotel badalne par WhatsApp tab purana data dikhayega.
  static Future<void> _releaseController() async {
    if (!_ownsController || _openCount > 0) return;

    // Page band hone ki animation poori hone do
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!_ownsController || _openCount > 0) return;

    _ownsController = false;

    if (Get.isRegistered<WhatsappController>()) {
      Get.delete<WhatsappController>();
    }
  }
}
