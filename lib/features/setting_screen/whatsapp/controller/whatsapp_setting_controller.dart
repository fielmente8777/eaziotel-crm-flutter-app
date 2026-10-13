// ============================================================
// WHATSAPP SETTING CONTROLLER
//
// Settings > WhatsApp tab ka "dimaag".
//
//   Screen (widgets)  --->  ye controller  --->  WhatsappSettingService  --->  API
//   (templates ke liye WhatsApp feature ki WhatsappTemaplate service)
//
// Is file me 5 hisse hain:
//   1. DATA LOAD        : tab khulte hi server se data lana
//   2. AUTO MESSAGE     : switch / dropdown badalna
//   3. PROFILE EDIT     : business profile badalna (Edit / Save / Cancel)
//   4. AI CONFIGURATION : AI ka switch aur time
//   5. WIDGET CODE      : website me lagane wala code
//   6. BUTTONS          : jin buttons ki API abhi nahi mili
// ============================================================

import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:eazotel/features/whatsapp/services/whatsappTemplate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/auto_message_config.dart';
import '../models/whatsapp_account_info.dart';
import '../models/whatsapp_widget_code.dart';
import '../services/whatsapp_setting_service.dart';

/// WhatsApp tab ke andar ka menu (left side / upar ke chips)
enum WhatsappSettingMenu {
  overview('Overview'),
  messageTemplates('Message Templates'),
  autoMessage('Auto Message'),
  flows('Flows'),
  whatsappFlow('WhatsApp Flow'),
  quickReplies('Quick Replies'),
  creditsUsage('Credits & Usage');

  const WhatsappSettingMenu(this.label);

  /// Screen par dikhne wala naam
  final String label;
}

class WhatsappSettingController extends GetxController {
  /// Hotel id aur ndid dashboard se milte hain
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  String get ndid => dashboard.user.value?.profile.ndid ?? '';

  /// Andar ke menu me abhi kaunsa item chuna hai
  final selectedMenu = WhatsappSettingMenu.overview.obs;

  // ============================================================
  // 1. DATA LOAD
  // ============================================================

  /// true = data aa raha hai (screen par shimmer dikhta hai)
  final isLoading = true.obs;

  /// null = sab theek. Text ho to poori screen par wahi message dikhta hai.
  final errorMessage = RxnString();

  /// Account, phone number aur business profile ki jaankari
  final info = const WhatsappAccountInfo().obs;

  /// Hotel ke WhatsApp templates
  final templates = <WhatsappTemplate>[].obs;

