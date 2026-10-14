// ============================================================
// MESSAGE TEMPLATE CONTROLLER
// Settings > WhatsApp > Message Templates
//
//   Create Template  : naam, category, language, header (none/text/photo),
//                      body, footer, buttons, {{1}} ke sample -> Create
//   Edit             : Overview ke template card ka "Edit" (naam badal nahi sakte)
//   Template Library : taiyaar template chuno -> form bhar jaata hai
//
// Variable = body/header me {{1}}, {{2}} ... Meta ko har ek ka
// sample (jaise "Rahul") chahiye, isliye unke liye alag box aate hain.
// ============================================================

import 'dart:convert';

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/whatsapp_setting_controller.dart';
import '../../models/whatsapp_action_response.dart';
import '../models/template_library.dart';
import '../services/message_template_service.dart';

enum TemplateSubTab {
  create('Create Template'),
  library('Template Library');

  const TemplateSubTab(this.label);
  final String label;
}

enum TemplateHeaderType {
  none('NONE', 'None'),
  text('TEXT', 'Text'),
  image('IMAGE', 'Image');

  const TemplateHeaderType(this.value, this.label);

  /// Server wala naam
  final String value;
  final String label;

  static TemplateHeaderType from(String? value) => values.firstWhere(
    (t) => t.value == value?.toUpperCase(),
    orElse: () => none,
  );
}

/// Form ka ek button (Visit website / Quick reply / Call)
class TemplateButtonForm {
  TemplateButtonForm({
    this.type = 'visit',
    String text = '',
    String url = '',
    String urlType = 'static',
  }) : text = TextEditingController(text: text),
       url = TextEditingController(text: url),
       urlType = urlType.obs;

  /// visit (naya) / URL / QUICK_REPLY / CALL / PHONE_NUMBER
  final String type;
  final TextEditingController text;
  final TextEditingController url;

  /// static / dynamic
  final RxString urlType;

  bool get isLink => type == 'visit' || type == 'URL';
  bool get isCall => type == 'CALL' || type == 'PHONE_NUMBER';
  bool get needsValue => isLink || isCall;

  String get typeLabel => isLink
      ? 'Visit website'
      : isCall
      ? 'Call phone number'
      : 'Quick reply';

  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text.text.trim(),
    if (needsValue) 'url': url.text.trim(),
    if (isLink) 'urlType': urlType.value,
  };

  void dispose() {
    text.dispose();
    url.dispose();
  }
}

class MessageTemplateController extends GetxController {
  static const Map<String, String> languages = {
    'en_US': 'English (US)',
    'hi': 'Hindi',
  };
  static const List<String> categories = LibraryTemplate.categories;
  static const int maxButtons = 10;

  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  final subTab = TemplateSubTab.create.obs;

  // ============================================================
  // FORM
  // ============================================================

  /// null = naya template, warna edit ho rahe template ki id
  final editingId = RxnString();
  bool get isEditing => editingId.value != null;

  final name = TextEditingController();
  final header = TextEditingController();
  final body = TextEditingController();
  final footer = TextEditingController();

  final language = 'en_US'.obs;
  final category = 'UTILITY'.obs;
  final headerType = TemplateHeaderType.none.obs;

  /// Nayi chuni photo (phone / computer par)
  final headerImagePath = RxnString();

  /// Pehle se lagi photo ka link (edit me)
  final headerImageUrl = RxnString();

  final buttons = <TemplateButtonForm>[].obs;

  /// {{1}} {{2}} ke sample (header me max 1)
  final headerSamples = <TextEditingController>[].obs;
  final bodySamples = <TextEditingController>[].obs;

  /// Submit dabane ke baad hi galti dikhao
  final showErrors = false.obs;
  final isSaving = false.obs;

  /// Text badalne par screen dobara bane
  final _tick = 0.obs;
  void _touch() => _tick.value++;

  @override
  void onInit() {
    super.onInit();
    for (final field in [name, footer]) {
      field.addListener(_touch);
    }
    header.addListener(() {
      _syncSamples();
      _touch();
    });
    body.addListener(() {
      _syncSamples();
      _touch();
    });
  }

  @override
  void onClose() {
    for (final field in [name, header, body, footer]) {
      field.dispose();
    }
    for (final b in buttons) {
      b.dispose();
    }
    for (final s in [...headerSamples, ...bodySamples]) {
      s.dispose();
    }
    super.onClose();
  }

  // ============================================================
  // VARIABLES {{1}}
  // ============================================================

  /// "Hi {{1}}, room {{2}} ... {{1}}" -> ["{{1}}", "{{2}}"]
  static List<String> variablesOf(String text) => RegExp(
    r'\{\{\d+\}\}',
  ).allMatches(text).map((m) => m.group(0)!).toSet().toList();

