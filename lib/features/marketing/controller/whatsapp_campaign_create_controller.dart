// ============================================================
// WHATSAPP: NAYA CAMPAIGN  (web dashboard ka "New campaign" jaisa)
//
//   1. Naam
//   2. Message : Marketing / Utility -> approved template -> {{1}} {{2}} values
//   3. Audience: contact source -> kitne log + andaazan kharcha
//                (1000 / din se zyada ho to chetavni)
//   -> Create campaign
// ============================================================

import 'dart:async';

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:eazotel/features/whatsapp/services/whatsappTemplate.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../services/marketing_service.dart';

/// Template ka type (web ke TEMPLATE_CATEGORIES)
enum CampaignCategory {
  marketing('Marketing', 0.10),
  utility('Utility', 0.05);

  const CampaignCategory(this.label, this.pricePerMessage);

  final String label;

  /// Ek message ka andaazan kharcha (₹)
  final double pricePerMessage;
}

class WhatsappCampaignCreateController extends GetxController {
  /// Meta ka tier-1 limit: 24 ghante me itne alag contacts
  static const int dailySendLimit = 1000;

  static final RegExp _placeholder = RegExp(r'\{\{\s*\d+\s*\}\}');

  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ============================================================
  // FORM STATE
  // ============================================================

  final name = ''.obs;
  final category = CampaignCategory.marketing.obs;
  final template = Rxn<WhatsappTemplate>();

  /// {{1}} {{2}} ... ki values (body)
  final bodyValues = <String>[].obs;

  /// Header ka {{1}} (zyada se zyada ek)
  final headerValues = <String>[].obs;

  /// '' = All sources
  final source = ''.obs;

  // ============================================================
  // DATA
  // ============================================================

  final allTemplates = <WhatsappTemplate>[].obs;
  final isTemplatesLoading = true.obs;
  final templatesError = RxnString();

  final audience = 0.obs;
  final isAudienceLoading = false.obs;

  final isCreating = false.obs;

  int _audienceRequest = 0;

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
    loadAudience();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  /// Sirf APPROVED + chuni hui category ke template
  List<WhatsappTemplate> get templates => allTemplates.where((t) {
    final status = (t.status ?? '').toUpperCase();
    final approved = status.isEmpty || status == 'APPROVED';
    return approved && (t.category ?? '').toLowerCase() == category.value.name;
  }).toList();

  double get cost => audience.value * category.value.pricePerMessage;

  bool get overLimit => audience.value > dailySendLimit;

  /// Pehli cheez jo abhi baaki hai (null = sab theek, bhej sakte hain)
  String? get missing {
    if (name.value.trim().isEmpty) return 'Give the campaign a name';
    if (template.value == null) return 'Choose a template';
    final filled = [
      ...bodyValues,
      ...headerValues,
    ].every((v) => v.trim().isNotEmpty);
    if (!filled) return 'Fill in every template value';
    if (!isAudienceLoading.value && audience.value == 0) {
      return 'No contacts match this audience';
    }
    return null;
  }

  // ============================================================
  // TEMPLATE BODY / HEADER
  // ============================================================

  static TemplateComponent? componentOf(WhatsappTemplate? t, String type) => t
      ?.components
      ?.firstWhereOrNull((c) => (c.type ?? '').toUpperCase() == type);

  static int placeholderCount(String? text) =>
      _placeholder.allMatches(text ?? '').length;

  /// {{1}} ki jagah value (khali ho to {{1}} hi rehne do)
  static String fill(String text, List<String> values) {
    var i = 0;
    return text.replaceAllMapped(_placeholder, (m) {
      final value = i < values.length ? values[i].trim() : '';
      i++;
      return value.isEmpty ? m[0]! : value;
    });
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void changeCategory(CampaignCategory value) {
    category.value = value;
    template.value = null;
    bodyValues.clear();
    headerValues.clear();
  }

  /// Template chuna: sample values se shuru
  void chooseTemplate(WhatsappTemplate? value) {
    template.value = value;

    final body = componentOf(value, 'BODY');
    final header = componentOf(value, 'HEADER');

    final bodyCount = placeholderCount(body?.text);
    final bodySamples = body?.example?.bodyText?.firstOrNull ?? const [];
    bodyValues.assignAll([
      for (var i = 0; i < bodyCount; i++)
        i < bodySamples.length ? bodySamples[i] : '',
    ]);

    final headerIsText = (header?.format ?? 'TEXT').toUpperCase() == 'TEXT';
    final headerCount = headerIsText ? placeholderCount(header?.text) : 0;
    final headerSamples = header?.example?.headerText ?? const [];
    headerValues.assignAll([
      for (var i = 0; i < headerCount; i++)
        i < headerSamples.length ? headerSamples[i] : '',
    ]);
  }

  void setBodyValue(int index, String value) {
    if (index < bodyValues.length) bodyValues[index] = value;
  }

  void setHeaderValue(int index, String value) {
    if (index < headerValues.length) headerValues[index] = value;
  }

  void changeSource(String value) {
    source.value = value;
    loadAudience();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadTemplates() async {
    if (hid.isEmpty) {
      templatesError.value = 'No hotel selected';
      isTemplatesLoading.value = false;
      return;
    }

    isTemplatesLoading.value = true;
    templatesError.value = null;

    try {
      final response = await WhatsappTemaplate.getWhatsappTemplates(hid: hid);
      allTemplates.assignAll(response.result?.docs?.data ?? const []);
    } catch (e) {
      debugPrint('NEW CAMPAIGN: templates error: $e');
      templatesError.value = 'Unable to load templates.';
    } finally {
      isTemplatesLoading.value = false;
    }
  }

  Future<void> loadAudience() async {
    if (hid.isEmpty) return;

    // Jaldi jaldi source badla to sirf aakhri wala jawab rakho
    final request = ++_audienceRequest;
    isAudienceLoading.value = true;

    try {
      final total = await MarketingService.getCampaignAudience(
        hid: hid,
        source: source.value,
      );
      if (request == _audienceRequest) audience.value = total;
    } catch (e) {
      debugPrint('NEW CAMPAIGN: audience error: $e');
      if (request == _audienceRequest) audience.value = 0;
    } finally {
      if (request == _audienceRequest) isAudienceLoading.value = false;
    }
  }

  // ============================================================
  // CREATE
  // ============================================================

  /// true = ban gaya. Galti ho to [onError] me server ka message.
  Future<bool> create({required void Function(String) onError}) async {
    final t = template.value;
    if (missing != null || t == null || isCreating.value) return false;

    isCreating.value = true;

    try {
      await MarketingService.createWhatsappCampaign(
        hid: hid,
        name: name.value.trim(),
        source: source.value,
        // Web jaisa: header ki value ek string jaati hai (header me ek hi {{1}})
        template: {
          'templateId': t.id,
          'templateName': t.name,
          'templateCategory': t.category,
          'templateLanguage': t.language,
          'templateParams': bodyValues.map((v) => v.trim()).toList(),
          'templateParamsHeader': headerValues.isNotEmpty
              ? headerValues.first.trim()
              : <String>[],
        },
      );
      return true;
    } catch (e) {
      onError(MarketingService.errorText(e, 'Could not create the campaign.'));
      return false;
    } finally {
      isCreating.value = false;
    }
  }
}
