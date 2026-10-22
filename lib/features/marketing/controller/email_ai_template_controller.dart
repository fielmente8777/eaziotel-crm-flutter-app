// ============================================================
// AI EMAIL TEMPLATE CONTROLLER  (like the web AITemplateModal)
//
//   Brief  : what email you want + tone + brand (name, color, logo) + button
//   Generate -> AI writes the whole email (20-60 sec)
//   Refine   -> a change like "make the button red", new version
//   Versions : < 1 / 3 >  you can go back to an older version
//   Save / Save & use
//
// The brand is remembered on the phone (no need to type it every time).
// ============================================================

import 'dart:convert';

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/marketing_models.dart';
import '../services/marketing_service.dart';

class EmailAiTemplateController extends GetxController {
  EmailAiTemplateController({EmailTemplate? initial}) {
    if (initial != null && initial.html.isNotEmpty) _open(initial);
  }

  static const String _brandKey = 'eazomail_ai_brand';

  static const suggestions = [
    'Festive season offer: 20% off direct bookings for stays in November and December',
    'Welcome email for guests who just booked, with check-in tips and what to pack',
    'Monthly newsletter with property updates, a new experience and a seasonal menu',
    "Win back past guests who haven't stayed with us in over a year",
  ];

  static const tones = [
    ('friendly', 'Friendly'),
    ('warm', 'Warm'),
    ('professional', 'Professional'),
    ('luxurious', 'Luxurious'),
    ('playful', 'Playful'),
    ('urgent', 'Urgent'),
  ];

  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ============================================================
  // BRIEF
  // ============================================================

  final prompt = ''.obs;
  final tone = 'friendly'.obs;
  final brandName = ''.obs;
  final primaryColor = '#2563eb'.obs;
  final logoUrl = ''.obs;
  final ctaText = ''.obs;
  final ctaUrl = ''.obs;
  final refineText = ''.obs;

  // ============================================================
  // RESULT
  // ============================================================

  final versions = <EmailTemplate>[].obs;
  final versionIndex = (-1).obs;
  final name = ''.obs;
  final subject = ''.obs;

  final isGenerating = false.obs;
  final isSaving = false.obs;
  final error = RxnString();
  final notice = RxnString();

  /// Template saved on the server (empty = not saved yet)
  final savedId = ''.obs;
  String _savedSnapshot = '';

  EmailTemplate? get current =>
      versionIndex.value >= 0 && versionIndex.value < versions.length
      ? versions[versionIndex.value]
      : null;

  bool get busy => isGenerating.value || isSaving.value;

  String _snapshot(String n, String s, String html) =>
      jsonEncode([n.trim(), s.trim(), html]);

  bool get hasUnsavedChanges =>
      savedId.value.isEmpty ||
      _snapshot(name.value, subject.value, current?.html ?? '') !=
          _savedSnapshot;

  @override
  void onInit() {
    super.onInit();
    _loadBrand();
  }

  void _open(EmailTemplate t) {
    versions.assignAll([t]);
    versionIndex.value = 0;
    name.value = t.name;
    subject.value = t.subject;
    prompt.value = t.prompt;
    savedId.value = t.id;
    _savedSnapshot = _snapshot(t.name, t.subject, t.html);
  }

  // ============================================================
  // GENERATE / REFINE
  // ============================================================

  Future<void> generate({bool refine = false}) async {
    if (isGenerating.value) return;

    final brief = (refine ? refineText.value : prompt.value).trim();
    if (brief.length < 5) {
      error.value = refine
          ? 'Describe what you want to change.'
          : "Describe the email: the offer, who it's for, and any dates or details.";
      return;
    }

    error.value = null;
    notice.value = null;
    isGenerating.value = true;
    _saveBrand();

    try {
      final previous = refine ? current : null;
      final doc = await MarketingService.generateEmailTemplate(
        hid: hid,
        prompt: brief,
        tone: tone.value,
        brandName: brandName.value.trim(),
        primaryColor: primaryColor.value.trim(),
        logoUrl: logoUrl.value.trim(),
        ctaText: ctaText.value.trim(),
        ctaUrl: ctaUrl.value.trim(),
        previous: previous?.copyWith(subject: subject.value),
      );

      // Drop the later versions and add a new one (new one made after an undo)
      final next = [
        ...versions.take(versionIndex.value + 1),
        EmailTemplate(
          name: doc.name,
          subject: doc.subject,
          html: doc.html,
          previewText: doc.previewText,
        ),
      ];
      versions.assignAll(next);
      versionIndex.value = next.length - 1;

      if (doc.subject.isNotEmpty) subject.value = doc.subject;
      if (doc.name.isNotEmpty &&
          (name.value.trim().isEmpty || (!refine && savedId.value.isEmpty))) {
        name.value = doc.name;
      }
      if (refine) refineText.value = '';
    } catch (e) {
      error.value = MarketingService.errorText(
        e,
        'Could not generate the template. Try again.',
      );
    } finally {
      isGenerating.value = false;
    }
  }

  void previousVersion() {
    if (versionIndex.value > 0) versionIndex.value--;
  }

  void nextVersion() {
    if (versionIndex.value < versions.length - 1) versionIndex.value++;
  }

  // ============================================================
  // SAVE
  // ============================================================

  /// Saved template (null = error, message in [error])
  Future<EmailTemplate?> save() async {
    final c = current;
    if (c == null || isSaving.value) return null;

    final wasSaved = savedId.value.isNotEmpty;
    final draft = EmailTemplate(
      id: savedId.value,
      name: name.value.trim().isEmpty ? 'Untitled template' : name.value.trim(),
      subject: subject.value.trim(),
      html: c.html,
      previewText: c.previewText,
      prompt: prompt.value.trim(),
    );

    isSaving.value = true;
    error.value = null;
    notice.value = null;

    try {
      final saved = await MarketingService.saveEmailTemplate(
        hid: hid,
        template: draft,
      );
      savedId.value = saved.id.isNotEmpty ? saved.id : draft.id;
      name.value = draft.name;
      _savedSnapshot = _snapshot(draft.name, draft.subject, draft.html);
      notice.value = wasSaved ? 'Template updated.' : 'Template saved.';

      return draft.copyWith(id: savedId.value);
    } catch (e) {
      error.value = MarketingService.errorText(
        e,
        'Could not save the template.',
      );
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  /// To use in the email (save first if it changed)
  Future<EmailTemplate?> saveAndUse() async {
    final c = current;
    if (c == null || busy) return null;

    if (hasUnsavedChanges) return save();

    return EmailTemplate(
      id: savedId.value,
      name: name.value.trim().isEmpty ? 'Untitled template' : name.value.trim(),
      subject: subject.value.trim(),
      html: c.html,
      previewText: c.previewText,
      prompt: prompt.value.trim(),
    );
  }

  // ============================================================
  // BRAND (remembered on the phone)
  // ============================================================

  Future<void> _loadBrand() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_brandKey);
      if (raw == null) return;

      final json = jsonDecode(raw);
      if (json is! Map) return;

      brandName.value = '${json['brandName'] ?? ''}';
      logoUrl.value = '${json['logoUrl'] ?? ''}';
      final color = '${json['primaryColor'] ?? ''}';
      if (color.isNotEmpty) primaryColor.value = color;
    } catch (e) {
      debugPrint('AI TEMPLATE: brand load error: $e');
    }
  }

  Future<void> _saveBrand() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _brandKey,
        jsonEncode({
          'brandName': brandName.value.trim(),
          'primaryColor': primaryColor.value.trim(),
          'logoUrl': logoUrl.value.trim(),
        }),
      );
    } catch (_) {}
  }
}
