import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappTemplateController.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappbotumwidget/whatsappTemplate.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappbotumwidget/whatsappTemplateParams.dart';
import 'package:eazotel/features/whatsapp/services/whatsappMessegSand.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class AddContect extends StatefulWidget {
  /// If given, the phone number comes pre-filled (like from the Calls page)
  final String? initialPhone;

  const AddContect({super.key, this.initialPhone});

  @override
  State<AddContect> createState() => _AddContectState();
}

class _AddContectState extends State<AddContect> with WidgetsBindingObserver {
  static const List<String> _favoriteCodes = [
    'IN',
    'US',
    'GB',
    'AE',
    'AU',
    'CA',
  ];

  /// Length (min, max) of the national number by country.
  /// _fallbackRange is used for countries not in the list.
  static const Map<String, (int, int)> _lengthRules = {
    'IN': (10, 10),
    'US': (10, 10),
    'CA': (10, 10),
    'GB': (9, 10),
    'AE': (9, 9),
    'AU': (9, 9),
    'SA': (9, 9),
    'SG': (8, 8),
    'PK': (10, 10),
    'BD': (10, 10),
    'NP': (10, 10),
    'LK': (9, 9),
    'CN': (11, 11),
  };

  static const (int, int) _fallbackRange = (6, 14);

  final Whatsapptemplatecontroller controller =
      Get.find<Whatsapptemplatecontroller>();

  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  Country selectedCountry = CountryService().findByCode('IN')!;

  /// The chosen template object
  dynamic selectedTemplate;

  // Template variables edited by the user (to send)
  TemplateSendData? selectedTemplateData;

  bool isPickingContact = false;
  bool isSending = false;

  String get selectedTemplateName =>
      selectedTemplate == null ? '' : _safeString(() => selectedTemplate.name);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    phoneFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    final initialPhone = widget.initialPhone?.trim() ?? '';

