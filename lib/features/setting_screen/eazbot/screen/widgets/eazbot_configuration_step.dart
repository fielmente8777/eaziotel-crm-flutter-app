// ============================================================
// STEP 3: CONFIGURATION
//
//   Basic Setup : messages, time interval, chaar switch
//   Questions   : chatbot ke sawal (on / off + text badalna)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/eazbot_setting_controller.dart';
import 'eazbot_common.dart';

class EazbotConfigurationStep extends StatefulWidget {
  const EazbotConfigurationStep({
    super.key,
    required this.controller,
    required this.wide,
  });

  final EazbotSettingController controller;
  final bool wide;

  @override
  State<EazbotConfigurationStep> createState() =>
      _EazbotConfigurationStepState();
}

class _EazbotConfigurationStepState extends State<EazbotConfigurationStep> {
  bool showQuestions = false;

  Widget _pair(Widget a, Widget b) {
    if (!widget.wide) {
      return Column(children: [a, const SizedBox(height: 10), b]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget tab(String label, bool selected, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configure Bot',
          style: TextStyle(
            color: p.text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            tab(
              'Basic Setup',
              !showQuestions,
              () => setState(() => showQuestions = false),
            ),
            tab(
              'Questions',
              showQuestions,
              () => setState(() => showQuestions = true),
            ),
          ],
        ),
        const SizedBox(height: 14),
        showQuestions ? _questions(p) : _basic(),
      ],
    );
  }

  Widget _basic() {
    final c = widget.controller;

    return Obx(
      () => Column(
        children: [
          _pair(
            EazbotField(
              label: 'Chat Terminate Message',
              controller: c.terminateMessage,
              hint: 'Thank you for chatting with us!',
            ),
            EazbotField(
              label: 'Fallback Message',
              controller: c.fallbackMessage,
              hint: "Sorry, I didn't understand that.",
            ),
          ),
          const SizedBox(height: 12),
          EazbotField(
            label: 'Time Interval (seconds)',
            controller: c.timeInterval,
            hint: '30',
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _pair(
            EazbotSwitch(
              label: 'Show Eazotel Branding',
              value: c.showBranding.value,
              onChanged: (v) => c.showBranding.value = v,
            ),
            EazbotSwitch(
              label: 'Show Typing Indicator',
              value: c.showTypingIndicator.value,
              onChanged: (v) => c.showTypingIndicator.value = v,
            ),
          ),
          const SizedBox(height: 10),
          _pair(
            EazbotSwitch(
              label: 'Enable Live Chat',
              value: c.enableLiveChat.value,
              onChanged: (v) => c.enableLiveChat.value = v,
            ),
            EazbotSwitch(
              label: 'Active',
              value: c.active.value,
              onChanged: (v) => c.active.value = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questions(SettingPalette p) {
    final c = widget.controller;

    return Obx(
      () => Column(
        children: [
          for (final q in c.questions)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // key: sawal badalne par purana text na rahe
                      key: ValueKey(q.key),
                      initialValue: q.question,
                      onChanged: (v) => c.setQuestionText(q, v),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        helperText: 'Answer type: ${q.type}',
                      ),
                    ),
                  ),
                  Switch(
                    value: q.active,
                    onChanged: (v) => c.setQuestionActive(q, v),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
