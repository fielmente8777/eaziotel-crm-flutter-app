// ============================================================
// CHATBOT NODE EDITOR  (step par tap karne par)
//
//   upar   : step ka type
//   beech  : us type ka form (chatbot_step_editors.dart)
//   CONNECTIONS : har rasta (button / option / next) -> "Goes to" step
//                 (web me teer kheenchte hain; yahan dropdown se chunte hain,
//                  phone par bhi aasaan)
//   neeche : Delete step | Cancel | Save
//
// Data ki copy par kaam hota hai; Cancel = kuch nahi badla.
// Phone: neeche se sheet. Tablet / window: beech me dialog.
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:flutter/material.dart';

import '../../../../screen/widgets/setting_section_card.dart';
import '../../../screen/widgets/wa_form_widgets.dart';
import '../../controller/chatbot_flow_controller.dart';
import '../../models/chatbot_flow_models.dart';
import 'chatbot_step_editors.dart';

Future<void> showChatbotNodeEditor(
  BuildContext context,
  ChatbotFlowController c,
  ChatbotNode node,
) async {
  final editor = _NodeEditor(c: c, node: node);
  final p = SettingPalette(context);

  if (TResponsive.of(context).isPhone) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          FractionallySizedBox(heightFactor: .92, child: editor),
    );
  } else {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 620,
            maxHeight: MediaQuery.sizeOf(context).height * .88,
          ),
          child: editor,
        ),
      ),
    );
  }
}

class _NodeEditor extends StatefulWidget {
  const _NodeEditor({required this.c, required this.node});

  final ChatbotFlowController c;
  final ChatbotNode node;

  @override
  State<_NodeEditor> createState() => _NodeEditorState();
}

class _NodeEditorState extends State<_NodeEditor> {
  late final Map<String, dynamic> _data = chatbotDeepCopy(widget.node.data);

  /// rasta (handle key) -> step id
  late final Map<String, String?> _links = {
    for (final o in widget.node.outputs)
      o.key: widget.c.targetOf(widget.node.id, o.handle),
  };

  bool _saving = false;

  List<ChatbotOutput> get _outputs =>
      ChatbotNode.outputsOf(widget.node.typeKey, _data);

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.c.saveNode(
      id: widget.node.id,
      data: _data,
      connections: {for (final o in _outputs) o.key: _links[o.key]},
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this step?'),
        content: const Text('Its arrows will be removed too.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    widget.c.deleteNode(widget.node.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final type = widget.node.type;
    final others = widget.c.nodes.where((n) => n.id != widget.node.id);

    return Column(
      children: [
        // ---------- Header ----------
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          decoration: BoxDecoration(
            color: type.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Row(
            children: [
              Icon(type.icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (type.description.isNotEmpty)
                      Text(
                        type.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),

        // ---------- Form + connections ----------
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ChatbotStepEditor(
                c: widget.c,
                node: widget.node,
                data: _data,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 18),
              Divider(color: p.border),
              const SizedBox(height: 8),
              Text(
                'CONNECTIONS',
                style: TextStyle(
                  color: p.subText,
                  fontSize: 11,
                  letterSpacing: .8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose where the chat goes after each answer.',
                style: TextStyle(color: p.subText, fontSize: 12),
              ),
              const SizedBox(height: 10),
              for (final o in _outputs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          o.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 16, color: p.subText),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: WaDropdown<String>(
                          key: ValueKey('link-${o.key}-${_links[o.key]}'),
                          value: _links[o.key] ?? '',
                          items: {
                            '': '— Not connected —',
                            for (final n in others) n.id: widget.c.titleOf(n),
                          },
                          onChanged: (v) => setState(
                            () => _links[o.key] = v.isEmpty ? null : v,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (others.isEmpty)
                Text(
                  'Add another step first, then connect it here.',
                  style: TextStyle(color: p.subText, fontSize: 12),
                ),
            ],
          ),
        ),

        // ---------- Buttons ----------
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: Row(
            children: [
              // Chhoti screen par sirf icon
              if (MediaQuery.sizeOf(context).width < 480)
                IconButton(
                  tooltip: 'Delete step',
                  onPressed: _saving ? null : _delete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                )
              else
                TextButton.icon(
                  onPressed: _saving ? null : _delete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                ),
              const Spacer(),
              OutlinedButton(
                style: waOutlineButton(context),
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: waPrimaryButton(context, color: type.color),
                onPressed: _saving ? null : _save,
                icon: Icon(
                  _saving ? Icons.hourglass_top : Icons.check,
                  size: 18,
                ),
                label: Text(_saving ? 'Saving…' : 'Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
