// ============================================================
// WIDGET CARD
//
// The "WhatsApp Widget Integration" card.
// Shows two code blocks (Option 1 and Option 2), each with a
// "Copy Code" button. The code is built by WhatsappWidgetCode (models).
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_setting_controller.dart';

class WhatsappWidgetCard extends StatelessWidget {
  const WhatsappWidgetCard({super.key, required this.controller});

  final WhatsappSettingController controller;

  /// Lines of the "Configuration Options" box: name -> meaning
  static const Map<String, String> _options = {
    'ndid': 'Visitor identifier.',
    'hid': 'Website identifier.',
    'phoneNumber': 'WhatsApp number that receives messages.',
    'message': 'Default WhatsApp message.',
    'pageUrl': 'Current page URL (API integration only).',
    'websiteName': 'Current website hostname (API integration only).',
  };

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      title: 'WhatsApp Widget Integration',
      subtitle: 'Choose one of the integration methods below.',
      child: Obx(() {
        // The code updates by itself when the phone number arrives
        final code = controller.widgetCode;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CodeBlock(
              title: 'Option 1: Widget Script (Recommended)',
              note:
                  'Paste this code before the closing </body> tag of your website.',
              code: code.script,
            ),
            const SizedBox(height: 16),
            _CodeBlock(
              title: 'Option 2: Manual API Integration',
              note:
                  'Use this if you want to manually trigger widget click tracking from your application.',
              code: code.manualApi,
            ),
            const SizedBox(height: 16),
            _Note(
              color: TAppColors.info,
              title: 'Configuration Options',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final option in _options.entries)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: '•  '),
                            TextSpan(
                              text: option.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' - ${option.value}'),
                          ],
                        ),
                        style: TextStyle(color: p.text, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _Note(
              color: TAppColors.success,
              title: 'Recommendation',
              child: Text(
                'Use Widget Script Integration unless you need custom behavior. '
                'It automatically handles widget rendering, click tracking, and WhatsApp redirection.',
                style: TextStyle(color: p.text, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.title,
    required this.note,
    required this.code,
  });

  final String title;
  final String note;
  final String code;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: code));

    Get.snackbar(
      'Copied',
      'Code copied to the clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _copy,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                foregroundColor: p.text,
                side: BorderSide(color: p.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.copy_rounded, size: 14),
              label: const Text('Copy Code', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(note, style: TextStyle(color: p.subText, fontSize: 11.5)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.inner,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.border),
          ),
          // So a long line does not go off screen: scroll sideways
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: TextStyle(
                color: p.primary,
                fontSize: 11.5,
                height: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.color, required this.title, required this.child});

  final Color color;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
