// ============================================================
// EAZBOT SETTING CONTROLLER
//
//   Screen (widgets)  --->  this controller  --->  EazbotSettingService  --->  API
//
// This file has 5 parts:
//   1. STEPS          : 1 Bot Builder, 2 Profile, 3 Configuration, 4 Install
//   2. FORM           : all fields (color, name, messages, switches, questions)
//   3. CHECK          : check the form before Next / Publish
//   4. PUBLISH        : POST /leadeazbot/create
//   5. INSTALL CODE   : the script to put on the website
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/eazbot_question.dart';
import '../services/eazbot_setting_service.dart';

enum EazbotStep {
  builder('Bot Builder'),
  profile('Profile'),
  configuration('Configuration'),
  install('Install');

  const EazbotStep(this.label);

  final String label;
}

class EazbotSettingController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  String get ndid => dashboard.user.value?.profile.ndid ?? '';

  // ============================================================
  // 1. STEPS
  // ============================================================

  final step = EazbotStep.builder.obs;

  /// If there is an error stay on that step, otherwise go to the next step
  void next() {
    final error = _checkStep(step.value);

    if (error != null) return _message('Please check', error);

    if (step.value.index < EazbotStep.values.length - 1) {
      step.value = EazbotStep.values[step.value.index + 1];
    }
  }

  void previous() {
    if (step.value.index > 0) {
      step.value = EazbotStep.values[step.value.index - 1];
    }
  }

  /// From the top stepper: you can only go back or to finished steps
  void goTo(EazbotStep target) {
    if (target.index <= step.value.index) step.value = target;
  }

  // ============================================================
  // 2. FORM
  // ============================================================

  /// Ready-made colors of Builder > Customize
  static const List<Color> presetColors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
  ];

  final color = presetColors[2].obs;

  final greeting = TextEditingController();
  final botName = TextEditingController();
  final contact = TextEditingController();
  final email = TextEditingController();
  final description = TextEditingController(
    text: "Hello! I'm your virtual assistant. How can I help you today?",
  );
  final terminateMessage = TextEditingController();
  final fallbackMessage = TextEditingController();
  final timeInterval = TextEditingController();

  final showBranding = true.obs;
  final showTypingIndicator = false.obs;
  final enableLiveChat = true.obs;
  final active = false.obs;

  final questions = EazbotQuestion.defaults().obs;

  /// The preview changes right away while typing the greeting
  final greetingPreview = ''.obs;

  @override
  void onInit() {
    super.onInit();

    greeting.addListener(() => greetingPreview.value = greeting.text);
  }

  @override
  void onClose() {
    for (final c in [
      greeting,
      botName,
      contact,
      email,
      description,
      terminateMessage,
      fallbackMessage,
      timeInterval,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  void setQuestionActive(EazbotQuestion q, bool value) {
    q.active = value;
    questions.refresh();
  }

  void setQuestionText(EazbotQuestion q, String value) => q.question = value;

  /// Color(0xFFF59E0B) -> "#F59E0B"
  static String toHex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// "#F59E0B" / "F59E0B" -> Color. null if invalid.
  static Color? fromHex(String value) {
    final hex = value.trim().replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return null;

    return Color(int.parse('FF$hex', radix: 16));
  }

  // ============================================================
  // 3. CHECK
  // ============================================================

  String? _checkStep(EazbotStep target) {
    switch (target) {
      case EazbotStep.builder:
        if (greeting.text.trim().isEmpty) {
          return 'Please enter a greeting message';
        }
      case EazbotStep.profile:
        if (botName.text.trim().isEmpty) return 'Please enter the bot name';
        final mail = email.text.trim();
        if (mail.isNotEmpty && !GetUtils.isEmail(mail)) {
          return 'Please enter a valid email';
        }
      case EazbotStep.configuration:
        final seconds = timeInterval.text.trim();
        if (seconds.isNotEmpty && int.tryParse(seconds) == null) {
          return 'Time interval must be a number';
        }
      case EazbotStep.install:
        break;
    }
    return null;
  }

  // ============================================================
  // 4. PUBLISH
  // ============================================================

  final isPublishing = false.obs;

  Future<void> publish() async {
    if (isPublishing.value) return;

    // Check all steps; take the user to the one with an error
    for (final target in EazbotStep.values) {
      final error = _checkStep(target);

      if (error != null) {
        step.value = target;
        return _message('Please check', error);
      }
    }

    isPublishing.value = true;

    try {
      final message = await EazbotSettingService.publish(
        hid: hid,
        body: _body(),
      );

      step.value = EazbotStep.install;
      _message('Published', message);
    } catch (e) {
      _message('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isPublishing.value = false;
    }
  }

  /// Body same as web
  Map<String, dynamic> _body() => {
    'bot_name': botName.text.trim(),
    'email': email.text.trim(),
    'contact': contact.text.trim(),
    'description': description.text.trim(),
    'welcome_message': greeting.text.trim(),
    'fallback_message': fallbackMessage.text.trim(),
    'chat_terminate_message': terminateMessage.text.trim(),
    'bg_color': toHex(color.value),
    'text_color': '',
    'button_color': '',
    'button_text_color': '',
    'active': active.value,
    'avatar_url': <String, dynamic>{},
    'enable_live_chat': enableLiveChat.value,
    'show_typing_indicator': showTypingIndicator.value,
    'time_interval': timeInterval.text.trim(),
    'show_eazotel_branding': showBranding.value,
    'bot_type': 'lead',
    'chat_flow': questions.map((q) => q.toJson()).toList(),
    'redirection_url': 'thankyou',
  };

  // ============================================================
  // 5. INSTALL CODE
  // ============================================================

  static const String scriptUrl =
      'https://cb-script.dyq28lyxrazm2.amplifyapp.com/widget/lead-chatbot.js';

  String get nextJsCode =>
      '''<!-- Eazbot Script (Next.js) -->
<Script id="chatbot-config" strategy="afterInteractive">
  {`
    window.eazbotConfig = {
       ndid: "$ndid",
       hid: "$hid",
    };
  `}
</Script>
<Script
  src="$scriptUrl"
  strategy="afterInteractive"
/>''';

  String get htmlCode =>
      '''<!-- Eazbot Script (Plain HTML) -->
<script>
  window.eazbotConfig = {
    ndid: "$ndid",
    hid: "$hid",
  };
</script>
<script src="$scriptUrl"></script>''';

  void _message(String title, String text) {
    Get.snackbar(title, text, snackPosition: SnackPosition.BOTTOM);
  }
}