  List<String> get headerVariables {
    _tick.value;
    return headerType.value == TemplateHeaderType.text
        ? variablesOf(header.text)
        : const [];
  }

  List<String> get bodyVariables {
    _tick.value;
    return variablesOf(body.text);
  }

  /// Variable jitne hain utne sample box (purana likha hua bacha rehta hai)
  void _syncSamples() {
    void sync(RxList<TextEditingController> list, int count) {
      while (list.length < count) {
        list.add(TextEditingController()..addListener(_touch));
      }
      while (list.length > count) {
        list.removeLast().dispose();
      }
    }

    sync(headerSamples, headerVariables.length);
    sync(bodySamples, bodyVariables.length);
  }

  /// Header me sirf ek variable (Meta ka niyam)
  void addHeaderVariable() {
    if (variablesOf(header.text).isNotEmpty) return;
    header.text = '${header.text}{{1}}';
  }

  void addBodyVariable() {
    final next = RegExp(r'\{\{\d+\}\}').allMatches(body.text).length + 1;
    body.text = '${body.text} {{$next}}';
  }

  void setHeaderType(TemplateHeaderType type) {
    headerType.value = type;
    if (type != TemplateHeaderType.text) header.clear();
    if (type != TemplateHeaderType.image) {
      headerImagePath.value = null;
      headerImageUrl.value = null;
    }
    _syncSamples();
  }

  Future<void> pickHeaderImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    final path = file?.path;
    if (file == null || path == null) return;

