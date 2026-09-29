import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappbotumwidget/whatsappTemplate.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappMessageInput extends StatelessWidget {
  final WhatsappConversationDetailController controller;
  final WhatsappConversationModel chatdetail;

  const WhatsappMessageInput({
    super.key,
    required this.controller,
    required this.chatdetail,
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

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 120),
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
          // SEND BUTTON (sirf 24 ghante ke andar text ke liye)
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
              child: IconButton(
                onPressed: controller.sendMessage,
                icon: const Icon(Icons.send, color: Colors.white, size: 21),
              ),
            ),
          ],
        ],
      ),
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
          onPressed: () {},
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
  // WHEN 24 HOURS ARE OVER
  // ============================================================

  Widget _customScreen(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () {
        _showWhatsappTemplatePopup(context);
      },
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Icon(Icons.message_outlined, color: TAppColors.primary, size: 22),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Select WhatsApp Template',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TAppColors.primary,
                ),
              ),
            ),

            Icon(Icons.keyboard_arrow_right, color: Colors.grey.shade600),
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.80,
            padding: const EdgeInsets.all(16),
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
