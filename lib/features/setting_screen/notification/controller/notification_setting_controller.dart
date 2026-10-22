// ============================================================
// NOTIFICATION SETTING CONTROLLER
//
//   Screen (widgets)  --->  this controller  --->  services  --->  API
//
// This file has 4 parts:
//   1. DATA LOAD          : config, WhatsApp switch, templates, flow, team
//   2. CALL NOTIFICATION  : message for Not Answered / Missed Call / Busy
//   3. LEAD SOURCES       : who gets WhatsApp / Email for which source
//   4. SAVE               : send the whole setting to the server
// ============================================================

import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:eazotel/features/whatsapp/services/whatsappTemplate.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../whatsapp/services/whatsapp_setting_service.dart';
import '../models/notification_config.dart';
import '../models/notification_recipient.dart';
import '../models/template_meta.dart';
import '../services/notification_setting_service.dart';

/// WhatsApp (number) ya Email notification
enum NotificationChannel { whatsapp, email }

class NotificationSettingController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ============================================================
  // 1. DATA LOAD
  // ============================================================

  final isLoading = true.obs;

  /// null = all good. If there is text, a full-screen message + Retry.
  final errorMessage = RxnString();

  /// "Enable WhatsApp" switch
  final whatsappEnabled = false.obs;

  /// "Call Notification" switch
  final callEnabled = false.obs;

  /// Not Answered / Missed Call / Busy
  final callMessages = <CallMessage>[].obs;

  /// Webform / Eazbot / Whatsapp / Facebook / Google
  final sources = <LeadSourceNotification>[].obs;

  final templates = <WhatsappTemplate>[].obs;
  final flowIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    load();
  }

  Future<void> load() async {
    if (hid.isEmpty) {
      errorMessage.value = 'No hotel selected';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    // The config is required. The page still opens even if the rest
    // (switch, templates, flow, team) fails.
    try {
      final docs = await NotificationSettingService.getConfig(hid: hid);
      final config = NotificationConfig.fromJson(docs);

      sources.assignAll(config.sources);
      callEnabled.value = config.callEnabled;
      callMessages.assignAll(config.callMessages);
      _callConfigId = config.callConfigId;
    } catch (e) {
      debugPrint('NOTIFICATION: config error: $e');

      errorMessage.value = 'Unable to load notification settings.';
      isLoading.value = false;
      return;
    }

    await Future.wait([
      _loadWhatsappSwitch(),
      _loadTemplates(),
      _loadFlowIds(),
      _loadTeam(),
    ]);

    isLoading.value = false;
  }

  /// account/connection/details -> notification.enable
  Future<void> _loadWhatsappSwitch() async {
    try {
      final details = await WhatsappSettingService.getAccountDetails(hid: hid);
      final notification = details['notification'];

      whatsappEnabled.value =
          notification is Map && notification['enable'] == true;
    } catch (e) {
      debugPrint('NOTIFICATION: whatsapp switch error: $e');
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final response = await WhatsappTemaplate.getWhatsappTemplates(hid: hid);

      templates.assignAll(response.result?.docs?.data ?? []);
    } catch (e) {
      debugPrint('NOTIFICATION: templates error: $e');
    }
  }

  Future<void> _loadFlowIds() async {
    try {
      flowIds.assignAll(await WhatsappSettingService.getFlowIds(hid: hid));
    } catch (e) {
      debugPrint('NOTIFICATION: flow error: $e');
    }
  }

  /// The dashboard already has the team members; if not, fetch them
  Future<void> _loadTeam() async {
    if (dashboard.userNameResponse.value != null) return;

    try {
      await dashboard.getUserDetails();
    } catch (e) {
      debugPrint('NOTIFICATION: team error: $e');
    }
  }

  // ============================================================
  // 2. CALL NOTIFICATION
  // For now the change is only on screen (no save API found).
  // ============================================================

  void setCallType(CallMessage message, String type) {
    message.type = type;
    message.selection = null; // type changed -> clear the old selection
    callMessages.refresh();
  }

  void setCallSelection(CallMessage message, String? selection) {
    message.selection = selection;
    callMessages.refresh();
  }

  /// Options of the second dropdown: template names or flow ids
  List<String> optionsFor(CallMessage message) {
    if (message.isFlow) return flowIds.toList();

    return templates
        .map((template) => template.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// The selected template (for the preview). null for a flow.
  WhatsappTemplate? templateFor(CallMessage message) {
    if (message.isFlow) return null;

    return templates.firstWhereOrNull((t) => t.name == message.selection);
  }

  // ============================================================
  // 3. LEAD SOURCES
  // ============================================================

  /// Team members who have a number (WhatsApp) / email (Email)
  List<NotificationRecipient> recipientsFor(NotificationChannel channel) {
    final users = dashboard.userNameResponse.value?.data ?? [];

    return users
        .map(NotificationRecipient.fromUser)
        .where(
          (r) => channel == NotificationChannel.whatsapp
              ? r.phone.isNotEmpty
              : r.email.isNotEmpty,
        )
        .toList();
  }

  /// The source's selected numbers / emails
  List<String> valuesOf(
    LeadSourceNotification source,
    NotificationChannel channel,
  ) {
    return channel == NotificationChannel.whatsapp
        ? source.phones
        : source.emails;
  }

  bool isAllowed(LeadSourceNotification source, NotificationChannel channel) {
    return channel == NotificationChannel.whatsapp
        ? source.isPhoneAllowed
        : source.isEmailAllowed;
  }

  /// Name shown on the chip: the member's name if found, otherwise the number / email
  String labelOf(String value, NotificationChannel channel) {
    final match = recipientsFor(channel).firstWhereOrNull(
      (r) => channel == NotificationChannel.whatsapp
          ? r.hasPhone(value)
          : r.hasEmail(value),
    );

    return match?.name ?? value;
  }

  void setAllowed(
    LeadSourceNotification source,
    NotificationChannel channel,
    bool allowed,
  ) {
    if (channel == NotificationChannel.whatsapp) {
      source.isPhoneAllowed = allowed;
    } else {
      source.isEmailAllowed = allowed;
    }

    sources.refresh();
  }

  /// The full new list from the picker
  void setValues(
    LeadSourceNotification source,
    NotificationChannel channel,
    List<String> values,
  ) {
    if (channel == NotificationChannel.whatsapp) {
      source.phones = values;
    } else {
      source.emails = values;
    }

    sources.refresh();
  }

  void removeValue(
    LeadSourceNotification source,
    NotificationChannel channel,
    String value,
  ) {
    setValues(
      source,
      channel,
      valuesOf(source, channel).where((v) => v != value).toList(),
    );
  }

  // ============================================================
  // 4. SAVE
  // POST /api/v1/setting/update-config
  // The "Enable WhatsApp" switch is not in this API, so it is not saved.
  // ============================================================

  /// true = Save is running ("Saving..." on the button)
  final isSaving = false.obs;

  /// The server's callConfig._id (comes on load, sent back on save)
  String? _callConfigId;

  Future<void> save() async {
    if (isSaving.value) return;

    isSaving.value = true;

    try {
      await NotificationSettingService.updateConfig(
        hid: hid,
        body: _saveBody(),
      );

      Get.snackbar(
        'Saved',
        'Notification settings have been updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('NOTIFICATION: save error: $e');

      Get.snackbar(
        'Error',
        e is ApiException
            ? e.message
            : e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Body same as web: {"config": {...}, "callConfig": {...}}
  Map<String, dynamic> _saveBody() {
    return {
      'config': {for (final source in sources) source.key: source.toJson()},
      'callConfig': {
        'configs': {
          for (final message in callMessages)
            message.key: message.toJson(templateMeta: _metaFor(message)),
        },
        'enabled': callEnabled.value,
        if (_callConfigId != null) '_id': _callConfigId,
      },
    };
  }

  Map<String, dynamic>? _metaFor(CallMessage message) {
    final template = templateFor(message);

    return template == null ? null : templateMetaOf(template);
  }
}