    final size = file.lengthSync() ?? await file.length() ?? 0;
    if (size > 5 * 1024 * 1024) {
      _toast('Image too large', 'Header image should be less than 5MB.');
      return;
    }
    headerImagePath.value = path;
  }

  // ============================================================
  // BUTTONS
  // ============================================================

  void addButton() {
    if (buttons.length >= maxButtons) return;
    buttons.add(_watched(TemplateButtonForm()));
  }

  void removeButton(TemplateButtonForm button) {
    buttons.remove(button);
    button.dispose();
    _touch();
  }

  TemplateButtonForm _watched(TemplateButtonForm b) {
    b.text.addListener(_touch);
    b.url.addListener(_touch);
    return b;
  }

  // ============================================================
  // GALTIYAN (Submit par dikhti hain)
  // ============================================================

  String? get nameError {
    _tick.value;
    final value = name.text.trim();
    if (value.length < 3) return 'Template name must be at least 3 characters';
    if (value.length > 50) return 'Template name cannot exceed 50 characters';
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
      return 'Use lowercase letters, numbers and _ only';
    }
    return null;
  }

  String? get headerError {
    _tick.value;
    if (headerType.value == TemplateHeaderType.text &&
        header.text.trim().isEmpty) {
      return 'Header text is required';
    }
    if (headerType.value == TemplateHeaderType.image &&
        headerImagePath.value == null &&
        headerImageUrl.value == null) {
      return 'Please choose a header image';
    }
    return null;
  }

  String? get bodyError {
    _tick.value;
    final length = body.text.trim().length;
    if (length < 10) return 'Body must be at least 10 characters';
    if (length > 1024) return 'Body cannot exceed 1024 characters';
    return null;
  }

  String? buttonError(TemplateButtonForm b) {
    _tick.value;
    if (b.text.text.trim().isEmpty) return 'Button text is required';
    if (b.needsValue && b.url.text.trim().isEmpty) {
      return b.isCall ? 'Phone number is required' : 'Website URL is required';
    }
    return null;
  }

  bool get hasEmptySample {
    _tick.value;
    return [...headerSamples, ...bodySamples].any((s) => s.text.trim().isEmpty);
  }

  bool get isValid =>
      nameError == null &&
      headerError == null &&
      bodyError == null &&
      buttons.every((b) => buttonError(b) == null);

  // ============================================================
  // PREVIEW ({{1}} ki jagah sample)
  // ============================================================

  String _fill(String text, List<String> vars, List<TextEditingController> s) {
    var out = text;
    for (var i = 0; i < vars.length && i < s.length; i++) {
      final sample = s[i].text.trim();
      if (sample.isNotEmpty) out = out.replaceAll(vars[i], sample);
    }
    return out;
  }

  String get previewHeader {
    _tick.value;
    return _fill(header.text, headerVariables, headerSamples);
  }

  String get previewBody {
    _tick.value;
    return _fill(body.text, bodyVariables, bodySamples);
  }

  String get previewFooter {
    _tick.value;
    return footer.text;
  }

  // ============================================================
  // FORM BHARNA: naya / edit / library se
  // ============================================================

  void _reset() {
    editingId.value = null;
    showErrors.value = false;
    name.clear();
    header.clear();
    body.clear();
    footer.clear();
    language.value = 'en_US';
    category.value = 'UTILITY';
    headerType.value = TemplateHeaderType.none;
    headerImagePath.value = null;
    headerImageUrl.value = null;
    for (final b in buttons) {
      b.dispose();
    }
    buttons.clear();
    _syncSamples();
  }

  void startCreate() {
    _reset();
    subTab.value = TemplateSubTab.create;
  }

  /// Overview ke template card ka "Edit"
  void startEdit(WhatsappTemplate template) {
    _reset();

    TemplateComponent? part(String type) => template.components
        ?.firstWhereOrNull((c) => c.type?.toUpperCase() == type);

    final head = part('HEADER');
    final main = part('BODY');
    final foot = part('FOOTER');
    final btns = part('BUTTONS');

    editingId.value = template.id;
    name.text = template.name ?? '';
    language.value = languages.containsKey(template.language)
        ? template.language!
        : 'en_US';
    category.value = categories.contains(template.category?.toUpperCase())
        ? template.category!.toUpperCase()
        : 'UTILITY';

    final type = TemplateHeaderType.from(head?.format);
    headerType.value = type;
    if (type == TemplateHeaderType.text) header.text = head?.text ?? '';
    if (type == TemplateHeaderType.image) {
      headerImageUrl.value = head?.example?.headerHandle?.firstOrNull;
    }

    body.text = main?.text ?? '';
    footer.text = foot?.text ?? '';

    for (final b in btns?.buttons ?? <TemplateButton>[]) {
      buttons.add(
        _watched(
          TemplateButtonForm(
            type: b.type ?? 'URL',
            text: b.text ?? '',
            url: b.url ?? '',
          ),
        ),
      );
    }

    _syncSamples();
    _fillSamples(headerSamples, head?.example?.headerText ?? const []);
    _fillSamples(bodySamples, main?.example?.bodyText?.firstOrNull ?? const []);

    subTab.value = TemplateSubTab.create;
  }

  /// Template Library se
  void useLibrary(LibraryTemplate template) {
    _reset();

    name.text = template.name;
    category.value = template.category;
    headerType.value = TemplateHeaderType.text;
    header.text = template.header;
    body.text = template.body;
    footer.text = template.footer;

    for (final b in template.buttons) {
      buttons.add(
        _watched(
          TemplateButtonForm(
            type: b.type == 'URL' ? 'visit' : b.type,
            text: b.text,
            url: b.url ?? '',
          ),
        ),
      );
    }

    _syncSamples();
    subTab.value = TemplateSubTab.create;
  }

  void _fillSamples(List<TextEditingController> list, List<String> values) {
    for (var i = 0; i < list.length && i < values.length; i++) {
      list[i].text = values[i];
    }
  }

  // ============================================================
  // SAVE (Create / Publish Changes)
  // ============================================================

  Future<void> submit() async {
    if (isSaving.value) return;

    showErrors.value = true;
    if (!isValid) {
      _toast('Check the form', 'Please fix the highlighted fields.');
      return;
    }

    final fields = {
      'name': name.text.trim(),
      'language': language.value,
      'category': category.value,
      'headerType': headerType.value.value,
      'header': header.text.trim(),
      'body': body.text.trim(),
      'footer': footer.text.trim(),
      'headerVariables': jsonEncode(
        headerSamples.map((s) => s.text.trim()).toList(),
      ),
      'bodyVariables': jsonEncode(
        bodySamples.map((s) => s.text.trim()).toList(),
      ),
      'buttons': jsonEncode(buttons.map((b) => b.toJson()).toList()),
    };

    final imagePath = headerType.value == TemplateHeaderType.image
        ? headerImagePath.value
        : null;

    isSaving.value = true;
    try {
      final response = isEditing
          ? await MessageTemplateService.updateTemplate(
              hid: hid,
              templateId: editingId.value!,
              fields: fields,
              headerFilePath: imagePath,
            )
          : await MessageTemplateService.createTemplate(
              hid: hid,
              fields: fields,
              headerFilePath: imagePath,
            );

      if (response.isSuccess) {
        _toast(
          isEditing ? 'Template updated' : 'Template created',
          response.message('Sent to Meta for review.'),
        );

        // Overview ki list taaza karo
        if (Get.isRegistered<WhatsappSettingController>()) {
          Get.find<WhatsappSettingController>().reloadTemplates();
        }
        startCreate();
        return;
      }

      _toast('Not saved', response.message('Failed to create template.'));
    } catch (e) {
      _toast(
        'Not saved',
        WhatsappActionResponse.errorOf(e, 'Failed to create template.'),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // TEMPLATE LIBRARY
  // ============================================================

  final librarySearch = ''.obs;

  /// '' = All
  final libraryCategory = ''.obs;

  List<LibraryTemplate> get libraryTemplates => LibraryTemplate.all
      .where(
        (t) =>
            (libraryCategory.value.isEmpty ||
                t.category == libraryCategory.value) &&
            t.matches(librarySearch.value),
      )
      .toList();

  void _toast(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}
