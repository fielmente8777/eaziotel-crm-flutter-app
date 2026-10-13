// ============================================================
// RECIPIENT PICKER
//
// Team members ki list checkbox ke saath. "Done" par chune hue members
// ka number (WhatsApp) ya email (Email) source me chala jata hai.
//
// Jo number / email pehle se chuna hai par kisi member ka nahi,
// wo bhi list me dikhta hai, taaki galti se na hate.
// ============================================================

import 'package:flutter/material.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/notification_setting_controller.dart';
import '../../models/notification_config.dart';

Future<void> showRecipientPicker(
  BuildContext context, {
  required NotificationSettingController controller,
  required LeadSourceNotification source,
  required NotificationChannel channel,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _RecipientPicker(
      controller: controller,
      source: source,
      channel: channel,
    ),
  );
}

class _RecipientPicker extends StatefulWidget {
  const _RecipientPicker({
    required this.controller,
    required this.source,
    required this.channel,
  });

  final NotificationSettingController controller;
  final LeadSourceNotification source;
  final NotificationChannel channel;

  @override
  State<_RecipientPicker> createState() => _RecipientPickerState();
}

class _RecipientPickerState extends State<_RecipientPicker> {
  bool get _isWhatsapp => widget.channel == NotificationChannel.whatsapp;

  /// value (number / email) -> screen ka naam
  late final Map<String, String> _options = _buildOptions();

  /// Abhi chune hue values
  late final Set<String> _selected = widget.controller
      .valuesOf(widget.source, widget.channel)
      .toSet();

  Map<String, String> _buildOptions() {
    final options = <String, String>{};

    for (final recipient in widget.controller.recipientsFor(widget.channel)) {
      final value = _isWhatsapp ? recipient.phone : recipient.email;
      options[value] = recipient.name;
    }

    // Pehle se chuna hua value jo kisi member ka nahi (ya alag format me hai)
    for (final value in widget.controller.valuesOf(
      widget.source,
      widget.channel,
    )) {
      final alreadyListed = options.keys.any(
        (key) =>
            widget.controller.labelOf(key, widget.channel) ==
                widget.controller.labelOf(value, widget.channel) &&
            _same(key, value),
      );

      if (!alreadyListed) {
        options[value] = widget.controller.labelOf(value, widget.channel);
      }
    }

    return options;
  }

  /// "9528295631" aur "919528295631" ek hi number hain
  bool _same(String a, String b) {
    if (!_isWhatsapp) return a.toLowerCase() == b.toLowerCase();

    String last10(String v) {
      final digits = v.replaceAll(RegExp(r'\D'), '');
      return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    }

    return last10(a) == last10(b);
  }

  bool _isChecked(String value) => _selected.any((s) => _same(s, value));

  void _toggle(String value, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(value);
      } else {
        _selected.removeWhere((s) => _same(s, value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return AlertDialog(
      backgroundColor: p.card,
      title: Text(
        '${widget.source.label} · ${_isWhatsapp ? 'WhatsApp' : 'Email'}',
        style: TextStyle(color: p.text, fontSize: 16),
      ),
      content: SizedBox(
        width: 380,
        child: _options.isEmpty
            ? Text(
                _isWhatsapp
                    ? 'No team member has a phone number.'
                    : 'No team member has an email.',
                style: TextStyle(color: p.subText),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final option in _options.entries)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _isChecked(option.key),
                      onChanged: (checked) =>
                          _toggle(option.key, checked ?? false),
                      title: Text(
                        option.value,
                        style: TextStyle(color: p.text, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        option.key,
                        style: TextStyle(color: p.subText, fontSize: 11.5),
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.controller.setValues(
              widget.source,
              widget.channel,
              _selected.toList(),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
