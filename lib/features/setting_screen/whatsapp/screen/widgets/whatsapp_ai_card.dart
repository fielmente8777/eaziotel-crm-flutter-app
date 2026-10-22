// ============================================================
// AI CARD
//
// The "AI Configuration" card: AI switch, From / To time and
// Save button. The data is in controller.aiEnabled / aiFrom / aiTo.
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_setting_controller.dart';

/// "AI Configuration": AI on/off and until what time it stays on
class WhatsappAiCard extends StatelessWidget {
  const WhatsappAiCard({super.key, required this.controller, required this.r});

  final WhatsappSettingController controller;
  final TResponsive r;

  Future<void> _pick(BuildContext context, Rx<TimeOfDay> time) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time.value,
    );

    if (picked != null) time.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      child: Obx(() {
        final enabled = controller.aiEnabled.value;
        final from = controller.aiFrom.value;
        final to = controller.aiTo.value;

        final fromField = _TimeField(
          label: 'From Time',
          value: from.format(context),
          onTap: enabled ? () => _pick(context, controller.aiFrom) : null,
        );

        final toField = _TimeField(
          label: 'To Time',
          value: to.format(context),
          onTap: enabled ? () => _pick(context, controller.aiTo) : null,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI CONFIGURATION',
                        style: TextStyle(
                          color: p.subText,
                          fontSize: 10.5,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: p.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: (value) => controller.aiEnabled.value = value,
                ),
              ],
            ),
            Divider(height: 20, color: p.border),
            Text(
              'AI Active Duration',
              style: TextStyle(color: p.primary, fontSize: 12.5),
            ),
            const SizedBox(height: 8),

            // Phone: stacked. Side by side on big screens.
            if (r.isPhone) ...[
              fromField,
              const SizedBox(height: 10),
              toField,
            ] else
              Row(
                children: [
                  Expanded(child: fromField),
                  const SizedBox(width: 10),
                  Expanded(child: toField),
                ],
              ),

            const SizedBox(height: 8),
            Text(
              'AI will be active from ${from.format(context)} to ${to.format(context)}.',
              style: TextStyle(color: p.subText, fontSize: 11.5),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: settingSmallButton().copyWith(
                backgroundColor: const WidgetStatePropertyAll(
                  TAppColors.success,
                ),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: controller.isSavingAi.value
                  ? null
                  : controller.saveAiConfiguration,
              child: Text(
                controller.isSavingAi.value ? 'Saving…' : 'Save Configuration',
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: p.subText, fontSize: 11)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: onTap == null ? p.subText : p.text,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(Icons.schedule, size: 16, color: p.subText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