  /// Chatbot flow ki id (auto message ke "Flow" dropdown ke liye)
  final flowIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    load();
  }

  /// Tab khulne par, Retry par aur neeche kheechne (refresh) par chalta hai.
  ///
  ///   Step 1: WhatsApp juda hai ya nahi  (nahi -> message dikha kar ruk jao)
  ///   Step 2: baaki data saath me lao    (account, templates, flow)
  Future<void> load() async {
    if (hid.isEmpty) {
      errorMessage.value = 'No hotel selected';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    // ---------- Step 1 ----------
    try {
      final connected = await WhatsappSettingService.isWhatsappConnected(
        hid: hid,
      );

      if (!connected) {
        errorMessage.value = 'WhatsApp is not connected for this hotel.';
        isLoading.value = false;
        return;
      }
    } catch (e) {
      debugPrint('WHATSAPP SETTING: connection check error: $e');

      errorMessage.value =
          'Unable to load WhatsApp settings. Please try again.';
      isLoading.value = false;
      return;
    }

    // ---------- Step 2 ----------
    // Teeno saath me chalte hain. Ek fail ho to baaki do phir bhi dikhen.
    await Future.wait([_loadAccount(), _loadTemplates(), _loadFlowIds()]);

    isLoading.value = false;
  }

  /// Account, phone, business profile + auto message aur AI ki saved setting
  Future<void> _loadAccount() async {
    try {
      // Dono API saath me chalti hain
      final detailsRequest = WhatsappSettingService.getAccountDetails(hid: hid);
      final profileRequest = WhatsappSettingService.getBusinessProfile(
        hid: hid,
      );

      final details = await detailsRequest;
      final profile = await profileRequest;

      info.value = WhatsappAccountInfo.fromJson(
        details: details,
        profile: profile,
      );

      _readAutoMessages(details['autoMessage']);
      _readAi(details['ai']);
    } catch (e) {
      debugPrint('WHATSAPP SETTING: account error: $e');
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final response = await WhatsappTemaplate.getWhatsappTemplates(hid: hid);

      templates.assignAll(response.result?.docs?.data ?? []);
    } catch (e) {
      debugPrint('WHATSAPP SETTING: templates error: $e');
    }
  }

  Future<void> _loadFlowIds() async {
    try {
      flowIds.assignAll(await WhatsappSettingService.getFlowIds(hid: hid));
    } catch (e) {
      debugPrint('WHATSAPP SETTING: flow error: $e');
    }
  }

  // ============================================================
  // 2. AUTO MESSAGE
  // Saved setting server se aati hai. Badlav abhi sirf screen par hota hai
  // (save ki API nahi mili).
  // ============================================================

  /// Paanch module: Eazbot, Webform, Meta, Google, WhatsApp
  final autoMessages = AutoMessageConfig.listFromJson({}).obs;

  /// Server ka `autoMessage` Map -> paanch module
  void _readAutoMessages(dynamic json) {
    autoMessages.assignAll(
      AutoMessageConfig.listFromJson(
        json is Map ? Map<String, dynamic>.from(json) : {},
      ),
    );
  }

  /// "Apply same config to all modules" ka checkbox
  final applyToAll = false.obs;

  /// Switch on / off
  void setAutoMessageEnabled(AutoMessageConfig module, bool enabled) {
    module.enabled = enabled;

    _afterAutoMessageChange(module);
  }

  /// Pehla dropdown: Template ya Flow
  void setAutoMessageType(AutoMessageConfig module, String type) {
    module.type = type;
    module.selection = null; // type badla to purana chunav hata do

    _afterAutoMessageChange(module);
  }

  /// Doosra dropdown: kaunsa template / flow
  void setAutoMessageSelection(AutoMessageConfig module, String? selection) {
    module.selection = selection;

    _afterAutoMessageChange(module);
  }

  void _afterAutoMessageChange(AutoMessageConfig changed) {
    // Checkbox laga ho to wahi setting baaki sab module me bhi daal do
    if (applyToAll.value) {
      for (final module in autoMessages) {
        module.enabled = changed.enabled;
        module.type = changed.type;
        module.selection = changed.selection;
      }
    }

    // List ke andar ka object badla hai, isliye screen ko khud batana padta hai
    autoMessages.refresh();
  }

  /// Doosre dropdown ke option: template ke naam ya flow ki id
  List<String> optionsFor(AutoMessageConfig module) {
    if (module.isFlow) return flowIds.toList();

    return templates
        .map((template) => template.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Chune hue template ka message (dropdown ke neeche preview me dikhta hai)
  String? previewFor(AutoMessageConfig module) {
    if (module.isFlow) return null;

    final template = templates.firstWhereOrNull(
      (t) => t.name == module.selection,
    );

    return template == null ? null : bodyOf(template);
  }

  /// Template ke BODY hisse ka text
  String? bodyOf(WhatsappTemplate template) {
    final body = template.components?.firstWhereOrNull(
      (component) => component.type?.toUpperCase() == 'BODY',
    );

    final text = body?.text?.trim() ?? '';

    return text.isEmpty ? null : text;
  }

  // ============================================================
  // 3. BUSINESS PROFILE EDIT
  // Edit -> form khulta hai -> Save par API -> naya data dobara aata hai
  // ============================================================

  /// true = card me form dikh raha hai
  final isEditingProfile = false.obs;

  /// true = Save chal raha hai (button par "Saving...")
  final isSavingProfile = false.obs;

  /// Form ke neeche dikhne wala error (null = koi error nahi)
  final profileError = RxnString();

  void startEditingProfile() {
    profileError.value = null;
    isEditingProfile.value = true;
  }

  void cancelEditingProfile() {
    profileError.value = null;
    isEditingProfile.value = false;
  }

  Future<void> saveBusinessProfile({
    required String about,
    required String email,
    required String address,
    required String industry,
    required List<String> websites,
  }) async {
    if (isSavingProfile.value) return;

    // Khali website hata do
    final links = websites
        .map((link) => link.trim())
        .where((link) => link.isNotEmpty)
        .toList();

    // ---------- Form check ----------
    final mail = email.trim();

    if (mail.isNotEmpty && !GetUtils.isEmail(mail)) {
      profileError.value = 'Please enter a valid email';
      return;
    }

    if (links.any((link) => !link.startsWith('http'))) {
      profileError.value = 'Website must start with https://';
      return;
    }

    // ---------- API ----------
    profileError.value = null;
    isSavingProfile.value = true;

    try {
      await WhatsappSettingService.updateBusinessProfile(
        hid: hid,
        about: about.trim(),
        vertical: industry,
        email: mail,
        address: address.trim(),
        websites: links,
      );

      // Server se naya data lao, phir form band karo
      await _loadAccount();

      isEditingProfile.value = false;

      Get.snackbar(
        'Profile updated',
        'WhatsApp business profile has been saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      profileError.value = e.message;
    } catch (e) {
      profileError.value = 'Unable to save the profile. Please try again.';
    } finally {
      isSavingProfile.value = false;
    }
  }

  // ============================================================
  // 4. AI CONFIGURATION
  // Saved setting server se aati hai. Badlav abhi sirf screen par hota hai
  // (save ki API nahi mili).
  // ============================================================

  final aiEnabled = false.obs;
  final aiFrom = const TimeOfDay(hour: 8, minute: 0).obs;
  final aiTo = const TimeOfDay(hour: 8, minute: 0).obs;

  /// Server ka `ai` Map: {"enabled": true, "duration": {"from": "08:00", "to": "08:00"}}
  void _readAi(dynamic json) {
    if (json is! Map) return;

    aiEnabled.value = json['enabled'] == true;

    final duration = json['duration'];

    if (duration is Map) {
      aiFrom.value = _parseTime(duration['from']) ?? aiFrom.value;
      aiTo.value = _parseTime(duration['to']) ?? aiTo.value;
    }
  }

  /// "08:30" -> TimeOfDay(8, 30). Galat ho to null.
  TimeOfDay? _parseTime(dynamic value) {
    final parts = value?.toString().split(':') ?? [];
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  // ============================================================
  // 5. WIDGET CODE
  // ============================================================

  /// Website me lagane wala code (hotel ki ndid, hid, phone ke saath)
  WhatsappWidgetCode get widgetCode {
    // "+91 97593 49941" -> "+919759349941"
    final digits = info.value.phoneNumber.replaceAll(RegExp(r'\D'), '');

    return WhatsappWidgetCode(
      ndid: ndid,
      hid: hid,
      phone: digits.isEmpty ? '' : '+$digits',
    );
  }

  // ============================================================
  // 6. BUTTONS JINKI API ABHI NAHI MILI
  // API milne par: WhatsappSettingService me call banao,
  // phir yahan _notConnected ki jagah use chalao.
  // ============================================================

  void saveAiConfiguration() => _notConnected('Saving the AI configuration');

  void createTemplate() => _notConnected('Creating a template');

  void editTemplate(WhatsappTemplate template) =>
      _notConnected('Editing a template');

  void deleteTemplate(WhatsappTemplate template) =>
      _notConnected('Deleting a template');

  void _notConnected(String action) {
    Get.snackbar(
      'Not connected yet',
      '$action needs its API. The screen is ready.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
