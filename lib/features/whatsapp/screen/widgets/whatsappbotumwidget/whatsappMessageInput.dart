import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappbotumwidget/whatsappTemplate.dart';
import 'package:eazotel/features/whatsapp/services/whatsappMessegSand.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappMessageInput extends StatelessWidget {
  final WhatsappConversationDetailController controller;
  final WhatsappConversationModel chatdetail;
  final WhatsappController whatsappController;

  const WhatsappMessageInput({
    super.key,
    required this.controller,
    required this.chatdetail,
    required this.whatsappController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final createdDate = DateTime.tryParse(
      chatdetail.lastMessage!.createdAt.toString(),
    );

    final isWithin24Hours =
        createdDate != null &&
        DateTime.now().difference(createdDate.toLocal()) <=
            const Duration(hours: 24);

    final timeAgo = getTimeAgo(chatdetail.lastMessage!.createdAt);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TapmoateFooter(context, isWithin24Hours),

        // ============================================
        // PICKED IMAGE PREVIEW
        // ============================================
        Obx(() {
          final file = controller.pickedImage.value;

          if (file == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(file, height: 140, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: GestureDetector(
                    onTap: () => controller.pickedImage.value = null,
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? TAppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isDark
                          ? TAppColors.darkBorder
                          : TAppColors.lightBorder,
                    ),
                  ),

                  // ============================================
                  // 24 HOURS CHECK
                  // ============================================
                  child: isWithin24Hours
                      ? _whatappInputFiels(context, createdDate, timeAgo)
                      : _customScreen(context),
                ),
              ),

              // ============================================
              // SEND BUTTON (sirf 24 ghante ke andar)
              // ============================================
              if (isWithin24Hours) ...[
                const SizedBox(width: 6),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: TAppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Obx(
                    () => controller.isUploading.value
                        ? const Padding(
                            padding: EdgeInsets.all(13),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            onPressed: controller.sendMessage,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOOTER: FORM DROPDOWN + TEMPLATE BUTTON
  // ============================================================

  Padding _TapmoateFooter(BuildContext context, isWithin24Hours) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(),
        ),
        child: Row(
          children: [
            // Expanded must be the DIRECT child of Row, Obx goes inside it
            if (isWithin24Hours)
              Expanded(
                child: Obx(() {
                  final flows =
                      whatsappController.flow.value?.result?.docs?.flows ?? [];

                  final selectedId = whatsappController.selectedFlowId.value;

                  final validValue =
                      (selectedId.isEmpty ||
                          flows.any((f) => f.flowId == selectedId))
                      ? selectedId
                      : '';

                  return Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF15151D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFBFC0C8),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: validValue,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF15151D),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text(
                              flows.isEmpty ? 'No forms found' : 'Select Form',
                            ),
                          ),
                          for (final item in flows)
                            DropdownMenuItem<String>(
                              value: item.flowId ?? '',
                              child: Text(
                                item.flowName ?? 'Unnamed Form',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          final id = value ?? '';

                          whatsappController.selectedFlowId.value = id;

                          // A flow was picked -> open the "Set Flow" popup
                          if (id.isNotEmpty) {
                            _openFlowDialog(context, id);
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),

            const SizedBox(width: 12),

            Expanded(
              child: InkWell(
                onTap: () {
                  _showWhatsappTemplatePopup(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 44,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFBFC0C8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message_outlined),
                      HSpace(width: 12),
                      Text('Template'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FLOW POPUP ("Set Flow")
  // ============================================================

  Future<void> _openFlowDialog(BuildContext context, String flowId) async {
    final flows = whatsappController.flow.value?.result?.docs?.flows ?? [];

    final flow = flows.firstWhereOrNull((f) => f.flowId == flowId);

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return FlowSetupDialog(
          flowId: flowId,
          flowName: flow?.flowName ?? '',
          onSend: _sendFlow,
        );
      },
    );

    // Popup closed (Cancel / Send / X) -> reset dropdown so the same
    // form can be picked again.
    whatsappController.selectedFlowId.value = '';
  }

  // /// Called when the user taps "Send" in the popup.
  // /// Return true on success (popup closes), false on failure (popup stays).
  // Future<bool> _sendFlow(FlowSetupData data) async {
  //   try {
  //     final response = await WhatsappMessageSand.sendWhatsappFlow(
  //       hid: whatsappController.hid,
  //       phone: chatdetail.phone,
  //       flowId: data.flowId,
  //       header: data.header,
  //       body: data.body,
  //       footer: data.footer,
  //       ctaText: data.ctaText,
  //     );

  //     final int status = response.statusCode as int;

  //     return status >= 200 && status < 300;
  //   } catch (e) {
  //     debugPrint('SEND FLOW ERROR: $e');
  //     return false;
  //   }
  // }

  /// Called when the user taps "Send" in the popup.
  /// Return true on success (popup closes), false on failure (popup stays).
  Future<bool> _sendFlow(FlowSetupData data) {
    // Local chat + conversation list update, API call, temp id -> real id
    // sab WhatsappConversationDetailController -> WhatsappController me hota hai.
    return controller.sendFlowMessage(
      flowId: data.flowId,
      body: data.body,
      header: data.header,
      footer: data.footer,
      ctaText: data.ctaText,
    );
  }
  // ============================================================
  // NORMAL WHATSAPP INPUT
  // ============================================================

  Row _whatappInputFiels(
    BuildContext context,
    DateTime? createdDate,
    String timeAgo,
  ) {
    return Row(
      children: [
        // EMOJI
        IconButton(
          onPressed: () {
            debugPrint(createdDate.toString());
            debugPrint('time ago');
            debugPrint(timeAgo);
          },
          icon: Icon(
            Icons.emoji_emotions_outlined,
            color: Colors.grey.shade600,
          ),
        ),

        // TEXT
        Expanded(
          child: TextField(
            controller: controller.textController,
            minLines: 1,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Message',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // ATTACHMENT
        IconButton(
          onPressed: () => _showAttachmentSheet(context),
          icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
        ),

        // CAMERA
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ============================================================
  // ATTACHMENT BOTTOM SHEET (Gallery / Location)
  // ============================================================

  void _showAttachmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attachItem(Icons.photo_library, 'Gallery', Colors.purple, () {
                  Navigator.pop(sheetContext);
                  controller.pickImageFromGallery();
                }),
                _attachItem(Icons.location_on, 'Location', Colors.green, () {
                  Navigator.pop(sheetContext);
                  controller.pickCurrentLocation();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WHEN 24 HOURS ARE OVER
  // ============================================================

  Widget _customScreen(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                '24-hour messaging window has expired.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  // Soft Error Red
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TEMPLATE POPUP
  // ============================================================

  void _showWhatsappTemplatePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(vertical: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.80,
            padding: const EdgeInsets.all(0),
            child: WhatsappTemplateScreen(
              onSend: (template) => _sendTemplate(template),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TEMPLATE SEND
  // ============================================================

  Future<bool> _sendTemplate(dynamic template) {
    final components = _safeList(() => template.components);

    dynamic find(String type) {
      for (final c in components) {
        final t = _safeString(() => c.type);
        if (t.toUpperCase() == type) return c;
      }
      return null;
    }

    final body = find('BODY');
    final header = find('HEADER');

    // React logic: body.example.body_text[0] aur header.example.header_text
    // Agar model me field name alag ho (jaise body_text), to yahan badlo.
    final bodyText = _safeList(() => body?.example?.bodyText);

    final params = (bodyText.isNotEmpty && bodyText.first is List)
        ? (bodyText.first as List).map((e) => e.toString()).toList()
        : <String>[];

    final headerParams = _safeList(
      () => header?.example?.headerText,
    ).map((e) => e.toString()).toList();

    // Preview: {{1}}, {{2}} ko values se replace karo
    String preview = _safeString(() => body?.text);

    for (int i = 0; i < params.length; i++) {
      preview = preview.replaceAll('{{${i + 1}}}', params[i]);
    }

    final name = _safeString(() => template.name);
    final lang = _safeString(() => template.language);

    return controller.sendTemplateMessage(
      templateName: name,
      templateLanguage: lang.isEmpty ? 'en_US' : lang,
      templateParams: params,
      templateParamsHeader: headerParams,
      preview: preview.isEmpty ? name : preview,
    );
  }

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
}

// ============================================================
// FLOW POPUP DATA
// ============================================================

class FlowSetupData {
  final String flowId;
  final String flowName;
  final String header;
  final String body;
  final String footer;
  final String ctaText;

  const FlowSetupData({
    required this.flowId,
    required this.flowName,
    required this.header,
    required this.body,
    required this.footer,
    required this.ctaText,
  });
}

// ============================================================
// FLOW POPUP ("Set Flow")
// Header / Body* / Footer / CTA Button Text + Cancel / Send
// ============================================================

class FlowSetupDialog extends StatefulWidget {
  final String flowId;
  final String flowName;

  /// Return true on success -> popup closes.
  /// Return false (or throw) -> popup stays open with an error message.
  final Future<bool> Function(FlowSetupData data) onSend;

  const FlowSetupDialog({
    super.key,
    required this.flowId,
    required this.flowName,
    required this.onSend,
  });

  @override
  State<FlowSetupDialog> createState() => _FlowSetupDialogState();
}

class _FlowSetupDialogState extends State<FlowSetupDialog> {
  static const Color _bg = Color(0xFF14151A);
  static const Color _labelColor = Color(0xFF6B8DD6);
  static const Color _green = Color(0xFF00A94F);

  static const String _defaultCta = 'Fill Details';

  final TextEditingController _header = TextEditingController();
  final TextEditingController _body = TextEditingController(
    text: 'Please fill in your details below 👇',
  );
  final TextEditingController _footer = TextEditingController(
    text: 'Powered by Eazotel',
  );
  final TextEditingController _cta = TextEditingController(text: _defaultCta);

  bool _isSending = false;
  String? _bodyError;
  String? _sendError;

  @override
  void dispose() {
    _header.dispose();
    _body.dispose();
    _footer.dispose();
    _cta.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SEND
  // ------------------------------------------------------------

  Future<void> _handleSend() async {
    final body = _body.text.trim();

    if (body.isEmpty) {
      setState(() => _bodyError = 'Body is required');
      return;
    }

    setState(() {
      _isSending = true;
      _sendError = null;
    });

    bool ok = false;

    try {
      ok = await widget.onSend(
        FlowSetupData(
          flowId: widget.flowId,
          flowName: widget.flowName,
          header: _header.text.trim(),
          body: body,
          footer: _footer.text.trim(),
          // WhatsApp needs a button text, so fall back to the default
          ctaText: _cta.text.trim().isEmpty ? _defaultCta : _cta.text.trim(),
        ),
      );
    } catch (_) {
      ok = false;
    }

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSending = false;
        _sendError = 'Failed to send. Please try again.';
      });
    }
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- TITLE ----------------
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Set Flow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.flowName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Form: ${widget.flowName}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                InkWell(
                  onTap: _isSending
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ---------------- HEADER ----------------
            _label('Header'),
            _input(_header, maxLength: 60),

            const SizedBox(height: 16),

            // ---------------- BODY ----------------
            _label('Body', required: true),
            _input(
              _body,
              minLines: 4,
              maxLines: 4,
              maxLength: 1024,
              errorText: _bodyError,
              onChanged: (_) {
                if (_bodyError != null) setState(() => _bodyError = null);
              },
            ),

            const SizedBox(height: 16),

            // ---------------- FOOTER ----------------
            _label('Footer'),
            _input(_footer, maxLength: 60),

            const SizedBox(height: 16),

            // ---------------- CTA ----------------
            _label('CTA Button Text'),
            _input(_cta, maxLength: 20),

            if (_sendError != null) ...[
              const SizedBox(height: 12),
              Text(
                _sendError!,
                style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13),
              ),
            ],

            const SizedBox(height: 20),

            // ---------------- BUTTONS ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isSending
                      ? null
                      : () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    // Override app theme (infinite width breaks a Row)
                    minimumSize: const Size(0, 48),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: _isSending ? null : _handleSend,
                  style: ElevatedButton.styleFrom(
                    // Override app theme (infinite width breaks a Row)
                    minimumSize: const Size(0, 48),
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _green.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SMALL BUILDERS
  // ------------------------------------------------------------

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            color: _labelColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFFF4D4D)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller, {
    int minLines = 1,
    int maxLines = 1,
    int? maxLength,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white, width: 1),
    );

    return TextField(
      controller: controller,
      enabled: !_isSending,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        counterText: '',
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: _labelColor, width: 1.5),
        ),
        disabledBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.white38, width: 1),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFFFF4D4D), width: 1),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFFFF4D4D), width: 1.5),
        ),
      ),
    );
  }
}

// ============================================================
// TIME AGO
// ============================================================

String getTimeAgo(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return '';
  }

  final createdDate = DateTime.tryParse(dateString);

  if (createdDate == null) {
    return '';
  }

  final now = DateTime.now();

  final difference = now.difference(createdDate.toLocal());

  if (difference.isNegative) {
    return '0 min ago';
  }

  if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }

  if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  }

  if (difference.inMinutes > 0) {
    return '${difference.inMinutes} min ago';
  }

  return 'Just now';
}
