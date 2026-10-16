// ============================================================
// WHATSAPP HANDLING FOOTER  (chat ke neeche: message box ya "Take over")
//
//   🤖 The AI is replying to this guest.          [ Take over ]
//   ⚙️ An automated flow is replying to this guest. [ Take over ]
//   👤 A teammate is replying to this conversation.
//   warna: message box  (+ upar chhota "Hand back to AI" jab maine liya ho)
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

  /// Asli message box (jab likhne ki ijazat ho)
  final Widget input;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // list badle (take over) to bhi dobara bane
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
// BAR (message box ki jagah)
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
                // Gol loader nahi: chalte waqt hourglass
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
// HAND BACK TO AI (message box ke upar chhota sa)
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
          Expanded(
            child: Text(
              'You are replying to this guest',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.subText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
// LOADING (pata chal raha hai kaun reply karega)
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
