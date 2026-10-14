// ============================================================
// CHATBOT STEP EDITORS  (har step type ka form, web jaisi limit ke saath)
//
//   Send Message : Message / Image / Video / Audio / Document jodo
//   Buttons      : header (60), body (1024), footer (60), 3 button (20)
//   List         : header, body (4096), footer, list button (20),
//                  section (24) + option (24)
//   Question     : sawaal, variable, jawab ka type, required
//   Carousel     : body, button type (CTA URL / Quick Reply), 10 card tak
//                  (photo link ya upload, description, button)
//   Form Flow    : header, body, footer, kaunsa form, button ka naam (30)
//
// Sab form seedha `data` (copy) badalte hain aur onChanged bulate hain.
// Button / option ki id kabhi nahi badalti, isliye juda hua teer
// (connection) nahi tootta. (Web me har save par nayi id banti thi.)
// ============================================================

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../screen/widgets/setting_section_card.dart';
import '../../../screen/widgets/wa_form_widgets.dart';
import '../../controller/chatbot_flow_controller.dart';
import '../../models/chatbot_flow_models.dart';

class ChatbotStepEditor extends StatelessWidget {
  const ChatbotStepEditor({
    super.key,
    required this.c,
    required this.node,
    required this.data,
    required this.onChanged,
  });

  final ChatbotFlowController c;
  final ChatbotNode node;
  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    switch (node.type) {
      case ChatbotNodeType.sendMessage:
        return _SendMessageEditor(c: c, data: data, onChanged: onChanged);
      case ChatbotNodeType.button:
        return _ButtonsEditor(data: data, onChanged: onChanged);
      case ChatbotNodeType.list:
        return _ListEditor(data: data, onChanged: onChanged);
      case ChatbotNodeType.question:
        return _QuestionEditor(data: data, onChanged: onChanged);
      case ChatbotNodeType.carousel:
        return _CarouselEditor(data: data, onChanged: onChanged);
      case ChatbotNodeType.flow:
        return _FlowEditor(c: c, data: data, onChanged: onChanged);
      case ChatbotNodeType.unknown:
        return Text(
          'This step type can only be edited on the web dashboard.',
          style: TextStyle(color: SettingPalette(context).subText),
        );
    }
  }
}

// ============================================================
// HELPERS
// ============================================================

/// m[key] ko Map bana kar do (na ho to bana do)
Map<String, dynamic> _obj(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v is Map<String, dynamic>) return v;
  final fresh = v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  m[key] = fresh;
  return fresh;
}

/// m[key] ko List bana kar do
List<dynamic> _arr(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v is List) return v;
  final fresh = <dynamic>[];
  m[key] = fresh;
  return fresh;
}

Map<String, dynamic> _interactive(Map<String, dynamic> data) =>
    _obj(data, 'interactive');

String _text(Map<String, dynamic> m, String key) =>
    (m[key] is Map ? (m[key] as Map)['text'] : null)?.toString() ?? '';

/// Header / footer: khali ho to hata do (web jaisa)
void _setOptional(Map<String, dynamic> m, String key, String text) {
  if (text.trim().isEmpty) {
    m.remove(key);
  } else {
    m[key] = key == 'header' ? {'type': 'text', 'text': text} : {'text': text};
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.onChanged,
    this.max,
    this.lines = 1,
    this.hint,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int? max;
  final int lines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WaLabel(max == null ? label : '$label (max $max)'),
          TextFormField(
            initialValue: value,
            maxLength: max,
            minLines: lines,
            maxLines: lines == 1 ? 1 : lines + 3,
            decoration: waInput(context, hint: hint).copyWith(counterText: ''),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _addButton(BuildContext context, String label, VoidCallback? onTap) =>
    Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        style: waOutlineButton(context),
        onPressed: onTap,
        icon: const Icon(Icons.add, size: 18),
        label: Text(label),
      ),
    );

// ============================================================
// HEADER / BODY / FOOTER (Buttons, List, Flow me same)
// ============================================================

class _TextParts extends StatelessWidget {
  const _TextParts({
    required this.data,
    required this.onChanged,
    required this.bodyMax,
    this.bodyHint,
  });

  final Map<String, dynamic> data;
  final VoidCallback onChanged;
  final int bodyMax;
  final String? bodyHint;

  @override
  Widget build(BuildContext context) {
    final i = _interactive(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          label: 'Header text (optional)',
          value: _text(i, 'header'),
          max: 60,
          onChanged: (v) {
            _setOptional(i, 'header', v);
            onChanged();
          },
        ),
        _Field(
          label: 'Body text',
          value: _text(i, 'body'),
          max: bodyMax,
          lines: 3,
          hint: bodyHint,
          onChanged: (v) {
            i['body'] = {'text': v};
            onChanged();
          },
        ),
        _Field(
          label: 'Footer text (optional)',
          value: _text(i, 'footer'),
          max: 60,
          onChanged: (v) {
            _setOptional(i, 'footer', v);
            onChanged();
          },
        ),
      ],
    );
  }
}

