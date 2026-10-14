// ============================================================
// AUTO MESSAGE CARD  (web ke AutoMessageCard jaisa)
//
// "Auto Messaging Configuration" wala card. Overview me bhi aur
// "Auto Message" menu me bhi yahi card dikhta hai.
//
//   upar   : "Apply same config to all modules" (koi module chalu ho tabhi)
//   module : Eazbot / Webform / Meta / Google / WhatsApp
//            switch on -> type: Template / Text / Flow (Flow sirf WhatsApp)
//              Template -> template chuno + poora preview
//              Text     -> apna message
//              Flow     -> chatbot flow chuno
//   neeche : "Save Configuration" (sirf jab kuch badla ho)
//
// [columns] 2 ho to module do column me (badi screen)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_setting_controller.dart';
import '../../message_templates/screen/widgets/template_preview.dart';
import '../../models/auto_message_config.dart';
import 'wa_form_widgets.dart';

class WhatsappAutoMessageCard extends StatelessWidget {
  const WhatsappAutoMessageCard({
    super.key,
    required this.controller,
    this.columns = 1,
  });

  final WhatsappSettingController controller;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      child: Obx(() {
        // Ye sab yahin padhe jaate hain, taaki badalte hi card bane
        final modules = controller.autoMessages.toList();
        final anyOn = controller.anyAutoMessageEnabled;
        final changed = controller.autoMessageChanged;
        final saving = controller.isSavingAutoMessage.value;
        final applyAll = controller.applyToAll.value;
        controller.templates.length;
        controller.flowIds.length;

        final tiles = [
          for (final m in modules)
            _ModuleTile(module: m, controller: controller),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Auto Messaging Configuration',
              style: TextStyle(
                color: p.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Send a WhatsApp message automatically when a new lead comes in.',
              style: TextStyle(color: p.subText, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // ---------- Apply to all ----------
            Opacity(
              opacity: anyOn ? 1 : .5,
              child: Material(
                color: p.inner,
                borderRadius: BorderRadius.circular(10),
                child: CheckboxListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  value: applyAll,
                  onChanged: anyOn
                      ? (v) => controller.toggleApplyToAll(v ?? false)
                      : null,
                  title: Text(
                    'Apply same config to all modules',
                    style: TextStyle(color: p.text, fontSize: 13),
                  ),
                  subtitle: Text(
                    anyOn
                        ? 'Copies the first enabled module to all'
                        : 'Turn on a module first',
                    style: TextStyle(color: p.subText, fontSize: 11.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ---------- Modules ----------
            if (columns <= 1)
              for (final t in tiles)
                Padding(padding: const EdgeInsets.only(bottom: 10), child: t)
            else
              LayoutBuilder(
                builder: (context, box) {
                  const gap = 10.0;
                  final width = (box.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final t in tiles) SizedBox(width: width, child: t),
                    ],
                  );
                },
              ),

            // ---------- Save ----------
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: changed
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: waPrimaryButton(
                            context,
                            color: Colors.green.shade600,
                          ),
                          onPressed: saving
                              ? null
                              : controller.saveAutoMessages,
                          icon: Icon(
                            saving ? Icons.hourglass_top : Icons.save,
                            size: 18,
                          ),
                          label: Text(
                            saving ? 'Saving...' : 'Save Configuration',
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        );
      }),
    );
  }
}

/// Ek module ka dabba
class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module, required this.controller});

  final AutoMessageConfig module;
  final WhatsappSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final m = module;

    void update(void Function(AutoMessageConfig m) change) =>
        controller.updateAutoMessage(m, change);

    final templates = controller.templateNames;
    final template = controller.templateNamed(m.templateName);
    final flows = controller.flowIds;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: m.enabled ? Colors.green.withValues(alpha: .5) : p.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- Naam + switch ----------
          Row(
            children: [
              Expanded(
                child: Text(
                  m.label,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: m.enabled,
                activeTrackColor: Colors.green,
                onChanged: (v) => update((x) => x.enabled = v),
              ),
            ],
          ),

          if (m.enabled) ...[
            const SizedBox(height: 4),

            // ---------- Type ----------
            WaDropdown<String>(
              key: ValueKey('${m.key}-type-${m.type}'),
              value: m.type,
              items: m.typeOptions,
              onChanged: (v) => update((x) => x.type = v),
            ),
            const SizedBox(height: 10),

            // ---------- Template ----------
            if (m.isTemplate) ...[
              if (templates.isEmpty)
                Text(
                  'No templates found. Create one in Message Templates.',
                  style: TextStyle(color: p.subText, fontSize: 12),
                )
              else
                WaDropdown<String>(
                  key: ValueKey('${m.key}-tpl-${m.templateName}'),
                  value: m.templateName,
                  items: {
                    '': 'Select template',
                    for (final name in templates) name: name,
                  },
                  onChanged: (v) => update((x) => x.templateName = v),
                ),
              if (template != null) ...[
                const SizedBox(height: 10),
                TemplatePreview.ofTemplate(template),
              ],
            ],

            // ---------- Text ----------
            if (m.isText)
              TextFormField(
                // Apply to all se dusre module ka text badle to box bhi badle
                key: ValueKey('${m.key}-msg-${controller.applyToAll.value}'),
                initialValue: m.message,
                minLines: 3,
                maxLines: 6,
                decoration: waInput(context, hint: 'Type the message...'),
                onChanged: (v) => update((x) => x.message = v),
              ),

            // ---------- Flow (sirf WhatsApp) ----------
            if (m.isFlow)
              flows.isEmpty
                  ? Text(
                      'No chatbot flow found. Build one in WhatsApp Flow.',
                      style: TextStyle(color: p.subText, fontSize: 12),
                    )
                  : WaDropdown<String>(
                      key: ValueKey('${m.key}-flow-${m.flowId}'),
                      value: m.flowId,
                      items: {
                        '': 'Select flow',
                        for (final id in flows) id: id,
                      },
                      onChanged: (v) => update((x) => x.flowId = v),
                    ),
          ],
        ],
      ),
    );
  }
}
