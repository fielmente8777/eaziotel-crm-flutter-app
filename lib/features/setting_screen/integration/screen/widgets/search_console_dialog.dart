// ============================================================
// SEARCH CONSOLE DIALOG
//
// "Configure the Google Search Console property for this hotel."
//   Property Type (dropdown) + Domain + Connected Google Email (optional)
//   Save Settings -> controller.saveSearchConsole
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/integration_setting_controller.dart';
import '../../models/gsc_settings.dart';

Future<void> showSearchConsoleDialog(
  BuildContext context,
  IntegrationSettingController controller,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => _SearchConsoleDialog(controller: controller),
  );
}

class _SearchConsoleDialog extends StatefulWidget {
  const _SearchConsoleDialog({required this.controller});

  final IntegrationSettingController controller;

  @override
  State<_SearchConsoleDialog> createState() => _SearchConsoleDialogState();
}

class _SearchConsoleDialogState extends State<_SearchConsoleDialog> {
  late GscPropertyType type = widget.controller.gsc.value.propertyType;
  late final domain = TextEditingController(
    text: widget.controller.gsc.value.rawDomain,
  );
  late final email = TextEditingController(
    // If there is no saved email, the connected Google account's email
    text: widget.controller.gsc.value.email.isNotEmpty
        ? widget.controller.gsc.value.email
        : widget.controller.google.value.email,
  );

  String? error;

  @override
  void dispose() {
    domain.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final result = await widget.controller.saveSearchConsole(
      type: type,
      domain: domain.text,
      email: email.text,
    );

    if (!mounted) return;

    if (result == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text(text, style: TextStyle(color: p.text, fontSize: 13)),
    );

    return Dialog(
      backgroundColor: p.card,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Title ----------
              Row(
                children: [
                  Icon(Icons.language, size: 20, color: p.text),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search Console',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: p.subText),
                  ),
                ],
              ),
              Text(
                'Configure the Google Search Console property for this hotel.',
                style: TextStyle(color: p.primary, fontSize: 12),
              ),

              // ---------- Property Type ----------
              label('Property Type'),
              DropdownButtonFormField<GscPropertyType>(
                initialValue: type,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true),
                items: [
                  for (final option in GscPropertyType.values)
                    DropdownMenuItem(value: option, child: Text(option.label)),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
              ),

              // ---------- Domain ----------
              label('Domain'),
              TextField(
                controller: domain,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'example.com',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Enter the bare domain. We'll format it correctly based on "
                'the property type above.',
                style: TextStyle(color: p.subText, fontSize: 11),
              ),

              // ---------- Email ----------
              label('Connected Google Email (optional)'),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'owner@example.com',
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12.5,
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // ---------- Save ----------
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final saving = widget.controller.isSavingGsc.value;

                  return ElevatedButton.icon(
                    style: settingSmallButton(),
                    onPressed: saving ? null : _save,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(saving ? 'Saving...' : 'Save Settings'),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
