// ============================================================
// WHATSAPP SETTING CONTROLLER
//
// The "brain" of the Settings > WhatsApp tab.
//
//   Screen (widgets)  --->  this controller  --->  WhatsappSettingService  --->  API
//   (for templates, the WhatsApp feature's WhatsappTemaplate service)
//
// This file has 5 parts:
//   1. DATA LOAD        : get data from the server as soon as the tab opens
//   2. AUTO MESSAGE     : switch / dropdown badalna
//   3. PROFILE EDIT     : business profile badalna (Edit / Save / Cancel)
//   4. AI CONFIGURATION : the AI switch and times
//   5. WIDGET CODE      : the code to put on the website
//   6. BUTTONS          : buttons whose API has not been found yet
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

/// Menu inside the WhatsApp tab (left side / chips on top)
enum WhatsappSettingMenu {
  overview('Overview'),
  messageTemplates('Message Templates'),
  autoMessage('Auto Message'),
  flows('Flows'),
  whatsappFlow('WhatsApp Flow'),
  quickReplies('Quick Replies'),
  creditsUsage('Credits & Usage');

  const WhatsappSettingMenu(this.label);

  /// Name shown on screen
  final String label;
}

class WhatsappSettingController extends GetxController {
  /// The hotel id and ndid come from the dashboard
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  String get ndid => dashboard.user.value?.profile.ndid ?? '';

  /// Which item is selected in the inner menu now
  final selectedMenu = WhatsappSettingMenu.overview.obs;

  // ============================================================
  // 1. DATA LOAD
  // ============================================================

  /// true = data is loading (shimmer shows on screen)
  final isLoading = true.obs;

  /// null = all good. If there is text, that message fills the screen.
  final errorMessage = RxnString();

  /// Account, phone number and business profile info
  final info = const WhatsappAccountInfo().obs;

  /// The hotel's WhatsApp templates
  final templates = <WhatsappTemplate>[].obs;

  /// The chatbot flow id (for the auto message "Flow" dropdown)
  final flowIds = <String>[].obs;

  /// WhatsApp phone number id (needed to save auto message / AI)
  final phoneNumberId = ''.obs;

  @override
  void onInit() {
    super.onInit();

    load();
  }

  /// Runs when the tab opens, on Retry and on pull to refresh.
  ///
  ///   Step 1: is WhatsApp connected  (no -> show a message and stop)
  ///   Step 2: load the rest together  (account, templates, flow)
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
    // All three run together. If one fails, the other two still show.
    await Future.wait([_loadAccount(), _loadTemplates(), _loadFlowIds()]);

    isLoading.value = false;
  }

  /// Account, phone, business profile + saved auto message and AI settings
  Future<void> _loadAccount() async {
    try {
      // Both APIs run together
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

      // WhatsApp phone number id for saving auto message / AI
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

  /// Reload the list after creating / deleting a template
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
  // 2. AUTO MESSAGE (like the web AutoMessageCard)
  //
  //   har module: switch -> type (Template / Text / Flow*) ->
  //     Template : choose a template (full preview below)
  //     Text     : write your own message
  //     Flow     : choose a chatbot flow (*only in the WhatsApp module)
  //   "Apply same config to all": the first enabled module's setting
  //     applies to all; turning it off brings the old ones back
  //   "Save Configuration" shows only when something changed
  // ============================================================

  /// Paanch module: Eazbot, Webform, Meta, Google, WhatsApp
  final autoMessages = AutoMessageConfig.listFromJson({}).obs;

  /// The server's (saved) setting, to detect changes
  late String _savedAutoMessages = _autoSignature;

  /// The server's `autoMessage` Map -> five modules
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

  /// Did anything change? (Save button)
  bool get autoMessageChanged => _autoSignature != _savedAutoMessages;

  /// Is any module on? (otherwise "Apply to all" is disabled)
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

  /// Change one module (if Apply to all is on, the same change everywhere)
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

    // If all are off, turn off "Apply to all" too (same as web)
    if (!anyAutoMessageEnabled && applyToAll.value) {
      applyToAll.value = false;
      _beforeApplyAll = null;
    }
    autoMessages.refresh();
  }

  /// Names for the template dropdown
  List<String> get templateNames => templates
      .map((template) => template.name ?? '')
      .where((name) => name.isNotEmpty)
      .toList();

  WhatsappTemplate? templateNamed(String name) =>
      templates.firstWhereOrNull((t) => t.name == name);

  /// Text of the template's BODY part
  String? bodyOf(WhatsappTemplate template) {
    final body = template.components?.firstWhereOrNull(
      (component) => component.type?.toUpperCase() == 'BODY',
    );

    final text = body?.text?.trim() ?? '';

    return text.isEmpty ? null : text;
  }

  /// The web does not show the notification switch, but the saved value
  /// has to be sent back
  final notifyOnWhatsapp = false.obs;

  /// true = Save is running
  final isSavingAutoMessage = false.obs;

  /// Same as web: an off module {enabled:false}, an on module with full details
  Future<void> saveAutoMessages() async {
    if (isSavingAutoMessage.value) return;
    if (phoneNumberId.value.isEmpty) {
      _toast('Not saved', 'WhatsApp phone number not found. Pull to refresh.');
      return;
    }

    // What an on module needs is filled in
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

  /// The web's getTemplateMeta: the template info the server needs
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
  // Edit -> the form opens -> API on Save -> fresh data comes again
  // ============================================================

  /// true = the form is showing in the card
  final isEditingProfile = false.obs;

  /// true = Save is running ("Saving..." on the button)
  final isSavingProfile = false.obs;

  /// Error shown below the form (null = no error)
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

    // Remove empty websites
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

      // Get fresh data from the server, then close the form
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
  // The saved setting comes from the server. For now changes are only on screen
  // (no save API found).
  // ============================================================

  final aiEnabled = false.obs;
  final aiFrom = const TimeOfDay(hour: 8, minute: 0).obs;
  final aiTo = const TimeOfDay(hour: 8, minute: 0).obs;

  /// The server's `ai` Map: {"enabled": true, "duration": {"from": "08:00", "to": "08:00"}}
  void _readAi(dynamic json) {
    if (json is! Map) return;

    aiEnabled.value = json['enabled'] == true;

    final duration = json['duration'];

    if (duration is Map) {
      aiFrom.value = _parseTime(duration['from']) ?? aiFrom.value;
      aiTo.value = _parseTime(duration['to']) ?? aiTo.value;
    }
  }

  /// "08:30" -> TimeOfDay(8, 30). null if invalid.
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

  /// The code to put on the website (with the hotel's ndid, hid, phone)
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

    // Same as web: "From" cannot be after "To"
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
  // 7. TEMPLATES (from the Overview templates card)
  // Create / Edit -> opens the form of the "Message Templates" menu
  // ============================================================

  void createTemplate() {
    Get.put(MessageTemplateController()).startCreate();
    selectedMenu.value = WhatsappSettingMenu.messageTemplates;
  }

  void editTemplate(WhatsappTemplate template) {
    Get.put(MessageTemplateController()).startEdit(template);
    selectedMenu.value = WhatsappSettingMenu.messageTemplates;
  }

  /// Name of the template being deleted now (loading on the button)
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
