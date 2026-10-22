import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:flutter/material.dart';

// ============================================================
// TEMPLATE SEND DATA
// ============================================================

/// Final data for sending the template.
/// params / headerParams are the values the user edited.
class TemplateSendData {
  final String name;
  final String language;
  final List<String> params;
  final List<String> headerParams;

  /// Body text with {{1}}, {{2}} already replaced by the values
  final String preview;

  const TemplateSendData({
    required this.name,
    required this.language,
    required this.params,
    required this.headerParams,
    required this.preview,
  });
}

final RegExp _variableRegex = RegExp(r'\{\{\s*(\w+)\s*\}\}');

/// Names of the distinct {{...}} variables in the text.
/// If they are numbers like {{1}}, {{2}}, in number order.
List<String> _variablesIn(String text) {
  final keys = <String>[];

  for (final match in _variableRegex.allMatches(text)) {
    final key = match.group(1)!;
    if (!keys.contains(key)) keys.add(key);
  }

  if (keys.every((k) => int.tryParse(k) != null)) {
    keys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }

  return keys;
}

String _fillVariables(String text, Map<String, String> values) {
  return text.replaceAllMapped(_variableRegex, (match) {
    final value = values[match.group(1)]?.trim() ?? '';
    return value.isEmpty ? match.group(0)! : value;
  });
}

TemplateComponent? _findComponent(WhatsappTemplate template, String type) {
  for (final component in template.components ?? <TemplateComponent>[]) {
    if ((component.type ?? '').toUpperCase() == type) return component;
  }
  return null;
}

// ============================================================
// OPEN EDITOR
// ============================================================

/// Popup to edit the template variables ({{1}}, {{2}} ...) before
/// sending. The fields are filled with the template's example values.
///
/// Cancel returns null. If the template has no variables the popup
/// does not open, and the data comes back directly.
Future<TemplateSendData?> showTemplateParamsEditor(
  BuildContext context,
  dynamic template, {
  String actionLabel = 'Send',
}) async {
  final WhatsappTemplate t = template as WhatsappTemplate;

  final bodyText = _findComponent(t, 'BODY')?.text ?? '';
  final headerText = _findComponent(t, 'HEADER')?.text ?? '';

  final name = t.name ?? '';
  final language = (t.language ?? '').isEmpty ? 'en_US' : t.language!;

  if (_variablesIn(bodyText).isEmpty && _variablesIn(headerText).isEmpty) {
    return TemplateSendData(
      name: name,
      language: language,
      params: const [],
      headerParams: const [],
      preview: bodyText.isEmpty ? name : bodyText,
    );
  }

  return showDialog<TemplateSendData>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TemplateParamsDialog(
      template: t,
      name: name,
      language: language,
      actionLabel: actionLabel,
    ),
  );
}

// ============================================================
// EDITOR DIALOG
// ============================================================

class _TemplateParamsDialog extends StatefulWidget {
  const _TemplateParamsDialog({
    required this.template,
    required this.name,
    required this.language,
    required this.actionLabel,
  });

  final WhatsappTemplate template;
  final String name;
  final String language;
  final String actionLabel;

  @override
  State<_TemplateParamsDialog> createState() => _TemplateParamsDialogState();
}

class _TemplateParamsDialogState extends State<_TemplateParamsDialog> {
  late final String _bodyText;
  late final String _headerText;

  late final List<String> _bodyKeys;
  late final List<String> _headerKeys;

  final Map<String, TextEditingController> _bodyControllers = {};
  final Map<String, TextEditingController> _headerControllers = {};

  @override
  void initState() {
    super.initState();

    final body = _findComponent(widget.template, 'BODY');
    final header = _findComponent(widget.template, 'HEADER');

    _bodyText = body?.text ?? '';
    _headerText = header?.text ?? '';

    _bodyKeys = _variablesIn(_bodyText);
    _headerKeys = _variablesIn(_headerText);

    // Pre-fill the fields with the example values
    final bodyExamples = body?.example?.bodyText;
    final bodyDefaults = (bodyExamples != null && bodyExamples.isNotEmpty)
        ? bodyExamples.first
        : <String>[];
    final headerDefaults = header?.example?.headerText ?? <String>[];

    for (int i = 0; i < _bodyKeys.length; i++) {
      _bodyControllers[_bodyKeys[i]] = TextEditingController(
        text: i < bodyDefaults.length ? bodyDefaults[i] : '',
      );
    }

    for (int i = 0; i < _headerKeys.length; i++) {
      _headerControllers[_headerKeys[i]] = TextEditingController(
        text: i < headerDefaults.length ? headerDefaults[i] : '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _bodyControllers.values) {
      c.dispose();
    }
    for (final c in _headerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> _values(Map<String, TextEditingController> source) {
    return source.map((key, c) => MapEntry(key, c.text));
  }

  // WhatsApp does not accept an empty variable
  bool get _allFilled {
    return _bodyControllers.values.every((c) => c.text.trim().isNotEmpty) &&
        _headerControllers.values.every((c) => c.text.trim().isNotEmpty);
  }

  void _submit() {
    if (!_allFilled) return;

    final preview = _fillVariables(_bodyText, _values(_bodyControllers));

    Navigator.of(context).pop(
      TemplateSendData(
        name: widget.name,
        language: widget.language,
        params: _bodyKeys.map((k) => _bodyControllers[k]!.text.trim()).toList(),
        headerParams: _headerKeys
            .map((k) => _headerControllers[k]!.text.trim())
            .toList(),
        preview: preview.isEmpty ? widget.name : preview,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Material(
          color: const Color(0xFF15151D),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreview(),
                      const SizedBox(height: 16),
                      for (final key in _headerKeys)
                        _buildField(
                          label: 'Header {{$key}}',
                          controller: _headerControllers[key]!,
                        ),
                      for (final key in _bodyKeys)
                        _buildField(
                          label: 'Body {{$key}}',
                          controller: _bodyControllers[key]!,
                        ),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 8, 6, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1C25),
        border: Border(bottom: BorderSide(color: Color(0xFF30313B))),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, color: Color(0xFFFF8A1F), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.name.isEmpty ? 'Edit template' : widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final header = _fillVariables(_headerText, _values(_headerControllers));
    final body = _fillVariables(_bodyText, _values(_bodyControllers));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF351A16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4B4B55), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREVIEW',
            style: TextStyle(
              color: Color(0xFF9999A3),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          if (header.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                header,
                style: const TextStyle(
                  color: Color(0xFFF2F2F5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFF2F2F5),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFBDBDC6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            minLines: 1,
            maxLines: 3,
            cursorColor: const Color(0xFFFF7200),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFF171820),
              hintText: 'Enter value',
              hintStyle: const TextStyle(color: Color(0xFF777783)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4A4B55)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFF7200)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final enabled = _allFilled;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF30313B))),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4A4B55)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFFDADAE0), fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: enabled ? _submit : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xFFFF7200)
                      : const Color(0xFFFF7200).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.actionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
