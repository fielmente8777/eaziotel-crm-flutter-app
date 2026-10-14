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

import '../message_templates/controller/message_template_controller.dart';
import '../models/auto_message_config.dart';
import '../models/whatsapp_action_response.dart';
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

  /// WhatsApp phone number ki id (auto message / AI save me lagti hai)
  final phoneNumberId = ''.obs;

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

      // auto message / AI save ke liye WhatsApp phone number ki id
      final phone = details['phoneNumber'];
      phoneNumberId.value = phone is Map ? (phone['id']?.toString() ?? '') : '';

      final notification = details['notification'];
      notifyOnWhatsapp.value =
          notification is Map && notification['enable'] == true;

      _readAutoMessages(details['autoMessage']);
      _readAi(details['ai']);
    } catch (e) {
      debugPrint('WHATSAPP SETTING: account error: $e');
    }
  }

  /// Template banane / hatane ke baad list dobara lao
  Future<void> reloadTemplates() => _loadTemplates();

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
  // 2. AUTO MESSAGE (web ke AutoMessageCard jaisa)
  //
  //   har module: switch -> type (Template / Text / Flow*) ->
  //     Template : template chuno (neeche poora preview)
  //     Text     : apna message likho
  //     Flow     : chatbot flow chuno (*sirf WhatsApp module me)
  //   "Apply same config to all": pehle chalu module ki setting
  //     sab me lag jaati hai; hatane par purani wapas aa jaati hai
  //   "Save Configuration" tabhi dikhta hai jab kuch badla ho
  // ============================================================

  /// Paanch module: Eazbot, Webform, Meta, Google, WhatsApp
  final autoMessages = AutoMessageConfig.listFromJson({}).obs;

  /// Server wali (saved) setting, badlav pakadne ke liye
  late String _savedAutoMessages = _autoSignature;

  /// Server ka `autoMessage` Map -> paanch module
  void _readAutoMessages(dynamic json) {
    autoMessages.assignAll(
      AutoMessageConfig.listFromJson(
        json is Map ? Map<String, dynamic>.from(json) : {},
      ),
    );
    _savedAutoMessages = _autoSignature;
    applyToAll.value = false;
    _beforeApplyAll = null;
  }

  String get _autoSignature => autoMessages.map((m) => m.signature).join(';');

  /// Kuch badla hai? (Save button)
  bool get autoMessageChanged => _autoSignature != _savedAutoMessages;

  /// Koi module chalu hai? (warna "Apply to all" band)
  bool get anyAutoMessageEnabled => autoMessages.any((m) => m.enabled);

  /// "Apply same config to all modules"
  final applyToAll = false.obs;
  List<AutoMessageConfig>? _beforeApplyAll;

  void toggleApplyToAll(bool on) {
    if (on) {
      if (!anyAutoMessageEnabled) return;
      _beforeApplyAll = autoMessages.map((m) => m.copy()).toList();
      final source = autoMessages.firstWhere((m) => m.enabled);
      for (final module in autoMessages) {
        module.copyFrom(source);
        module.enabled = true;
      }
    } else if (_beforeApplyAll != null) {
      autoMessages.assignAll(_beforeApplyAll!);
      _beforeApplyAll = null;
    }
    applyToAll.value = on;
    autoMessages.refresh();
  }

  /// Ek module badlo (Apply to all laga ho to sab me wahi badlav)
  void updateAutoMessage(
    AutoMessageConfig module,
    void Function(AutoMessageConfig m) change,
  ) {
    if (applyToAll.value) {
      for (final m in autoMessages) {
        change(m);
        if (m.isFlow && !m.canUseFlow) m.type = AutoMessageConfig.typeTemplate;
      }
    } else {
      change(module);
    }

    // Sab band ho gaye to "Apply to all" bhi hata do (web jaisa)
    if (!anyAutoMessageEnabled && applyToAll.value) {
      applyToAll.value = false;
      _beforeApplyAll = null;
    }
    autoMessages.refresh();
  }

  /// Template dropdown ke naam
  List<String> get templateNames => templates
      .map((template) => template.name ?? '')
      .where((name) => name.isNotEmpty)
      .toList();

  WhatsappTemplate? templateNamed(String name) =>
      templates.firstWhereOrNull((t) => t.name == name);

  /// Template ke BODY hisse ka text
  String? bodyOf(WhatsappTemplate template) {
    final body = template.components?.firstWhereOrNull(
      (component) => component.type?.toUpperCase() == 'BODY',
    );

    final text = body?.text?.trim() ?? '';

    return text.isEmpty ? null : text;
  }

  /// Web me notification ka switch nahi dikhta, par saved value
  /// wapas bhejni hoti hai
  final notifyOnWhatsapp = false.obs;

  /// true = Save chal raha hai
  final isSavingAutoMessage = false.obs;

  /// Web jaisa: band module {enabled:false}, chalu module poori detail
  Future<void> saveAutoMessages() async {
    if (isSavingAutoMessage.value) return;
    if (phoneNumberId.value.isEmpty) {
      _toast('Not saved', 'WhatsApp phone number not found. Pull to refresh.');
      return;
    }

    // Chalu module me jo chahiye wo bhara ho
    for (final m in autoMessages.where((m) => m.enabled)) {
      final missing = m.isTemplate
          ? m.templateName.isEmpty
          : m.isText
          ? m.message.trim().isEmpty
          : m.flowId.isEmpty;
      if (missing) {
        _toast(
          'Check ${m.label}',
          m.isTemplate
              ? 'Please select a template.'
              : m.isText
              ? 'Please write the message.'
              : 'Please select a flow.',
        );
        return;
      }
    }

    final config = <String, dynamic>{};
    for (final m in autoMessages) {
      if (!m.enabled) {
        config[m.key] = {'enabled': false};
        continue;
      }

      config[m.key] = {
        'enabled': true,
        'type': m.type,
        'templateName': m.templateName.isEmpty ? null : m.templateName,
        'message': m.isText ? m.message.trim() : null,
        'flowId': m.isFlow ? m.flowId : null,
        'templateMeta': m.isTemplate ? _templateMeta(m.templateName) : null,
      };
    }

    isSavingAutoMessage.value = true;
    try {
      final response = await WhatsappSettingService.updateAutoMessageConfig(
        phoneNumberId: phoneNumberId.value,
        body: {
          'autoMessage': config,
          'notification': {'enable': notifyOnWhatsapp.value},
        },
      );

      if (response.isSuccess) {
        _savedAutoMessages = _autoSignature;
        autoMessages.refresh();
      }
      _toast(
        response.isSuccess ? 'Saved' : 'Not saved',
        response.message(
          response.isSuccess
              ? 'Auto message updated successfully'
              : 'Unable to save auto message.',
        ),
      );
    } catch (e) {
      _toast(
        'Not saved',
        WhatsappActionResponse.errorOf(e, 'Unable to save auto message.'),
      );
    } finally {
      isSavingAutoMessage.value = false;
    }
  }

  /// Web ka getTemplateMeta: template ki zaroori jaankari server ke liye
  Map<String, dynamic>? _templateMeta(String? name) {
    final template = templates.firstWhereOrNull((t) => t.name == name);
    if (template == null) return null;

    TemplateComponent? part(String type) => template.components
        ?.firstWhereOrNull((c) => c.type?.toUpperCase() == type);

    final body = part('BODY');
    final header = part('HEADER');
    final buttons = part('BUTTONS');

    return {
      'name': template.name,
      'language': template.language ?? 'en',
      'bodyText': body?.text ?? '',
      'variables': body?.example?.bodyText?.firstOrNull ?? <String>[],
      'headerVariables': header?.example?.headerText ?? <String>[],
      'headerType': header?.format,
      'buttons': [
        for (final b in buttons?.buttons ?? <TemplateButton>[])
          {
            'type': b.type,
            'text': b.text,
            if (b.url != null) 'url': b.url,
            if (b.example != null) 'example': b.example,
          },
      ],
    };
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
    String? photoPath,
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
        photoPath: photoPath,
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
  // 6. AI SAVE
  // ============================================================

  final isSavingAi = false.obs;

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> saveAiConfiguration() async {
    if (isSavingAi.value) return;
    if (phoneNumberId.value.isEmpty) {
      _toast('Not saved', 'WhatsApp phone number not found. Pull to refresh.');
      return;
    }

    final from = _hhmm(aiFrom.value);
    final to = _hhmm(aiTo.value);

    // Web jaisa: "From" "To" se baad nahi ho sakta
    if (from.compareTo(to) > 0) {
      _toast('Check the time', 'From time cannot be later than To time.');
      return;
    }

    isSavingAi.value = true;
    try {
      final response = await WhatsappSettingService.updateAutoMessageConfig(
        phoneNumberId: phoneNumberId.value,
        body: {
          'ai': {
            'enabled': aiEnabled.value,
            'duration': {'from': from, 'to': to},
            'timezone': 'Asia/Kolkata',
          },
        },
      );
      _toast(
        response.isSuccess ? 'Saved' : 'Not saved',
        response.message(
          response.isSuccess
              ? 'AI configuration saved successfully'
              : 'Unable to save AI configuration.',
        ),
      );
    } catch (e) {
      _toast(
        'Not saved',
        WhatsappActionResponse.errorOf(e, 'Unable to save AI configuration.'),
      );
    } finally {
      isSavingAi.value = false;
    }
  }

  // ============================================================
  // 7. TEMPLATES (Overview ke templates card se)
  // Create / Edit -> "Message Templates" menu ka form khulta hai
  // ============================================================

  void createTemplate() {
    Get.put(MessageTemplateController()).startCreate();
    selectedMenu.value = WhatsappSettingMenu.messageTemplates;
  }

  void editTemplate(WhatsappTemplate template) {
    Get.put(MessageTemplateController()).startEdit(template);
    selectedMenu.value = WhatsappSettingMenu.messageTemplates;
  }

  /// Template ka naam jo abhi delete ho raha hai (button par loading)
  final deletingTemplate = RxnString();

  Future<void> deleteTemplate(WhatsappTemplate template) async {
    final name = template.name ?? '';
    if (name.isEmpty || deletingTemplate.value != null) return;

    final sure = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete template?'),
        content: Text('"$name" will be deleted from WhatsApp.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true) return;

    deletingTemplate.value = name;
    try {
      final response = await WhatsappSettingService.deleteTemplate(
        templateName: name,
        language: template.language ?? 'en_US',
      );

      if (response.isSuccess) {
        templates.removeWhere((t) => t.name == name);
        _toast('Deleted', 'Template deleted successfully');
      } else {
        _toast('Not deleted', response.message('Unable to delete template.'));
      }
    } catch (e) {
      _toast(
        'Not deleted',
        WhatsappActionResponse.errorOf(e, 'Unable to delete template.'),
      );
    } finally {
      deletingTemplate.value = null;
    }
  }

  void _toast(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}
