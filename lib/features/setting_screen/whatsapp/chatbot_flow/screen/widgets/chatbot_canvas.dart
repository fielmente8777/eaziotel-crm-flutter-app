// ============================================================
// CHATBOT CANVAS  (web ke React Flow jaisa)
//
//   - har step ek card (upar rangeen patti = kheench kar jagah badlo)
//   - card par tap = editor khulta hai
//   - right side ke gole = rasta (button / option / next),
//     wahan se agle step tak teer
//   - do ungli / mouse wheel se zoom, khali jagah se pan
//
// Card ki height fix hisaab se banti hai (ChatbotLayout), taaki teer
// theek gole se shuru ho.
// ============================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../screen/widgets/setting_section_card.dart';
import '../../controller/chatbot_flow_controller.dart';
import '../../models/chatbot_flow_models.dart';

class ChatbotLayout {
  ChatbotLayout._();

  static const double width = 250;
  static const double header = 40;
  static const double summary = 60;
  static const double output = 32;
  static const double bottom = 8;

  static double heightOf(ChatbotNode n) =>
      header + summary + n.outputs.length * output + bottom;

  /// Rasta (output) ka gola: card ke right kinare par
  static Offset portOf(ChatbotNode n, int index) =>
      Offset(n.x + width, n.y + header + summary + index * output + output / 2);

  /// Teer yahan aakar lagta hai: card ke left kinare par
  static Offset inputOf(ChatbotNode n) => Offset(n.x, n.y + header / 2);
}

class ChatbotCanvas extends StatelessWidget {
  const ChatbotCanvas({super.key, required this.c, required this.onOpen});

  final ChatbotFlowController c;
  final void Function(ChatbotNode node) onOpen;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final nodes = c.nodes.toList();
      final edges = c.edges.toList();
      final selected = c.selectedId.value;

      // Canvas ka size: sab card + jagah. Minus position wale card ke liye
      // sab ko thoda right / neeche khiska kar dikhate hain.
      double minX = 0, minY = 0, maxX = 1200, maxY = 800;
      for (final n in nodes) {
        minX = math.min(minX, n.x);
        minY = math.min(minY, n.y);
        maxX = math.max(maxX, n.x + ChatbotLayout.width);
        maxY = math.max(maxY, n.y + ChatbotLayout.heightOf(n));
      }
      final shift = Offset(60 - minX, 60 - minY);
      final size = Size(maxX - minX + 600, maxY - minY + 500);

      return ClipRect(
        child: Container(
          color: p.inner,
          child: InteractiveViewer(
            constrained: false,
            minScale: 0.3,
            maxScale: 2,
            boundaryMargin: const EdgeInsets.all(400),
            child: SizedBox.fromSize(
              size: size,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPainter(color: p.border),
                      foregroundPainter: _EdgePainter(
                        nodes: nodes,
                        edges: edges,
                        shift: shift,
                        fallback: p.subText,
                      ),
                    ),
                  ),
                  for (final n in nodes)
                    Positioned(
                      left: n.x + shift.dx,
                      top: n.y + shift.dy,
                      child: ChatbotNodeCard(
                        node: n,
                        c: c,
                        selected: n.id == selected,
                        onOpen: () => onOpen(n),
                        onDrag: (d) => c.moveNode(n.id, d),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Ek step ka card (canvas par fix size, list me poori chaudai)
class ChatbotNodeCard extends StatelessWidget {
  const ChatbotNodeCard({
    super.key,
    required this.node,
    required this.c,
    required this.onOpen,
    this.selected = false,
    this.onDrag,
    this.expand = false,
  });

  final ChatbotNode node;
  final ChatbotFlowController c;
  final VoidCallback onOpen;
  final bool selected;

  /// null = kheench nahi sakte (list view)
  final ValueChanged<Offset>? onDrag;

  /// List view: poori chaudai, height apne aap
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final type = node.type;
    final outputs = node.outputs;
    final start = c.isStart(node.id);

    final header = Container(
      height: ChatbotLayout.header,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: type.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          if (onDrag != null) ...[
            const Icon(Icons.drag_indicator, color: Colors.white70, size: 18),
            const SizedBox(width: 2),
          ],
          Icon(type.icon, color: Colors.white, size: 17),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${c.nodes.indexOf(node) + 1}. ${type.label}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          if (start)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );

    final summary = Container(
      height: expand ? null : ChatbotLayout.summary,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      alignment: Alignment.topLeft,
      child: Text(
        node.summary,
        maxLines: expand ? 4 : 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: p.text, fontSize: 12, height: 1.3),
      ),
    );

    final rows = [
      for (final o in outputs)
        SizedBox(
          height: ChatbotLayout.output,
          child: _OutputRow(
            output: o,
            target: c.nodeById(c.targetOf(node.id, o.handle)),
            c: c,
            color: type.color,
          ),
        ),
    ];

    final card = Material(
      color: p.card,
      elevation: selected ? 6 : 1.5,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          c.selectedId.value = node.id;
          onOpen();
        },
        child: Container(
          width: expand ? double.infinity : ChatbotLayout.width,
          height: expand ? null : ChatbotLayout.heightOf(node),
          // Border upar se (andar jagah na le, warna height bigad jaati)
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? type.color : p.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              onDrag == null
                  ? header
                  : GestureDetector(
                      onPanStart: (_) => c.selectedId.value = node.id,
                      onPanUpdate: (d) => onDrag!(d.delta),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: header,
                      ),
                    ),
              summary,
              ...rows,
              const SizedBox(height: ChatbotLayout.bottom),
            ],
          ),
        ),
      ),
    );

    return card;
  }
}

class _OutputRow extends StatelessWidget {
  const _OutputRow({
    required this.output,
    required this.target,
    required this.c,
    required this.color,
  });

  final ChatbotOutput output;
  final ChatbotNode? target;
  final ChatbotFlowController c;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: output.label,
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: target == null
                          ? '  → not connected'
                          : '  → ${c.nodes.indexOf(target!) + 1}. ${target!.type.label}',
                      style: TextStyle(
                        color: target == null ? p.subText : color,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Rasta ka gola (teer yahin se nikalta hai)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 0),
            decoration: BoxDecoration(
              color: target == null ? p.card : color,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: .7);
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

class _EdgePainter extends CustomPainter {
  _EdgePainter({
    required this.nodes,
    required this.edges,
    required this.shift,
    required this.fallback,
  });

  final List<ChatbotNode> nodes;
  final List<ChatbotEdge> edges;
  final Offset shift;
  final Color fallback;

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final n in nodes) n.id: n};

    for (final e in edges) {
      final from = byId[e.source];
      final to = byId[e.target];
      if (from == null || to == null) continue;

      final outputs = from.outputs;
      var index = outputs.indexWhere((o) => o.key == e.handleKey);
      if (index < 0) index = 0;
      if (outputs.isEmpty) continue;

      final a = ChatbotLayout.portOf(from, index) + shift;
      final b = ChatbotLayout.inputOf(to) + shift;
      final bend = math.max(60.0, (b.dx - a.dx).abs() / 2);

      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx + bend, a.dy, b.dx - bend, b.dy, b.dx, b.dy);

      final color = from.type == ChatbotNodeType.unknown
          ? fallback
          : from.type.color;
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Teer ki nok
      final arrow = Path()
        ..moveTo(b.dx, b.dy)
        ..lineTo(b.dx - 9, b.dy - 5)
        ..lineTo(b.dx - 9, b.dy + 5)
        ..close();
      canvas.drawPath(arrow, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) => true;
}
