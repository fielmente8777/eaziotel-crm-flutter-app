// ============================================================
// CALL NOTIFICATION BOX
//
// "Call Notification" switch, and three states:
//   Not Answered | Missed Call | Busy
// Each has: Template / Flow dropdown, which template / flow, and a preview.
//
//   phone           : all three stacked
//   tablet / window : all three in one row
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/notification_setting_controller.dart';
import '../../models/notification_config.dart';
import 'template_preview.dart';

class CallNotificationBox extends StatelessWidget {
  const CallNotificationBox({
    super.key,
    required this.controller,
    required this.r,
  });

  final NotificationSettingController controller;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Obx(() {
        final enabled = controller.callEnabled.value;

        // update the dropdowns when templates / flows arrive
        controller.templates.length;
        controller.flowIds.length;

        final columns = [
          for (final message in controller.callMessages)
            _CallColumn(message: message, controller: controller),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Title + switch ----------
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Call Notification',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: (value) => controller.callEnabled.value = value,
                ),
              ],
            ),

            // If the switch is off, the three columns are hidden
            if (enabled) ...[
              const SizedBox(height: 8),
              if (r.isPhone)
                for (final column in columns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: column,
                  )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < columns.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: columns[i]),
                      ],
                    ],
                  ),
                ),
            ],
          ],
        );
      }),
    );
  }
}

/// Box for one state (like "Missed Call")
class _CallColumn extends StatelessWidget {
  const _CallColumn({required this.message, required this.controller});

  final CallMessage message;
  final NotificationSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final options = controller.optionsFor(message);
    final selection = options.contains(message.selection)
        ? message.selection
        : null;
    final template = controller.templateFor(message);

    final String hint;
    if (options.isEmpty) {
      hint = message.isFlow ? 'No flows found' : 'No templates found';
    } else {
      hint = message.isFlow ? 'Select flow' : 'Select template';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.label,
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _Dropdown(
            value: message.type,
            hint: 'Type',
            options: CallMessage.types,
            onChanged: (value) {
              if (value != null) controller.setCallType(message, value);
            },
          ),
          const SizedBox(height: 8),
          _Dropdown(
            value: selection,
            hint: hint,
            options: options,
            onChanged: (value) => controller.setCallSelection(message, value),
          ),
          if (template != null) ...[
            const SizedBox(height: 10),
            TemplatePreview(template: template),
          ],
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.hint,
    required this.options,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return DropdownButtonFormField<String>(
      // Changing the key rebuilds the dropdown, otherwise the old value would show
      key: ValueKey('$hint-$value-${options.length}'),
      initialValue: value,
      isExpanded: true,
      isDense: true,
      dropdownColor: p.card,
      borderRadius: BorderRadius.circular(10),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: p.subText),
      style: TextStyle(color: p.text, fontSize: 12.5),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      hint: Text(hint, style: TextStyle(color: p.subText, fontSize: 12.5)),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text(option, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: options.isEmpty ? null : onChanged,
    );
  }
}
