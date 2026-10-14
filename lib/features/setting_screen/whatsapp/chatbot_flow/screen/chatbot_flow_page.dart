// ============================================================
// WHATSAPP FLOW PAGE  (Settings > WhatsApp > WhatsApp Flow)
//
// Chatbot banane ki jagah (web ka FlowBuilder).
//   upar   : Canvas | List,  + Add step,  Refresh,  Publish
//   Canvas : steps ka naksha (kheencho, zoom, tap = edit)   [tablet / window]
//   List   : steps ek ke neeche ek (tap = edit)             [phone par pehle se]
//   Publish tak badlav sirf app me ("Unsaved changes")
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../screen/widgets/wa_form_widgets.dart';
import '../controller/chatbot_flow_controller.dart';
import '../models/chatbot_flow_models.dart';
import 'widgets/chatbot_canvas.dart';
import 'widgets/chatbot_node_editor.dart';

class ChatbotFlowPage extends StatefulWidget {
  const ChatbotFlowPage({super.key});

  @override
  State<ChatbotFlowPage> createState() => _ChatbotFlowPageState();
}

class _ChatbotFlowPageState extends State<ChatbotFlowPage> {
  final c = Get.put(ChatbotFlowController());
  bool _viewChosen = false;

  void _open(ChatbotNode node) => showChatbotNodeEditor(context, c, node);

  Future<void> _add() async {
    final p = SettingPalette(context);
    final type = await showModalBottomSheet<ChatbotNodeType>(
      context: context,
      backgroundColor: p.card,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a step',
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              for (final t in ChatbotNodeType.addable)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: t.color,
                    child: Icon(t.icon, color: Colors.white, size: 20),
                  ),
                  title: Text(t.label, style: TextStyle(color: p.text)),
                  subtitle: Text(
                    t.description,
                    style: TextStyle(color: p.subText, fontSize: 12),
                  ),
                  onTap: () => Navigator.pop(context, t),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (type == null || !mounted) return;

    final node = c.addNode(type);
    _open(node);
  }

  @override
  Widget build(BuildContext context) {
    return TResponsiveBuilder(
      builder: (context, r) {
        // Phone par pehli baar list, badi screen par canvas
        if (!_viewChosen) {
          c.view.value = r.isPhone ? ChatbotView.list : ChatbotView.canvas;
          _viewChosen = true;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Toolbar(c: c, r: r, onAdd: _add),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value && c.flowResponse.value == null) {
                  return const _Loading();
                }
                if (c.loadFailed.value) {
                  return _Message(
                    icon: Icons.cloud_off_outlined,
                    text: "Couldn't load the WhatsApp flow.",
                    action: TextButton.icon(
                      onPressed: c.load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  );
                }
                if (c.nodes.isEmpty) {
                  return _Message(
                    icon: Icons.account_tree_outlined,
                    text:
                        'No steps yet.\nStart with "Send Message" for the welcome text.',
                    action: ElevatedButton.icon(
                      style: waPrimaryButton(context),
                      onPressed: _add,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add first step'),
                    ),
                  );
                }

                return c.view.value == ChatbotView.canvas
                    ? ChatbotCanvas(c: c, onOpen: _open)
                    : _ListView(c: c, r: r, onOpen: _open);
              }),
            ),
          ],
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.c, required this.r, required this.onAdd});

  final ChatbotFlowController c;
  final TResponsive r;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.pagePadding, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Obx(() {
        final publishing = c.isPublishing.value;
        final changed = c.hasChanges.value;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            SegmentedButton<ChatbotView>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              segments: const [
                ButtonSegment(
                  value: ChatbotView.canvas,
                  icon: Icon(Icons.account_tree_outlined, size: 16),
                  label: Text('Canvas'),
                ),
                ButtonSegment(
                  value: ChatbotView.list,
                  icon: Icon(Icons.view_list_outlined, size: 16),
                  label: Text('List'),
                ),
              ],
              selected: {c.view.value},
              onSelectionChanged: (s) => c.view.value = s.first,
            ),
            Wrap(
              spacing: 4,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (changed)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      'Unsaved changes',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: 'Reload (drops unsaved changes)',
                  onPressed: publishing ? null : c.load,
                  icon: Icon(Icons.refresh, color: p.text),
                ),
                OutlinedButton.icon(
                  style: waOutlineButton(context),
                  onPressed: publishing ? null : onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add step'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: waPrimaryButton(
                    context,
                    color: const Color(0xFFFD5C01),
                  ),
                  onPressed: publishing || c.nodes.isEmpty ? null : c.publish,
                  icon: Icon(
                    publishing ? Icons.hourglass_top : Icons.publish,
                    size: 18,
                  ),
                  label: Text(publishing ? 'Publishing…' : 'Publish'),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

/// Phone: steps ek ke neeche ek (shuru wale pehle)
class _ListView extends StatelessWidget {
  const _ListView({required this.c, required this.r, required this.onOpen});

  final ChatbotFlowController c;
  final TResponsive r;
  final void Function(ChatbotNode node) onOpen;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    // Pehle START wale, phir canvas me upar-left se neeche-right
    final ordered = c.nodes.toList()
      ..sort((a, b) {
        final sa = c.isStart(a.id) ? 0 : 1;
        final sb = c.isStart(b.id) ? 0 : 1;
        if (sa != sb) return sa - sb;
        final byX = a.x.compareTo(b.x);
        return byX != 0 ? byX : a.y.compareTo(b.y);
      });

    return ListView(
      padding: EdgeInsets.all(r.pagePadding),
      children: [
        Text(
          'Tap a step to edit it and choose where each answer goes.',
          style: TextStyle(color: p.subText, fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        for (final n in ordered)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ChatbotNodeCard(
              node: n,
              c: c,
              expand: true,
              selected: c.selectedId.value == n.id,
              onOpen: () => onOpen(n),
            ),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: p.subText),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subText),
            ),
            if (action != null) ...[const SizedBox(height: 14), action!],
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget box() => Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [box(), box(), box()],
      ),
    );
  }
}
