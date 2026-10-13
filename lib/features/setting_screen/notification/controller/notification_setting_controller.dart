// ============================================================
// NOTIFICATION SETTING CONTROLLER
//
//   Screen (widgets)  --->  ye controller  --->  services  --->  API
//
// Is file me 4 hisse hain:
//   1. DATA LOAD          : config, WhatsApp switch, templates, flow, team
//   2. CALL NOTIFICATION  : Not Answered / Missed Call / Busy ka message
//   3. LEAD SOURCES       : kis source par kisko WhatsApp / Email jaye
//   4. SAVE               : poori setting server par bhejna
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

  /// null = sab theek. Text ho to poori screen par message + Retry.
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

    // Config zaroori hai. Baaki (switch, templates, flow, team) fail ho
    // jayein to bhi page khulta hai.
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

  /// Team members dashboard ke paas pehle se hote hain; na hon to mangao
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
  // Badlav abhi sirf screen par hota hai (save ki API nahi mili).
  // ============================================================

  void setCallType(CallMessage message, String type) {
    message.type = type;
    message.selection = null; // type badla to purana chunav hata do
    callMessages.refresh();
  }

  void setCallSelection(CallMessage message, String? selection) {
    message.selection = selection;
    callMessages.refresh();
  }

  /// Doosre dropdown ke option: template ke naam ya flow ki id
  List<String> optionsFor(CallMessage message) {
    if (message.isFlow) return flowIds.toList();

    return templates
        .map((template) => template.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Chuna hua template (preview ke liye). Flow ho to null.
  WhatsappTemplate? templateFor(CallMessage message) {
    if (message.isFlow) return null;

    return templates.firstWhereOrNull((t) => t.name == message.selection);
  }

  // ============================================================
  // 3. LEAD SOURCES
  // ============================================================

  /// Team ke wo members jinke paas number (WhatsApp) / email (Email) hai
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

  /// Source ke chune hue number / email
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

  /// Chip par dikhne wala naam: member mila to uska naam, warna number / email
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

  /// Picker se aayi poori nayi list
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
  // "Enable WhatsApp" switch is API me nahi hai, isliye wo save nahi hota.
  // ============================================================

  /// true = Save chal raha hai (button par "Saving...")
  final isSaving = false.obs;

  /// Server ka callConfig._id (load par milta hai, save me wapas jata hai)
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

  /// Web jaisa body: {"config": {...}, "callConfig": {...}}
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
