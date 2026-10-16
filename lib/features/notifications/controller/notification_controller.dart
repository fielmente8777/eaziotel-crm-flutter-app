// ============================================================
// NOTIFICATION CONTROLLER
//
//   1. App khulte hi WhatsApp shuru: WhatsappController + socket
//      (pehle sirf WhatsApp tab kholne par judta tha)
//      Hotel badla -> purana band, naye hotel ka shuru
//   2. Socket par customer ka naya message -> notification
//        - list me jodo (Home ki ghanti par ginti)
//        - upar chhota banner (tap = wahi chat khule)
//   3. Notification par tap -> wahi WhatsApp chat khulti hai
//   4. Chat khuli -> us chat ki notifications "read"
//
// Notifications phone me save hoti hain (SharedPreferences),
// logout par SessionCleaner sab saaf kar deta hai.
// ============================================================

import 'dart:convert';

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/notifications/models/app_notification.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/whatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsapp_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  static const String _storageKey = 'app_notifications_v1';
  static const String _soundKey = 'app_notifications_sound';

  /// Itni hi purani notifications rakhte hain
  static const int _maxItems = 100;

  /// Saari notifications (sab hotels ki), nayi sabse upar
  final RxList<AppNotification> _all = <AppNotification>[].obs;

  /// Abhi chuna hua hotel
  final RxString currentHid = ''.obs;

  Worker? _hotelWorker;
  Worker? _openChatWorker;

  late final DashboardController _dashboard;

  // ============================================================
  // SOUND (naya notification aate hi phone ki default awaaz)
  // ============================================================

  /// Notification page par on / off, phone me yaad rehta hai
  final RxBool soundOn = true.obs;

  final FlutterRingtonePlayer _ringtone = FlutterRingtonePlayer();
  DateTime? _lastSoundAt;

  // ============================================================
  // GETTERS (screen + ghanti)
  // ============================================================

  /// Sirf chune hue hotel ki notifications
  List<AppNotification> get items {
    final hid = currentHid.value;
    return _all.where((n) => n.hid == hid).toList();
  }

  int get unreadCount => items.where((n) => !n.isRead).length;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _dashboard = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    _load();
    _loadSoundSetting();

    // Hotel id baad me aata hai (getUser) aur badal bhi sakta hai
    _hotelWorker = ever<String>(_dashboard.selectedHotelId, _startWhatsapp);
    _startWhatsapp(_dashboard.selectedHotelId.value);
  }

  @override
  void onClose() {
    _hotelWorker?.dispose();
    _openChatWorker?.dispose();

    if (Get.isRegistered<WhatsappController>()) {
      Get.find<WhatsappController>().onIncomingMessage = null;
    }

    super.onClose();
  }

  // ============================================================
  // 1. WHATSAPP + SOCKET (app khulte hi)
  // ============================================================

  void _startWhatsapp(String rawHid) {
    final hid = rawHid.trim();

    // Hotel abhi nahi aaya (ya save hi nahi tha)
    if (hid.isEmpty || hid == 'null') return;

    currentHid.value = hid;

    if (Get.isRegistered<WhatsappController>()) {
      final current = Get.find<WhatsappController>();

      // Wahi hotel: bas jod do
      if (current.hid == hid) {
        _attach(current);
        return;
      }

      // Hotel badla: purana controller + socket band
      Get.delete<WhatsappController>(force: true);
    }

    // Naya controller: conversations + socket turant shuru (onInit me)
    final whatsapp = Get.put(WhatsappController(hid: hid), permanent: true);
    _attach(whatsapp);
  }

  void _attach(WhatsappController whatsapp) {
    whatsapp.onIncomingMessage = _onWhatsappMessage;

    // Koi chat khuli -> us chat ki notifications padh li gayi
    _openChatWorker?.dispose();
    _openChatWorker = ever<String>(whatsapp.currentConversationId, (id) {
      if (id.isNotEmpty) markConversationRead(id);
    });
  }

  // ============================================================
  // 2. NAYA MESSAGE -> NOTIFICATION
  // ============================================================

  void _onWhatsappMessage(
    WhatsappConversationModel chat,
    WhatsappSocketMessageModel message,
  ) {
    final id = message.messageId ?? message.id ?? '';
    if (id.isEmpty || _all.any((n) => n.id == id)) return;

    final name = chat.name?.trim().isNotEmpty == true
        ? chat.name!.trim()
        : (message.name?.trim().isNotEmpty == true
              ? message.name!.trim()
              : chat.phone);

    final notification = AppNotification(
      id: id,
      type: AppNotificationType.whatsapp,
      hid: chat.hid.isNotEmpty ? chat.hid : currentHid.value,
      conversationId: chat.id,
      title: name,
      body: previewText(message.messageType, message.body),
      phone: chat.phone,
      createdAt:
          DateTime.tryParse(message.createdAt ?? '')?.toLocal() ??
          DateTime.now(),
    );

    _all.insert(0, notification);
    if (_all.length > _maxItems) _all.removeRange(_maxItems, _all.length);

    _save();
    _showBanner(notification);
    _playSound();
  }

  /// Message ka chhota text (photo / video ... ke liye label)
  static String previewText(String? type, String? body) {
    final text = body?.trim() ?? '';

    switch (type?.toLowerCase()) {
      case 'image':
        return text.isEmpty ? '📷 Photo' : '📷 $text';
      case 'video':
        return text.isEmpty ? '🎥 Video' : '🎥 $text';
      case 'audio':
      case 'voice':
        return '🎤 Voice message';
      case 'document':
        return text.isEmpty ? '📄 Document' : '📄 $text';
      case 'location':
        return '📍 Location';
      case 'sticker':
        return 'Sticker';
      case 'contacts':
        return '👤 Contact';
    }

    return text.isEmpty ? 'New message' : text;
  }

  // ============================================================
  // SOUND
  // ============================================================

  /// Phone ki apni (default) notification awaaz:
  ///   Android : Settings me chuni hui notification tone
  ///   iOS     : system ki notification awaaz
  ///   Windows / baaki : system alert
  /// Phone silent / vibrate par ho to system khud awaaz nahi bajata.
  Future<void> _playSound() async {
    if (!soundOn.value) return;

    // Ek saath bahut message aaye to baar baar nahi bajta
    final now = DateTime.now();
    if (_lastSoundAt != null &&
        now.difference(_lastSoundAt!) < const Duration(milliseconds: 1500)) {
      return;
    }
    _lastSoundAt = now;

    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        await _ringtone.playNotification(looping: false, asAlarm: false);
      } else {
        await SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('NOTIFICATION SOUND ERROR: $e');
    }
  }

  Future<void> toggleSound() async {
    soundOn.value = !soundOn.value;

    // On karte hi ek baar suna do
    if (soundOn.value) {
      _lastSoundAt = null;
      _playSound();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundKey, soundOn.value);
    } catch (e) {
      debugPrint('NOTIFICATION SOUND SAVE ERROR: $e');
    }
  }

  Future<void> _loadSoundSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      soundOn.value = prefs.getBool(_soundKey) ?? true;
    } catch (_) {}
  }

  // ============================================================
  // BANNER (app ke upar chhota sa)
  // ============================================================

  void _showBanner(AppNotification n) {
    final context = Get.context;
    if (context == null) return;

    final p = WaPalette(context);

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        borderRadius: 16,
        backgroundColor: p.card,
        borderColor: p.border,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: p.isDark ? .4 : .12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        maxWidth: 520,
        icon: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: WaAvatar(name: n.title, size: 38),
        ),
        titleText: Row(
          children: [
            const Icon(Icons.chat_rounded, size: 13, color: WaPalette.green),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                n.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        messageText: Text(
          n.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: p.subText, fontSize: 13),
        ),
        onTap: (_) {
          Get.closeCurrentSnackbar();
          open(n);
        },
      ),
    );
  }

  // ============================================================
  // 3. TAP -> CHAT KHOLO
  // ============================================================

  void open(AppNotification n) {
    n.isRead = true;
    _all.refresh();
    _save();

    if (!Get.isRegistered<WhatsappController>()) return;

    final whatsapp = Get.find<WhatsappController>();
    final chat = whatsapp.conversations.firstWhereOrNull(
      (c) => c.id == n.conversationId,
    );

    if (chat == null) {
      Get.snackbar(
        'Chat not found',
        'This conversation is no longer available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Wahi kaam jo WhatsApp list me chat par tap karne se hota hai
    whatsapp.getConversationMessages(conversationId: chat.id);
    whatsapp.markConversationAsReadLocally(chat.id);

    Get.to(
      () => WhatsappConversationMesseg(
        chat: chat,
        whatsapptemplate: whatsapp.templateController,
      ),
    );
  }

  // ============================================================
  // 4. READ / CLEAR
  // ============================================================

  void markConversationRead(String conversationId) {
    var changed = false;

    for (final n in _all) {
      if (n.conversationId == conversationId && !n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }

    if (changed) {
      _all.refresh();
      _save();
    }
  }

  void markAllRead() {
    for (final n in items) {
      n.isRead = true;
    }
    _all.refresh();
    _save();
  }

  void remove(AppNotification n) {
    _all.remove(n);
    _save();
  }

  void clearAll() {
    final hid = currentHid.value;
    _all.removeWhere((n) => n.hid == hid);
    _save();
  }

  // ============================================================
  // SAVE / LOAD (phone me)
  // ============================================================

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;

      final list = jsonDecode(raw);
      if (list is! List) return;

      final saved = list
          .whereType<Map>()
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .where((n) => n.id.isNotEmpty)
          .toList();

      // Load hote hote socket se jo aa gayi, wo bhi rakho
      final ids = _all.map((n) => n.id).toSet();
      _all.addAll(saved.where((n) => !ids.contains(n.id)));
    } catch (e) {
      debugPrint('NOTIFICATIONS LOAD ERROR: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(_all.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('NOTIFICATIONS SAVE ERROR: $e');
    }
  }
}
