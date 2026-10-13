// ============================================================
// AUTO MESSAGE CARD
//
// "Auto Messaging Configuration" wala card.
// Isme paanch module hain (Eazbot Leads, Webform Leads ...).
// Har module me:
//   - switch            : on / off
//   - pehla dropdown    : Template ya Flow
//   - doosra dropdown   : kaunsa template / flow
//   - preview           : chune hue template ka message
//
// Data aur badlav sab WhatsappSettingController me hain.
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_setting_controller.dart';
import '../../models/auto_message_config.dart';

class WhatsappAutoMessageCard extends StatelessWidget {
  const WhatsappAutoMessageCard({super.key, required this.controller});

  final WhatsappSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto Messaging Configuration',
            style: TextStyle(
              color: p.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // ---------- "Apply same config to all modules" ----------
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Text(
                    'Apply same config to all modules',
                    style: TextStyle(color: p.text, fontSize: 12.5),
                  ),
                ),
                Checkbox(
                  value: controller.applyToAll.value,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) =>
                      controller.applyToAll.value = value ?? false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ---------- Paanch module ----------
          Obx(
            () => Column(
              children: [
                for (final module in controller.autoMessages)
                  _ModuleTile(
                    module: module,
                    controller: controller,
                    // options aur preview yahin (Obx ke andar) nikalte hain,
                    // taaki templates / flows aane par ye apne aap badlen
                    options: controller.optionsFor(module),
                    preview: controller.previewFor(module),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ek module ka dabba
class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.module,
    required this.controller,
    required this.options,
    required this.preview,
  });

  final AutoMessageConfig module;
  final WhatsappSettingController controller;

  /// Doosre dropdown ke option
  final List<String> options;

  /// Chune hue template ka message (na ho to null)
  final String? preview;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    // Chuna hua option list me na ho to dropdown ko khali rakho
    final selection = options.contains(module.selection)
        ? module.selection
        : null;

    final String selectionHint;
    if (options.isEmpty) {
      selectionHint = module.isFlow ? 'No flows found' : 'No templates found';
    } else {
      selectionHint = module.isFlow ? 'Select flow' : 'Select template';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Naam + switch ----------
          Row(
            children: [
              Expanded(
                child: Text(
                  module.label,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: module.enabled,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) =>
                    controller.setAutoMessageEnabled(module, value),
              ),
            ],
          ),

          // Switch off ho to neeche ka hissa nahi dikhta
          if (module.enabled) ...[
            // ---------- Template ya Flow ----------
            _Dropdown(
              value: module.type,
              hint: 'Type',
              options: AutoMessageConfig.types,
              onChanged: (value) {
                if (value != null) controller.setAutoMessageType(module, value);
              },
            ),
            const SizedBox(height: 8),

            // ---------- Kaunsa template / flow ----------
            _Dropdown(
              value: selection,
              hint: selectionHint,
              options: options,
              onChanged: (value) =>
                  controller.setAutoMessageSelection(module, value),
            ),

            // ---------- Template ka preview ----------
            if (preview != null) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: p.inner,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.border),
                ),
                child: Text(
                  preview!,
                  style: TextStyle(color: p.primary, fontSize: 12, height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Is card ke dono dropdown ka ek jaisa design
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

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: DropdownButtonFormField<String>(
        // key badalne par dropdown naya banta hai. Iske bina controller se
        // value badalne par bhi dropdown purana chuna hua hi dikhata hai.
        key: ValueKey('$hint-$value-${options.length}'),
        initialValue: value,
        isExpanded: true,
        isDense: true,
        dropdownColor: p.card,
        borderRadius: BorderRadius.circular(10),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: p.subText),
        style: TextStyle(color: p.text, fontSize: 13),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        hint: Text(hint, style: TextStyle(color: p.subText, fontSize: 13)),
        items: [
          for (final option in options)
            DropdownMenuItem<String>(
              value: option,
              child: Text(option, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
        // Option hi na hon to dropdown band (grey) rehta hai
        onChanged: options.isEmpty ? null : onChanged,
      ),
    );
  }
}
