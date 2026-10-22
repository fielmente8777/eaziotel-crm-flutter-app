// ============================================================
// TEAM HEADER
//
// "Team Members", the member count and the "Add New User" button.
//   phone          : button below the title, full width
//   tablet / window: button to the right of the title
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/team_management_controller.dart';
import 'team_user_form_dialog.dart';

class TeamHeader extends StatelessWidget {
  const TeamHeader({
    super.key,
    required this.controller,
    required this.isPhone,
  });

  final TeamManagementController controller;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final title = Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Members',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${controller.members.length} members',
            style: TextStyle(fontSize: 12.5, color: p.subText),
          ),
        ],
      ),
    );

    final addButton = OutlinedButton.icon(
      onPressed: () => showTeamUserForm(context, controller),
      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
      label: const Text('Add New User'),
    );

    if (isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title, const SizedBox(height: 12), addButton],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        addButton,
      ],
    );
  }
}