// ============================================================
// SEND MESSAGE
// ============================================================

class _SendMessageEditor extends StatefulWidget {
  const _SendMessageEditor({
    required this.c,
    required this.data,
    required this.onChanged,
  });

  final ChatbotFlowController c;
  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  @override
  State<_SendMessageEditor> createState() => _SendMessageEditorState();
}

class _SendMessageEditorState extends State<_SendMessageEditor> {
  static const _kinds = {
    'text': ('Message', Icons.notes),
    'image': ('Image', Icons.image_outlined),
    'video': ('Video', Icons.videocam_outlined),
    'audio': ('Audio', Icons.audiotrack_outlined),
    'document': ('Document', Icons.description_outlined),
  };

  List<dynamic> get _blocks => _arr(widget.data, 'blocks');

  void _changed() {
    setState(() {});
    widget.onChanged();
  }

  void _add(String type) {
    _blocks.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'title': '',
      'file': false,
      'url': null,
    });
    _changed();
  }

  Future<void> _pick(Map block) async {
    final type = block['type'];
    final file = await FilePicker.pickFile(
      type: switch (type) {
        'image' => FileType.image,
        'video' => FileType.video,
        'audio' => FileType.audio,
        _ => FileType.custom,
      },
      allowedExtensions: type == 'document'
          ? const ['pdf', 'doc', 'docx', 'txt']
          : null,
    );
    final path = file?.path;
    if (path == null) return;

    block['_localPath'] = path;
    block['file'] = true;
    block['url'] = null;
    block.remove('media'); // nayi file, purani hatao
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_blocks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Add what this step should send. Each item goes as a separate '
              'WhatsApp message.',
              style: TextStyle(color: p.subText, fontSize: 12.5),
            ),
          ),
        for (final raw in List.of(_blocks))
          if (raw is Map) _block(context, raw),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in _kinds.entries)
              ActionChip(
                avatar: Icon(k.value.$2, size: 16),
                label: Text(k.value.$1),
                onPressed: () => _add(k.key),
              ),
          ],
        ),
      ],
    );
  }

  Widget _block(BuildContext context, Map block) {
    final p = SettingPalette(context);
    final type = '${block['type']}';
    final kind = _kinds[type] ?? ('Item', Icons.circle_outlined);
    final id = '${block['id']}';

    // Photo: nayi chuni, pehle chuni (Publish baaki), ya server wali
    final local = block['_localPath']?.toString() ?? widget.c.pendingFiles[id];
    final mediaId = block['media'] is Map ? block['media']['mediaId'] : null;
    final hasFile = local != null || mediaId != null || block['file'] == true;

    Widget? preview;
    if (type == 'image' && local != null) {
      preview = Image.file(File(local), height: 120, fit: BoxFit.cover);
    } else if (type == 'image' && mediaId != null) {
      preview = Image.network(
        widget.c.mediaUrl('$mediaId'),
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    return Container(
      key: ValueKey('block-$id'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 12),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(kind.$2, size: 16, color: p.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  kind.$1,
                  style: TextStyle(
                    color: p.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  _blocks.remove(block);
                  _changed();
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (type != 'text') ...[
                  if (preview != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: preview,
                    ),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(
                    style: waOutlineButton(context),
                    onPressed: () => _pick(block),
                    icon: Icon(
                      hasFile ? Icons.swap_horiz : Icons.upload,
                      size: 18,
                    ),
                    label: Text(
                      local != null
                          ? local.split(RegExp(r'[\\/]')).last
                          : hasFile
                          ? 'Uploaded · tap to change'
                          : 'Upload ${kind.$1.toLowerCase()}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (local != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Uploads when you Publish',
                        style: TextStyle(color: p.subText, fontSize: 11),
                      ),
                    ),
                ],
                if (type == 'text' || type == 'image') ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: '${block['title'] ?? ''}',
                    minLines: type == 'text' ? 3 : 1,
                    maxLines: 6,
                    decoration: waInput(
                      context,
                      hint: type == 'text'
                          ? 'Enter message...'
                          : 'Enter caption...',
                    ),
                    onChanged: (v) {
                      block['title'] = v;
                      widget.onChanged();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BUTTONS
// ============================================================

class _ButtonsEditor extends StatefulWidget {
  const _ButtonsEditor({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  @override
  State<_ButtonsEditor> createState() => _ButtonsEditorState();
}

class _ButtonsEditorState extends State<_ButtonsEditor> {
  List<dynamic> get _buttons =>
      _arr(_obj(_interactive(widget.data), 'action'), 'buttons');

  void _changed() {
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    _interactive(widget.data)['type'] = 'button';
    widget.data['type'] = 'interactive';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TextParts(
          data: widget.data,
          onChanged: widget.onChanged,
          bodyMax: 1024,
          bodyHint: 'Ask a question here',
        ),
        _SectionTitle('Buttons (max 3)'),
        for (var i = 0; i < _buttons.length; i++)
          _buttonRow(
            context,
            i,
            _obj(_buttons[i] as Map<String, dynamic>, 'reply'),
          ),
        _addButton(
          context,
          'Add button',
          _buttons.length >= 3
              ? null
              : () {
                  _buttons.add({
                    'type': 'reply',
                    'reply': {
                      'id': chatbotId('btn_${_buttons.length + 1}'),
                      'title': 'Answer ${_buttons.length + 1}',
                    },
                  });
                  _changed();
                },
        ),
      ],
    );
  }

  Widget _buttonRow(
    BuildContext context,
    int index,
    Map<String, dynamic> reply,
  ) {
    return Padding(
      key: ValueKey('btn-${reply['id']}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: '${reply['title'] ?? ''}',
              maxLength: 20,
              decoration: waInput(
                context,
                hint: 'Button ${index + 1}',
              ).copyWith(counterText: ''),
              onChanged: (v) {
                reply['title'] = v;
                widget.onChanged();
              },
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: _buttons.length <= 1
                ? null
                : () {
                    _buttons.removeAt(index);
                    _changed();
                  },
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LIST
// ============================================================

class _ListEditor extends StatefulWidget {
  const _ListEditor({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  @override
  State<_ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<_ListEditor> {
  Map<String, dynamic> get _action => _obj(_interactive(widget.data), 'action');
  List<dynamic> get _sections => _arr(_action, 'sections');

  void _changed() {
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    _interactive(widget.data)['type'] = 'list';
    widget.data['type'] = 'interactive';
    _action['button'] ??= 'Choose';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TextParts(
          data: widget.data,
          onChanged: widget.onChanged,
          bodyMax: 4096,
          bodyHint: 'Select an option',
        ),
        _Field(
          label: 'List button text',
          value: '${_action['button']}',
          max: 20,
          onChanged: (v) {
            _action['button'] = v;
            widget.onChanged();
          },
        ),
        for (var s = 0; s < _sections.length; s++)
          Builder(
            builder: (context) {
              final section = _sections[s] as Map<String, dynamic>;
              final rows = _arr(section, 'rows');

              return Container(
                key: ValueKey('section-$s-${_sections.length}'),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.inner,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: '${section['title'] ?? ''}',
                            maxLength: 24,
                            decoration: waInput(
                              context,
                              hint: 'Section title',
                            ).copyWith(counterText: ''),
                            onChanged: (v) {
                              section['title'] = v;
                              widget.onChanged();
                            },
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove section',
                          onPressed: _sections.length <= 1
                              ? null
                              : () {
                                  _sections.removeAt(s);
                                  _changed();
                                },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var r = 0; r < rows.length; r++)
                      Padding(
                        key: ValueKey('row-${(rows[r] as Map)['id']}'),
                        padding: const EdgeInsets.only(bottom: 6, left: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.radio_button_unchecked,
                              size: 16,
                              color: p.subText,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextFormField(
                                initialValue:
                                    '${(rows[r] as Map)['title'] ?? ''}',
                                maxLength: 24,
                                decoration: waInput(
                                  context,
                                  hint: 'Option',
                                ).copyWith(counterText: ''),
                                onChanged: (v) {
                                  (rows[r] as Map)['title'] = v;
                                  widget.onChanged();
                                },
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove option',
                              onPressed: rows.length <= 1
                                  ? null
                                  : () {
                                      rows.removeAt(r);
                                      _changed();
                                    },
                              icon: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _addButton(context, 'Add option', () {
                        rows.add({
                          'id': chatbotId('row_${s + 1}_${rows.length + 1}'),
                          'title': 'New Option',
                        });
                        _changed();
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        _addButton(context, 'Add section', () {
          _sections.add({
            'title': 'New Section',
            'rows': [
              {
                'id': chatbotId('row_${_sections.length + 1}_1'),
                'title': 'New Option',
              },
            ],
          });
          _changed();
        }),
      ],
    );
  }
}

// ============================================================
// QUESTION
// ============================================================

class _QuestionEditor extends StatefulWidget {
  const _QuestionEditor({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  static const _types = {
    'text': 'Text',
    'number': 'Number',
    'email': 'Email',
    'phone': 'Phone',
  };

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    // Purane data me sawaal "message" me hota tha
    d['question'] ??= d['message'] ?? '';
    final type = _types.containsKey(d['type']) ? '${d['type']}' : 'text';
    d['type'] = type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          label: 'Question',
          value: '${d['question']}',
          lines: 2,
          hint: 'Ask something...',
          onChanged: (v) {
            d['question'] = v;
            widget.onChanged();
          },
        ),
        _Field(
          label: 'Save answer in variable',
          value: '${d['variable'] ?? ''}',
          hint: 'example: user_name',
          onChanged: (v) {
            d['variable'] = v;
            widget.onChanged();
          },
        ),
        const WaLabel('Answer type'),
        WaDropdown<String>(
          key: ValueKey('qtype-$type'),
          value: type,
          items: _types,
          onChanged: (v) {
            setState(() => d['type'] = v);
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Answer is required'),
          value: d['required'] == true,
          onChanged: (v) {
            setState(() => d['required'] = v);
            widget.onChanged();
          },
        ),
      ],
    );
  }
}

// ============================================================
// FORM FLOW
// ============================================================

class _FlowEditor extends StatefulWidget {
  const _FlowEditor({
    required this.c,
    required this.data,
    required this.onChanged,
  });

  final ChatbotFlowController c;
  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  @override
  State<_FlowEditor> createState() => _FlowEditorState();
}

class _FlowEditorState extends State<_FlowEditor> {
  Map<String, dynamic> get _params =>
      _obj(_obj(_interactive(widget.data), 'action'), 'parameters');

  /// Web jaisa: "Sign up" -> "SIGN_UP"
  static String _screenId(String title) => title
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final i = _interactive(widget.data);
    i['type'] = 'flow';
    widget.data['type'] = 'interactive';
    final action = _obj(i, 'action');
    action['name'] = 'flow';
    final params = _params;
    params['flow_message_version'] = '3';
    params['flow_action'] = 'navigate';
    final payload = _obj(params, 'flow_action_payload');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TextParts(
          data: widget.data,
          onChanged: widget.onChanged,
          bodyMax: 1024,
          bodyHint: 'Please fill in your details below 👇',
        ),
        const WaLabel('Form to open'),
        Obx(() {
          final flows = widget.c.formFlows.toList();
          if (flows.isEmpty) {
            return Text(
              'No forms yet. Create one in Flows > Create Flow.',
              style: TextStyle(color: p.subText, fontSize: 12.5),
            );
          }
          final current = '${params['flow_id'] ?? ''}';
          return WaDropdown<String>(
            key: ValueKey('flow-$current-${flows.length}'),
            value: current,
            items: {
              '': 'Select a flow',
              for (final f in flows)
                if ((f.flowId ?? '').isNotEmpty)
                  f.flowId!: f.flowName ?? f.flowId!,
            },
            onChanged: (v) {
              params['flow_id'] = v;
              final flow = flows.firstWhereOrNull((f) => f.flowId == v);
              final first = flow?.screens?.firstOrNull?.title;
              if (first != null) payload['screen'] = _screenId(first);
              setState(() {});
              widget.onChanged();
            },
          );
        }),
        if ('${payload['screen'] ?? ''}'.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Opens screen: ${payload['screen']}',
              style: TextStyle(color: p.subText, fontSize: 12),
            ),
          ),
        const SizedBox(height: 12),
        _Field(
          label: 'Button text',
          value: '${params['flow_cta'] ?? 'Fill Details'}',
          max: 30,
          onChanged: (v) {
            params['flow_cta'] = v;
            widget.onChanged();
          },
        ),
      ],
    );
  }
}

// ============================================================
// CAROUSEL
// ============================================================

class _CarouselEditor extends StatefulWidget {
  const _CarouselEditor({required this.data, required this.onChanged});

  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  @override
  State<_CarouselEditor> createState() => _CarouselEditorState();
}

class _CarouselEditorState extends State<_CarouselEditor> {
  List<dynamic> get _cards =>
      _arr(_obj(_interactive(widget.data), 'action'), 'cards');

  /// cta_url / quick_reply (sab card me ek jaisa, web jaisa)
  late String _buttonType =
      _cards.isNotEmpty &&
          (_cards.first is Map) &&
          chatbotList(
            chatbotMap((_cards.first as Map)['action'])['buttons'],
          ).isNotEmpty
      ? 'quick_reply'
      : 'cta_url';

  void _changed() {
    // card_index hamesha 0, 1, 2 ...
    for (var i = 0; i < _cards.length; i++) {
      (_cards[i] as Map)['card_index'] = i;
    }
    setState(() {});
    widget.onChanged();
  }

  Map<String, dynamic> _actionFor(String type, [int index = 0]) =>
      type == 'quick_reply'
      ? {
          'buttons': [
            {
              'type': 'quick_reply',
              'quick_reply': {
                'id': chatbotId('card_${index}_btn_0'),
                'title': 'Option 1',
              },
            },
          ],
        }
      : {
          'name': 'cta_url',
          'parameters': {'display_text': 'Click', 'url': 'https://example.com'},
        };

  void _setType(String type) {
    _buttonType = type;
    for (var i = 0; i < _cards.length; i++) {
      (_cards[i] as Map)['action'] = _actionFor(type, i);
    }
    _changed();
  }

  void _addCard() {
    if (_cards.length >= 10) {
      Get.snackbar(
        'Limit reached',
        'You can add up to 10 cards.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    _cards.add({
      'id': chatbotId(),
      'card_index': _cards.length,
      'type': 'cta_url',
      'header': {
        'type': 'image',
        'image': {'link': ''},
      },
      'action': _actionFor(_buttonType, _cards.length),
    });
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    final i = _interactive(widget.data);
    i['type'] = 'carousel';
    widget.data['type'] = 'interactive';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          label: 'Message',
          value: _text(i, 'body'),
          max: 1024,
          lines: 2,
          hint: 'Choose an option',
          onChanged: (v) {
            i['body'] = {'text': v};
            widget.onChanged();
          },
        ),
        const WaLabel('Button type (all cards)'),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'cta_url', label: Text('Website link')),
            ButtonSegment(value: 'quick_reply', label: Text('Quick reply')),
          ],
          selected: {_buttonType},
          onSelectionChanged: (s) => _setType(s.first),
        ),
        const SizedBox(height: 12),
        _SectionTitle('Cards (${_cards.length}/10)'),
        for (var c = 0; c < _cards.length; c++)
          _card(context, c, _cards[c] as Map<String, dynamic>),
        _addButton(context, 'Add card', _cards.length >= 10 ? null : _addCard),
      ],
    );
  }

  Widget _card(BuildContext context, int index, Map<String, dynamic> card) {
    final p = SettingPalette(context);
    final header = _obj(card, 'header');
    final image = _obj(header, 'image');
    final local = card['_localImage']?.toString();
    final link = '${image['link'] ?? ''}';
    final action = _obj(card, 'action');
    final params = _obj(action, 'parameters');
    final buttons = chatbotList(action['buttons']);

    Widget preview;
    if (local != null) {
      preview = Image.file(File(local), fit: BoxFit.cover);
    } else if (link.startsWith('http')) {
      preview = Image.network(
        link,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Icon(Icons.broken_image_outlined, color: p.subText),
      );
    } else {
      preview = Icon(Icons.image_outlined, size: 32, color: p.subText);
    }

    return Container(
      key: ValueKey('card-${card['id']}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Card ${index + 1}',
                style: TextStyle(color: p.text, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove card',
                onPressed: () {
                  _cards.removeAt(index);
                  _changed();
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 90,
                  height: 70,
                  color: p.card,
                  alignment: Alignment.center,
                  child: preview,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: waOutlineButton(context),
                  onPressed: () async {
                    final file = await FilePicker.pickFile(
                      type: FileType.image,
                    );
                    if (file?.path == null) return;
                    card['_localImage'] = file!.path;
                    _changed();
                  },
                  icon: const Icon(Icons.upload, size: 18),
                  label: Text(
                    local == null ? 'Upload image' : 'Uploads on Save',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: link,
            decoration: waInput(
              context,
              hint: 'or paste image link (https://...)',
            ),
            onChanged: (v) {
              image['link'] = v.trim();
              card.remove('_localImage');
              widget.onChanged();
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _text(card, 'body'),
            maxLength: 160,
            decoration: waInput(
              context,
              hint: 'Card description',
            ).copyWith(counterText: ''),
            onChanged: (v) {
              if (v.trim().isEmpty) {
                card.remove('body');
              } else {
                card['body'] = {'text': v};
              }
              widget.onChanged();
            },
          ),
          const SizedBox(height: 8),
          if (_buttonType == 'cta_url') ...[
            TextFormField(
              initialValue: '${params['display_text'] ?? ''}',
              maxLength: 20,
              decoration: waInput(
                context,
                hint: 'Button text',
              ).copyWith(counterText: ''),
              onChanged: (v) {
                params['display_text'] = v;
                widget.onChanged();
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: '${params['url'] ?? ''}',
              keyboardType: TextInputType.url,
              decoration: waInput(context, hint: 'https://yourhotel.com/offer'),
              onChanged: (v) {
                params['url'] = v.trim();
                widget.onChanged();
              },
            ),
          ] else ...[
            for (var b = 0; b < buttons.length; b++)
              Builder(
                builder: (context) {
                  final qr = _obj(
                    buttons[b] as Map<String, dynamic>,
                    'quick_reply',
                  );
                  return Padding(
                    key: ValueKey('qr-${qr['id']}'),
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: '${qr['title'] ?? ''}',
                            maxLength: 20,
                            decoration: waInput(
                              context,
                              hint: 'Button ${b + 1}',
                            ).copyWith(counterText: ''),
                            onChanged: (v) {
                              qr['title'] = v;
                              widget.onChanged();
                            },
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          onPressed: buttons.length <= 1
                              ? null
                              : () {
                                  buttons.removeAt(b);
                                  _changed();
                                },
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            _addButton(
              context,
              'Add button',
              buttons.length >= 2
                  ? null
                  : () {
                      _arr(action, 'buttons').add({
                        'type': 'quick_reply',
                        'quick_reply': {
                          'id': chatbotId(
                            'card_${index}_btn_${buttons.length}',
                          ),
                          'title': 'New Button',
                        },
                      });
                      _changed();
                    },
            ),
          ],
        ],
      ),
    );
  }
}
