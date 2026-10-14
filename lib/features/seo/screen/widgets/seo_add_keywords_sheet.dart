// ============================================================
// ADD KEYWORDS  (Local SEO + Website SEO)
//
// Phone par neeche se sheet, tablet / window par beech me dialog.
//   - ek line / comma me ek keyword
//   - type karte hi keyword chip ban kar dikhte hain (x se hatao)
//   - kitne credit lagenge + kam ho to button band
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import 'seo_common.dart';

/// "a, B\nb" -> ["a", "b"]
List<String> parseSeoKeywords(String text) {
  final seen = <String>{};
  return text
      .split(RegExp(r'[\n,]'))
      .map((k) => k.trim().toLowerCase())
      .where((k) => k.isNotEmpty && seen.add(k))
      .toList();
}

Future<void> showSeoAddKeywords(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String hint,
  required Color color,
  required int perKeyword,
  required int? balance,
  required RxBool saving,
  required RxString error,

  /// Return: jud gaye (sheet band) ya nahi (error dikhao)
  required Future<bool> Function(List<String> keywords) onAdd,
}) async {
  error.value = '';

  final form = _AddKeywordsForm(
    title: title,
    subtitle: subtitle,
    hint: hint,
    color: color,
    perKeyword: perKeyword,
    balance: balance,
    saving: saving,
    error: error,
    onAdd: onAdd,
  );

  if (TResponsive.of(context).isPhone) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: SettingPalette(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => form,
    );
  } else {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: SettingPalette(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: form,
        ),
      ),
    );
  }

  error.value = '';
}

class _AddKeywordsForm extends StatefulWidget {
  const _AddKeywordsForm({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.color,
    required this.perKeyword,
    required this.balance,
    required this.saving,
    required this.error,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final String hint;
  final Color color;
  final int perKeyword;
  final int? balance;
  final RxBool saving;
  final RxString error;
  final Future<bool> Function(List<String>) onAdd;

  @override
  State<_AddKeywordsForm> createState() => _AddKeywordsFormState();
}

class _AddKeywordsFormState extends State<_AddKeywordsForm> {
  final _text = TextEditingController();
  List<String> _keywords = const [];

  @override
  void initState() {
    super.initState();
    _text.addListener(
      () => setState(() => _keywords = parseSeoKeywords(_text.text)),
    );
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _remove(String keyword) {
    final left = _keywords.where((k) => k != keyword).join('\n');
    _text.value = TextEditingValue(
      text: left,
      selection: TextSelection.collapsed(offset: left.length),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final ok = await widget.onAdd(_keywords);
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final cost = _keywords.length * widget.perKeyword;
    final balance = widget.balance;
    final canAfford = balance == null || balance >= cost;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.add, color: widget.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(color: p.subText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: p.subText),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _text,
              autofocus: true,
              minLines: 4,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              style: TextStyle(color: p.text),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: p.subText),
                filled: true,
                fillColor: p.inner,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: p.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: p.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.color, width: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'One per line or comma-separated · '
              '${_keywords.length} keyword(s) detected',
              style: TextStyle(color: p.subText, fontSize: 11.5),
            ),

            // Keyword chips (x se hatao)
            if (_keywords.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in _keywords)
                    InputChip(
                      label: Text(k),
                      labelStyle: TextStyle(color: p.text, fontSize: 12),
                      backgroundColor: widget.color.withValues(alpha: .1),
                      side: BorderSide(
                        color: widget.color.withValues(alpha: .3),
                      ),
                      deleteIconColor: p.subText,
                      onDeleted: () => _remove(k),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (canAfford ? widget.color : SeoColors.rose).withValues(
                    alpha: .08,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.toll_outlined,
                      size: 18,
                      color: canAfford ? widget.color : SeoColors.rose,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        canAfford
                            ? 'Will cost $cost credits '
                                  '(${widget.perKeyword} per keyword)'
                            : 'Not enough credits: need $cost, '
                                  'have $balance',
                        style: TextStyle(
                          color: canAfford ? p.text : SeoColors.rose,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Obx(() {
              final text = widget.error.value;
              if (text.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  text,
                  style: const TextStyle(color: SeoColors.rose, fontSize: 12.5),
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final saving = widget.saving.value;
                  final enabled = !saving && _keywords.isNotEmpty && canAfford;

                  return ElevatedButton.icon(
                    style: seoButton(widget.color),
                    onPressed: enabled ? _submit : null,
                    icon: saving
                        ? const SeoSpin(child: Icon(Icons.sync, size: 18))
                        : const Icon(Icons.add, size: 18),
                    label: Text(
                      saving
                          ? 'Analyzing…'
                          : _keywords.isEmpty
                          ? 'Track'
                          : 'Track ${_keywords.length}',
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
