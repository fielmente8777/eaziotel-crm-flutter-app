// ============================================================
// STEP 4: INSTALL
//
// Website me lagane wala script (Next.js aur Plain HTML), Copy button ke saath.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/eazbot_setting_controller.dart';

class EazbotInstallStep extends StatelessWidget {
  const EazbotInstallStep({super.key, required this.controller});

  final EazbotSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Install',
          style: TextStyle(
            color: p.text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Publish your bot, then paste one of these codes into your website.',
          style: TextStyle(color: p.subText, fontSize: 12.5),
        ),
        const SizedBox(height: 14),
        _CodeBox(title: 'Next.js', code: controller.nextJsCode),
        const SizedBox(height: 14),
        _CodeBox(title: 'Plain HTML', code: controller.htmlCode),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.title, required this.code});

  final String title;
  final String code;

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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                Get.snackbar(
                  'Copied',
                  '$title code copied',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: const Icon(Icons.copy, size: 15),
              label: const Text('Copy Code'),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.inner,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: TextStyle(
                color: p.text,
                fontSize: 11.5,
                fontFamily: 'monospace',
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
