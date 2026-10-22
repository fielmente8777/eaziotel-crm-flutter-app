// ============================================================
// LEAD SOURCE LIST
//
// Lines for Webform / Eazbot / Whatsapp / Facebook / Google.
// Each line has: name, chosen members (chips) and an on / off switch.
// [channel] decides whether WhatsApp (number) or Email is shown.
//
//   phone           : name + switch on top, chips below at full width
//   tablet / window : name on the left, chips + switch on the right
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/notification_setting_controller.dart';
import '../../models/notification_config.dart';
import 'recipient_picker.dart';

class LeadSourceList extends StatelessWidget {
  const LeadSourceList({
    super.key,
    required this.controller,
    required this.channel,
    required this.r,
  });

  final NotificationSettingController controller;
  final NotificationChannel channel;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // when the team arrives, names show in the chips
      controller.dashboard.userNameResponse.value;

      return Column(
        children: [
          for (final source in controller.sources)
            _SourceRow(
              source: source,
              controller: controller,
              channel: channel,
              r: r,
            ),
        ],
      );
    });
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.source,
    required this.controller,
    required this.channel,
    required this.r,
  });

  final LeadSourceNotification source;
  final NotificationSettingController controller;
  final NotificationChannel channel;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final name = Text(
      source.label,
      style: TextStyle(
        color: p.text,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
    );

    final toggle = Switch(
      value: controller.isAllowed(source, channel),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onChanged: (value) => controller.setAllowed(source, channel, value),
    );

    final field = _RecipientField(
      source: source,
      controller: controller,
      channel: channel,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: r.isPhone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: name),
                    toggle,
                  ],
                ),
                const SizedBox(height: 6),
                field,
              ],
            )
          : Row(
              children: [
                Expanded(child: name),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: field,
                ),
                const SizedBox(width: 8),
                toggle,
              ],
            ),
    );
  }
}

/// Chips of the chosen members + a down arrow. Pressing it opens the picker.
class _RecipientField extends StatelessWidget {
  const _RecipientField({
    required this.source,
    required this.controller,
    required this.channel,
  });

  final LeadSourceNotification source;
  final NotificationSettingController controller;
  final NotificationChannel channel;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final values = controller.valuesOf(source, channel);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showRecipientPicker(
        context,
        controller: controller,
        source: source,
        channel: channel,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: p.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: values.isEmpty
                  ? Text(
                      'Select',
                      style: TextStyle(color: p.subText, fontSize: 12.5),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final value in values)
                          _Chip(
                            label: controller.labelOf(value, channel),
                            onRemove: () =>
                                controller.removeValue(source, channel, value),
                          ),
                      ],
                    ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: p.subText),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: p.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: p.primary, fontSize: 12)),
          InkWell(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 13, color: p.primary),
            ),
          ),
        ],
      ),
    );
  }
}
