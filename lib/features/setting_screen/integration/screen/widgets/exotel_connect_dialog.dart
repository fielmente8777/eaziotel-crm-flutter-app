// ============================================================
// EXOTEL CONNECT DIALOG
//
// Exotel card par "Connect" dabane par khulta hai.
//   API Key, Auth Token, Sub Domain, Account SID, Virtual Number
//   Connect -> controller.connectExotel (POST /api/v1/call/auth/connect)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/integration_setting_controller.dart';

Future<void> showExotelConnectDialog(
  BuildContext context,
  IntegrationSettingController controller,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ExotelConnectDialog(controller: controller),
  );
}

class _ExotelConnectDialog extends StatefulWidget {
  const _ExotelConnectDialog({required this.controller});

  final IntegrationSettingController controller;

  @override
  State<_ExotelConnectDialog> createState() => _ExotelConnectDialogState();
}

class _ExotelConnectDialogState extends State<_ExotelConnectDialog> {
  final apiKey = TextEditingController();
  final authToken = TextEditingController();
  final subDomain = TextEditingController();
  final accountSid = TextEditingController();
  final virtualNumber = TextEditingController();

  bool showSecrets = false;
  String? error;

  @override
  void dispose() {
    for (final c in [apiKey, authToken, subDomain, accountSid, virtualNumber]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _connect() async {
    final result = await widget.controller.connectExotel(
      apiKey: apiKey.text,
      authToken: authToken.text,
      subDomain: subDomain.text,
      accountSid: accountSid.text,
      virtualNumber: virtualNumber.text,
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

    Widget field(
      String label,
      TextEditingController controller,
      String hint, {
      bool secret = false,
      TextInputType? keyboard,
    }) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: p.text, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              obscureText: secret && !showSecrets,
              keyboardType: keyboard,
              autocorrect: false,
              enableSuggestions: !secret,
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                suffixIcon: secret
                    ? IconButton(
                        onPressed: () =>
                            setState(() => showSecrets = !showSecrets),
                        icon: Icon(
                          showSecrets
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      );
    }

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
              Row(
                children: [
                  Icon(Icons.call_outlined, size: 20, color: p.text),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connect Exotel',
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
                'Enter your Exotel account details. They are saved securely.',
                style: TextStyle(color: p.primary, fontSize: 12),
              ),
              field('API Key', apiKey, 'Exotel API key', secret: true),
              field('Auth Token', authToken, 'Exotel API token', secret: true),
              field('Sub Domain', subDomain, 'e.g. api.exotel.com'),
              field('Account SID', accountSid, 'Exotel account SID'),
              field(
                'Virtual Number',
                virtualNumber,
                'Your Exotel number',
                keyboard: TextInputType.phone,
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
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final busy = widget.controller.isConnectingExotel.value;

                  return ElevatedButton.icon(
                    style: settingSmallButton(),
                    onPressed: busy ? null : _connect,
                    icon: const Icon(Icons.link, size: 18),
                    label: Text(busy ? 'Connecting...' : 'Connect'),
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