    if (initialPhone.isNotEmpty) {
      final parsed = _parseContactNumber(initialPhone);

      selectedCountry = parsed.country;
      phoneController.text = parsed.national;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  /// Remove focus when the app goes to background / tabs switch, so the
  /// keyboard does not open by itself on return.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      phoneFocusNode.unfocus();
    }
  }

  // ===============================================================
  // TOP SNACKBAR
  // ===============================================================

  void _showTopSnack(String title, String message, {bool isError = true}) {
    final cs = Theme.of(context).colorScheme;

    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? cs.errorContainer : cs.primaryContainer,
      colorText: isError ? cs.onErrorContainer : cs.onPrimaryContainer,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? cs.onErrorContainer : cs.onPrimaryContainer,
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: media.size.height * 0.9,
          ),
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: theme.bottomSheetTheme.backgroundColor ?? cs.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(cs),
                    _buildHeader(theme, cs),
                    // Divider(color: cs.outlineVariant, height: 1),
                    const SizedBox(height: 22),
                    _label('Phone Number', cs),
                    const SizedBox(height: 10),
                    _buildPhoneField(theme, cs),
                    const SizedBox(height: 24),
                    _label('Template', cs),
                    const SizedBox(height: 10),
                    _buildTemplateField(theme, cs),
                    const SizedBox(height: 28),
                    _buildSendButton(cs),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // UI PARTS
  // ===============================================================

  Widget _buildHandle(ColorScheme cs) {
    return Center(
      // child: Container(
      //   width: 42,
      //   height: 4,
      //   margin: const EdgeInsets.only(bottom: 8),
      //   decoration: BoxDecoration(
      //     color: cs.outline.withValues(alpha: 0.5),
      //     borderRadius: BorderRadius.circular(10),
      //   ),
      // ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'New Message',
            style: theme.textTheme.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // IconButton(
        //   onPressed: isSending
        //       ? null
        //       : () {
        //           FocusScope.of(context).unfocus();
        //           Get.back();
        //         },
        //   icon: Icon(Icons.close, color: cs.onSurface),
        // ),
      ],
    );
  }

  Widget _label(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(
        color: cs.onSurfaceVariant,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPhoneField(ThemeData theme, ColorScheme cs) {
    final hasFocus = phoneFocusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 58,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFocus ? cs.primary : cs.outlineVariant,
          width: hasFocus ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          // ---------------- COUNTRY ----------------
          InkWell(
            onTap: _openCountryPicker,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(13),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCountry.flagEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+${selectedCountry.phoneCode}',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: cs.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          Container(width: 1, height: 28, color: cs.outlineVariant),

          // ---------------- NUMBER ----------------
          Expanded(
            child: TextField(
              controller: phoneController,
              focusNode: phoneFocusNode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              cursorColor: cs.primary,
              style: TextStyle(color: cs.onSurface, fontSize: 17),
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                hintStyle: TextStyle(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),

          // ---------------- CONTACT BUTTON ----------------
          Padding(
            padding: const EdgeInsets.only(right: 7),
            child: Material(
              color: cs.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: isPickingContact ? null : _pickContact,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: isPickingContact
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: cs.primary,
                          ),
                        )
                      : Icon(
                          Icons.contacts_outlined,
                          color: cs.primary,
                          size: 23,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tapping opens the WhatsappTemplateScreen popup.
  Widget _buildTemplateField(ThemeData theme, ColorScheme cs) {
    final hasTemplate = selectedTemplate != null;

    String bodyPreview = selectedTemplateData?.preview ?? '';
    if (hasTemplate && bodyPreview.isEmpty) {
      final components = _safeList(() => selectedTemplate.components);
      for (final c in components) {
        if (_safeString(() => c.type).toUpperCase() == 'BODY') {
          bodyPreview = _safeString(() => c.text);
          break;
        }
      }
    }

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isSending ? null : _openTemplatePicker,
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasTemplate ? cs.primary : cs.outlineVariant,
              width: hasTemplate ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasTemplate
                    ? Icons.check_circle_rounded
                    : Icons.description_outlined,
                color: hasTemplate ? cs.primary : cs.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: hasTemplate
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedTemplateName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (bodyPreview.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              bodyPreview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Text(
                        'Choose template',
                        style: TextStyle(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 15,
                        ),
                      ),
              ),
              if (hasTemplate)
                IconButton(
                  tooltip: 'Clear',
                  visualDensity: VisualDensity.compact,
                  onPressed: isSending
                      ? null
                      : () => setState(() {
                          selectedTemplate = null;
                          selectedTemplateData = null;
                        }),
                  icon: Icon(
                    Icons.close_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: cs.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(ColorScheme cs) {
    final enabled = selectedTemplate != null && !isSending;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: enabled ? _sendMessage : null,
        icon: isSending
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: cs.onPrimary,
                ),
              )
            : const Icon(Icons.send_rounded, size: 20),
        label: Text(
          isSending ? 'Sending...' : 'Send Message',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // TEMPLATE PICKER (WhatsappTemplateScreen popup)
  // ===============================================================

  Future<void> _openTemplatePicker() async {
    phoneFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    final height = MediaQuery.of(context).size.height;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 30,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SizedBox(
              height: height * 0.8,
              child: WhatsappTemplateScreen(
                controller: controller,
                sendLabel: 'Select',
                onSend: (template) async {
                  // Popup to edit the variables ({{1}}, {{2}} ...)
                  final data = await showTemplateParamsEditor(
                    context,
                    template,
                    actionLabel: 'Done',
                  );

                  // Cancel: keep the template popup open
                  if (data == null) return false;

                  if (mounted) {
                    setState(() {
                      selectedTemplate = template;
                      selectedTemplateData = data;
                    });
                  }
                  return true; // the popup will close
                },
              ),
            ),
          ),
        );
      },
    );

    // Do not reopen the keyboard after the popup closes
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) phoneFocusNode.unfocus();
      });
    }
  }

  // ===============================================================
  // COUNTRY PICKER
  // ===============================================================

  void _openCountryPicker() {
    FocusScope.of(context).unfocus();
    final cs = Theme.of(context).colorScheme;

    showCountryPicker(
      context: context,
      showPhoneCode: true,
      showSearch: true,
      showDragHandle: true,
      favorite: _favoriteCodes,
      countryListTheme: CountryListThemeData(
        backgroundColor: cs.surface,
        textStyle: TextStyle(color: cs.onSurface, fontSize: 16),
        searchTextStyle: TextStyle(color: cs.onSurface),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: TextStyle(color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      onSelect: (Country country) {
        setState(() => selectedCountry = country);
      },
    );
  }

  // ===============================================================
  // VALIDATION
  // ===============================================================

  /// null = the number is valid, otherwise an error message.
  String? _validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Please enter a phone number.';
    }

    final code = selectedCountry.countryCode;
    final name = selectedCountry.name;
    final dial = '+${selectedCountry.phoneCode}';

    final (min, max) = _lengthRules[code] ?? _fallbackRange;

    if (phone.length < min || phone.length > max) {
      final expected = min == max ? 'exactly $min' : '$min-$max';
      return '$name ($dial) numbers must have $expected digits. '
          'You entered ${phone.length} digits.';
    }

    // India: mobile numbers start with 6-9
    if (code == 'IN' && !RegExp(r'^[6-9]').hasMatch(phone)) {
      return 'Indian mobile number 6, 7, 8 ya 9 se shuru hona chahiye.';
    }

    return null;
  }

  // ===============================================================
  // CONTACT NUMBER PARSING
  // ===============================================================

  ({Country country, String national})? _detectCountry(String digits) {
    final all = CountryService().getAll();

    for (int len = 4; len >= 1; len--) {
      if (digits.length <= len) continue;

      final prefix = digits.substring(0, len);
      final matches = all.where((c) => c.phoneCode == prefix).toList();

      if (matches.isEmpty) continue;

      final country = matches.firstWhere(
        (c) => _favoriteCodes.contains(c.countryCode),
        orElse: () => matches.first,
      );

      return (country: country, national: digits.substring(len));
    }

    return null;
  }

  ({Country country, String national}) _parseContactNumber(String raw) {
    final trimmed = raw.trim();
    final hasPlus = trimmed.startsWith('+');
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');

    if (hasPlus || digits.startsWith('00')) {
      if (!hasPlus) digits = digits.substring(2);

      final detected = _detectCountry(digits);
      if (detected != null) return detected;

      return (country: selectedCountry, national: digits);
    }

    final code = selectedCountry.phoneCode;
    if (digits.startsWith(code) && digits.length > 10) {
      return (
        country: selectedCountry,
        national: digits.substring(code.length),
      );
    }

    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return (country: selectedCountry, national: digits);
  }

  Future<void> _pickContact() async {
    FocusScope.of(context).unfocus();
    setState(() => isPickingContact = true);

    try {
      final permissionStatus = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (permissionStatus != PermissionStatus.granted) {
        if (mounted) _showPermissionMessage();
        return;
      }

      final Contact? contact = await FlutterContacts.native.showPicker(
        properties: {ContactProperty.phone},
      );

      if (contact == null) return;

      if (contact.phones.isEmpty) {
        if (mounted) {
          _showTopSnack(
            'No Phone Number',
            'Selected contact does not have a phone number.',
          );
        }
        return;
      }

      final parsed = _parseContactNumber(contact.phones.first.number);

      if (!mounted) return;

      setState(() => selectedCountry = parsed.country);

      phoneController.text = parsed.national;
      phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneController.text.length),
      );

      // NOTE: requestFocus is deliberately not called here,
      // otherwise the keyboard opened after picking a contact.
    } catch (e) {
      debugPrint('Contact picker error: $e');
      if (mounted) {
        _showTopSnack('Contact Error', 'Unable to access contacts.');
      }
    } finally {
      if (mounted) setState(() => isPickingContact = false);
    }
  }

  void _showPermissionMessage() {
    final cs = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          'Contact Permission Required',
          style: TextStyle(color: cs.onSurface),
        ),
        content: Text(
          'Please allow contact access to select a contact.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // HELPERS
  // ===============================================================

  List<dynamic> _safeList(dynamic Function() getter) {
    try {
      final v = getter();
      if (v == null) return [];
      return List<dynamic>.from(v as Iterable);
    } catch (_) {
      return [];
    }
  }

  String _safeString(dynamic Function() getter) {
    try {
      return getter()?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  // ===============================================================
  // SEND MESSAGE
  // ===============================================================

  Future<void> _sendMessage() async {
    if (isSending) return;

    phoneFocusNode.unfocus();

    final phone = phoneController.text.trim();

    // ---------- validation ----------
    final error = _validatePhone(phone);
    if (error != null) {
      _showTopSnack('Invalid Number', error);
      return;
    }

    final data = selectedTemplateData;

    if (selectedTemplate == null || data == null) {
      _showTopSnack('Template', 'Please choose a template first.');
      return;
    }

    // ---------- params (edited by the user) ----------
    final params = data.params;
    final headerParams = data.headerParams;
    final preview = data.preview;
    final name = data.name;
    final fullPhoneNumber = '+${selectedCountry.phoneCode}$phone';
    // ---------- API ----------
    final whatsappController = Get.find<WhatsappController>();

    setState(() => isSending = true);

    try {
      final response = await WhatsappMessageSand.sendWhatsappTemplate(
        hid: whatsappController.hid,
        phone: fullPhoneNumber,
        templateName: name,
        templateLanguage: data.language,
        templateParams: params,
        templateParamsHeader: headerParams,
      );

      final int status = response.statusCode as int;

      if (status < 200 || status >= 300) {
        throw Exception('Send failed: $status');
      }

      String? realMessageId;
      try {
        final decoded = jsonDecode(response.body);
        realMessageId = decoded['result']?['docs']?['messageId']?.toString();
      } catch (e) {
        debugPrint('TEMPLATE RESPONSE PARSE ERROR: $e');
      }

      _updateConversationList(
        whatsappController: whatsappController,
        fullPhone: fullPhoneNumber,
        text: preview.isEmpty ? name : preview,
        realMessageId: realMessageId,
      );

      if (!mounted) return;

      Get.back();

      _showTopSnack(
        'Message Sent',
        'Template "$name" sent to $fullPhoneNumber',
        isError: false,
      );
    } catch (e, st) {
      debugPrint('ADD CONTACT TEMPLATE SEND ERROR: $e');
      debugPrintStack(stackTrace: st);

      if (mounted) {
        _showTopSnack('Error', 'Message send nahi hua, dobara try karein.');
      }
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  void _updateConversationList({
    required WhatsappController whatsappController,
    required String fullPhone,
    required String text,
    String? realMessageId,
  }) {
    final target = _digitsOnly(fullPhone);

    final existing = whatsappController.conversations.firstWhereOrNull(
      (c) => _digitsOnly(c.phone) == target,
    );

    if (existing == null) {
      whatsappController.getConversations();
      return;
    }

    final tempId = 'temp_template_${DateTime.now().microsecondsSinceEpoch}';

    whatsappController.addSentMessageToCurrentConversation(
      phone: existing.phone,
      text: text,
      messageId: tempId,
      conversationId: existing.id,
    );

    if (realMessageId != null && realMessageId.isNotEmpty) {
      whatsappController.updateMessageId(tempId: tempId, realId: realMessageId);
    }
  }
}
