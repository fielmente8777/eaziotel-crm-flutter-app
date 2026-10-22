// ============================================================
// STEP 2: PROFILE
//
// Bot Name, Contact, Email, Description.
// On wide screens Name + Contact in one row.
// ============================================================

import 'package:flutter/material.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/eazbot_setting_controller.dart';
import 'eazbot_common.dart';

class EazbotProfileStep extends StatelessWidget {
  const EazbotProfileStep({
    super.key,
    required this.controller,
    required this.wide,
  });

  final EazbotSettingController controller;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final name = EazbotField(
      label: 'Bot Name',
      controller: controller.botName,
      hint: 'e.g. Hotel Assistant',
    );

    final contact = EazbotField(
      label: 'Contact',
      controller: controller.contact,
      hint: '1234567890',
      keyboard: TextInputType.phone,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bot Profile',
          style: TextStyle(
            color: p.text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: name),
              const SizedBox(width: 12),
              Expanded(child: contact),
            ],
          )
        else ...[
          name,
          const SizedBox(height: 12),
          contact,
        ],
        const SizedBox(height: 12),
        EazbotField(
          label: 'Email',
          controller: controller.email,
          hint: 'Enter your email',
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        EazbotField(
          label: 'Description',
          controller: controller.description,
          maxLines: 4,
        ),
      ],
    );
  }
}
