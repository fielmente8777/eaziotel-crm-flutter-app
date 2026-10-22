// ============================================================
// TEAM MANAGEMENT TAB  (Settings > Team Management)
//
// This file is only the page frame:
//   top   : TeamHeader       (title, count, "Add New User")
//   bottom: the list of members
//             phone  (< 640px)  -> TeamMemberCards
//             tablet / window   -> TeamMemberTable
//
// All widgets are in screen/widgets/, data in controller/.
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screen/widgets/setting_section_card.dart';
import '../controller/team_management_controller.dart';
import 'widgets/team_header.dart';
import 'widgets/team_member_cards.dart';
import 'widgets/team_member_table.dart';

/// Below this width = phone (cards), above it = table
const double _tableBreakpoint = 640;

class TeamManagementSettingTab extends StatelessWidget {
  const TeamManagementSettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeamManagementController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isPhone = constraints.maxWidth < _tableBreakpoint;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 12 : 16),
          child: SettingSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeamHeader(controller: controller, isPhone: isPhone),
                const SizedBox(height: 16),

                // members reads the selected hotel, so this Obx rebuilds
                // by itself when the hotel changes
                Obx(() {
                  final members = controller.members;

                  if (members.isEmpty) return const _EmptyTeam();

                  return isPhone
                      ? TeamMemberCards(
                          members: members,
                          controller: controller,
                        )
                      : TeamMemberTable(
                          members: members,
                          controller: controller,
                        );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTeam extends StatelessWidget {
  const _EmptyTeam();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.group_outlined,
              size: 40,
              color: p.subText.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text('No team members found', style: TextStyle(color: p.subText)),
          ],
        ),
      ),
    );
  }
}
