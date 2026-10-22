// ============================================================
// STEP 1: BOT BUILDER
//
//   Intro     : what Eazbot does
//   Customize : pick a color + greeting message + small preview
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/eazbot_setting_controller.dart';
import 'eazbot_common.dart';

class EazbotBuilderStep extends StatelessWidget {
  const EazbotBuilderStep({super.key, required this.controller});

  final EazbotSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build Your Chatbot',
          style: TextStyle(
            color: p.text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _Section(
          title: 'Intro',
          icon: Icons.smart_toy_outlined,
          child: Text(
            'Eazbot is a chat widget for your website. It greets visitors, '
            'asks your questions (name, phone, dates ...) and saves the answers '
            'as leads in your dashboard.',
            style: TextStyle(color: p.subText, fontSize: 13, height: 1.5),
          ),
        ),
        _Section(
          title: 'Customize',
          icon: Icons.palette_outlined,
          initiallyOpen: true,
          child: _Customize(controller: controller),
        ),
      ],
    );
  }
}

class _Customize extends StatelessWidget {
  const _Customize({required this.controller});

  final EazbotSettingController controller;

  Future<void> _pickCustom(BuildContext context) async {
    final input = TextEditingController(
      text: EazbotSettingController.toHex(controller.color.value),
    );

    final picked = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pick Color'),
        content: TextField(
          controller: input,
          decoration: const InputDecoration(
            labelText: 'Hex color',
            hintText: '#F59E0B',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              EazbotSettingController.fromHex(input.text),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    input.dispose();
    if (picked != null) controller.color.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final selected = controller.color.value;
      final isCustom = !EazbotSettingController.presetColors.contains(selected);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick a color',
            style: TextStyle(color: p.subText, fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final color in EazbotSettingController.presetColors)
                _ColorDot(
                  color: color,
                  selected: color == selected,
                  onTap: () => controller.color.value = color,
                ),
              OutlinedButton.icon(
                onPressed: () => _pickCustom(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  foregroundColor: p.text,
                ),
                icon: Icon(
                  Icons.colorize,
                  size: 16,
                  color: isCustom ? selected : null,
                ),
                label: const Text('Pick Color'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          EazbotField(
            label: 'Greeting message',
            controller: controller.greeting,
            hint: 'Hi! How can we help you?',
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _Preview(
              color: selected,
              text: controller.greetingPreview.value,
            ),
          ),
        ],
      );
    });
  }
}

/// Small preview: greeting bubble + round chat button
class _Preview extends StatelessWidget {
  const _Preview({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text.isEmpty ? 'Greeting message' : text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.subText, fontSize: 12),
                ),
              ),
              Icon(Icons.close, size: 14, color: p.subText),
            ],
          ),
        ),
        const SizedBox(height: 6),
        CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: const Icon(
            Icons.chat_bubble_outline,
            size: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: selected ? 2.5 : 1),
        ),
        child: selected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

/// Box that opens and closes (Intro / Customize)
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyOpen = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyOpen,
          leading: Icon(icon, size: 18, color: p.primary),
          title: Text(
            title,
            style: TextStyle(
              color: p.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [child],
        ),
      ),
    );
  }
}
