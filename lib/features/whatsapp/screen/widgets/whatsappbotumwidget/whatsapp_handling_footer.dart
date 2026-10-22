// ============================================================
// WHATSAPP HANDLING FOOTER  (below the chat: message box or "Take over")
//
//   🤖 The AI is replying to this guest.          [ Take over ]
//   ⚙️ An automated flow is replying to this guest. [ Take over ]
//   👤 A teammate is replying to this conversation.
//   otherwise: message box  (+ a small "Hand back to AI" on top when I took over)
// ============================================================

import 'package:eazotel/features/whatsapp/controller/whatsapp_handling_controller.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsapp_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class WhatsappHandlingFooter extends StatelessWidget {
  const WhatsappHandlingFooter({
    super.key,
    required this.controller,
    required this.input,
  });

  final WhatsappHandlingController controller;

  /// The real message box (when typing is allowed)
  final Widget input;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // rebuild when the list changes too (take over)
      controller.whatsapp.conversations.length;

      switch (controller.mode) {
        case WaReplyMode.loading:
          return const _LoadingBar();

        case WaReplyMode.teammate:
          return const _HandlingBar(
            icon: Icons.support_agent_rounded,
            color: Color(0xFFF59E0B),
            text: 'A teammate is replying to this conversation.',
          );

        case WaReplyMode.ai:
          return _HandlingBar(
            icon: Icons.smart_toy_outlined,
            color: const Color(0xFF6366F1),
            text: 'The AI is replying to this guest.',
            busy: controller.isChanging.value,
            onTakeOver: controller.takeOver,
          );

        case WaReplyMode.flow:
          return _HandlingBar(
            icon: Icons.account_tree_outlined,
            color: const Color(0xFF0EA5E9),
            text: 'An automated flow is replying to this guest.',
            busy: controller.isChanging.value,
            onTakeOver: controller.stopFlow,
          );

        case WaReplyMode.me:
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HandBackRow(controller: controller),
              input,
            ],
          );

        case WaReplyMode.open:
          return input;
      }
    });
  }
}

// ============================================================
// BAR (in place of the message box)
// ============================================================

class _HandlingBar extends StatelessWidget {
  const _HandlingBar({
    required this.icon,
    required this.color,
    required this.text,
    this.onTakeOver,
    this.busy = false,
  });

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? onTakeOver;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: p.card,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: p.tint(color),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: p.onTint(color)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            if (onTakeOver != null) ...[
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: busy ? null : onTakeOver,
                style: FilledButton.styleFrom(
                  backgroundColor: WaPalette.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: WaPalette.green.withValues(
                    alpha: .55,
                  ),
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // No spinner: hourglass while running
                icon: Icon(
                  busy
                      ? Icons.hourglass_top_rounded
                      : Icons.front_hand_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Take over',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HAND BACK TO AI (a small one above the message box)
// ============================================================

class _HandBackRow extends StatelessWidget {
  const _HandBackRow({required this.controller});

  final WhatsappHandlingController controller;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);
    const color = Color(0xFF6366F1);

    return Container(
      width: double.infinity,
      color: p.wallpaper,
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 0),
      child: Row(
        children: [
          Icon(Icons.person_rounded, size: 15, color: p.accent),
          const SizedBox(width: 5),
          Expanded(child: _ReplyingText(color: p.subText)),
          Obx(() {
            final busy = controller.isChanging.value;

            return TextButton.icon(
              onPressed: busy ? null : () => controller.handBack(context),
              style: TextButton.styleFrom(
                foregroundColor: p.onTint(color),
                visualDensity: VisualDensity.compact,
              ),
              icon: Icon(
                busy ? Icons.hourglass_top_rounded : Icons.smart_toy_outlined,
                size: 16,
              ),
              label: const Text(
                'Hand back to AI',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// ANIMATED REPLYING STATUS
// ============================================================

class _ReplyingText extends StatefulWidget {
  const _ReplyingText({required this.color});

  final Color color;

  @override
  State<_ReplyingText> createState() => _ReplyingTextState();
}

class _ReplyingTextState extends State<_ReplyingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final Animation<int> _dots = StepTween(
    begin: 0,
    end: 4,
  ).animate(_controller);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = .75;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dots,
      builder: (context, child) {
        final count = _dots.value.clamp(0, 3);
        return Text.rich(
          TextSpan(
            text: 'You are replying',
            children: [
              TextSpan(text: '.' * count),
              TextSpan(
                text: '.' * (3 - count),
                style: const TextStyle(color: Colors.transparent),
              ),
            ],
          ),
          semanticsLabel: 'You are replying',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: widget.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

// ============================================================
// LOADING (finding out who will reply)
// ============================================================

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    return Container(
      color: p.wallpaper,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: SafeArea(
        top: false,
        child: Shimmer.fromColors(
          baseColor: p.border,
          highlightColor: Color.lerp(
            p.border,
            Colors.white,
            p.isDark ? .12 : .7,
          )!,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: p.card,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
