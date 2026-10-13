// ============================================================
// EAZBOT COMMON
//
// Chaaron step ke kaam aane wale chhote widget:
//   EazbotField   : label + text box
//   EazbotSwitch  : label + switch wala dabba
//   EazbotStepper : upar ka 1-2-3-4 stepper
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/eazbot_setting_controller.dart';

class EazbotField extends StatelessWidget {
  const EazbotField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: p.subText, fontSize: 12.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          decoration: InputDecoration(isDense: true, hintText: hint),
        ),
      ],
    );
  }
}

class EazbotSwitch extends StatelessWidget {
  const EazbotSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: p.text, fontSize: 13)),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// 1 Bot Builder — 2 Profile — 3 Configuration — 4 Install
class EazbotStepper extends StatelessWidget {
  const EazbotStepper({super.key, required this.current, required this.onTap});

  final EazbotStep current;
  final ValueChanged<EazbotStep> onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final steps = EazbotStep.values;

    // Upar dots + lines, neeche labels. Har label apne hisse me fit hota hai,
    // isliye phone par bhi line bahar nahi jaati.
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: i <= current.index ? TAppColors.success : p.border,
                  ),
                ),
              InkWell(
                onTap: () => onTap(steps[i]),
                customBorder: const CircleBorder(),
                child: _Dot(index: i, current: current.index),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (var i = 0; i < steps.length; i++)
              Expanded(
                child: Text(
                  steps[i].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == steps.length - 1
                      ? TextAlign.right
                      : TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: i == current.index ? p.primary : p.subText,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.current});

  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final done = index < current;
    final now = index == current;

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? TAppColors.success : (now ? p.primary : p.card),
        border: Border.all(color: done || now ? Colors.transparent : p.border),
      ),
      child: done
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: now ? Colors.white : p.text,
              ),
            ),
    );
  }
}
