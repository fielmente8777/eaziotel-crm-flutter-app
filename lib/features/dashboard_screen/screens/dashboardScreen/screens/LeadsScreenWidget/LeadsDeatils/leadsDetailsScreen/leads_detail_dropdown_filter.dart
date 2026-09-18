import 'package:eazotel/features/dashboard_screen/controllers/lead_details_filter_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadDetailsFilterWidget extends StatelessWidget {
  final LeadModel leads;

  LeadDetailsFilterWidget({super.key, required this.leads});

  final LeadFilterController controller = Get.put(LeadFilterController());

  @override
  Widget build(BuildContext context) {
    controller.setCurrentLead(leads);

    final String assigneeBy = leads.assignee?.trim().isNotEmpty == true
        ? leads.assignee!.trim()
        : 'Select';

    final String status = leads.status?.trim().isNotEmpty == true
        ? leads.status!.trim()
        : 'Select';

    final String turnAwayCode = leads.turnAwayCode?.trim().isNotEmpty == true
        ? leads.turnAwayCode!.trim()
        : 'Select';

    final List<UserModel> attemptedByUsers =
        controller.controller.userNameResponse()?.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // ATTEMPTED BY
        // ========================================================
        _attemptedByDropdown(users: attemptedByUsers, currentValue: assigneeBy),

        const SizedBox(height: 12),

        // ========================================================
        // STAGE
        // ========================================================
        _dropdown(
          label: 'Stage',
          currentValue: status,
          value: controller.selectedStage,
          items: controller.stageList,
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              controller.onStageChanged(value);
            }
          },
        ),

        const SizedBox(height: 12),

        // ========================================================
        // TURN AWAY CODE
        // ========================================================
        _dropdown(
          label: 'Turn Away Code',
          currentValue: turnAwayCode,
          value: controller.selectedTurnAwayCode,
          items: controller.turnAwayCodeList,
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              controller.onTurnAwayCodeChanged(value);
            }
          },
        ),
      ],
    );
  }

  // ============================================================
  // ATTEMPTED BY DROPDOWN
  // ============================================================

  Widget _attemptedByDropdown({
    required List<UserModel> users,
    required String currentValue,
  }) {
    return Obx(() {
      final String selectedValue =
          controller.selectedAttemptedBy.value.isNotEmpty
          ? controller.selectedAttemptedBy.value
          : currentValue;

      final bool hasSelectedValue =
          selectedValue.isNotEmpty &&
          selectedValue != 'Select' &&
          users.any((user) => user.displayName?.trim() == selectedValue);

      return DropdownButtonFormField<String>(
        value: hasSelectedValue ? selectedValue : null,

        decoration: const InputDecoration(
          labelText: 'Attempted By',
          border: OutlineInputBorder(),
        ),

        isExpanded: true,

        hint: Text(currentValue),

        items: users
            .map((user) {
              final String name = user.displayName?.trim() ?? '';

              if (name.isEmpty) {
                return null;
              }

              return DropdownMenuItem<String>(value: name, child: Text(name));
            })
            .whereType<DropdownMenuItem<String>>()
            .toList(),

        onChanged: (String? value) async {
          if (value == null || value.isEmpty) {
            return;
          }

          UserModel? selectedUser;

          for (final user in users) {
            if (user.displayName?.trim() == value) {
              selectedUser = user;
              break;
            }
          }

          if (selectedUser == null) {
            print('❌ USER NOT FOUND');
            return;
          }

          await controller.onAttemptedByChanged(selectedUser);
        },
      );
    });
  }

  // ============================================================
  // COMMON DROPDOWN
  // ============================================================

  Widget _dropdown({
    required String label,
    required String currentValue,
    required RxString value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Obx(() {
      final String selectedValue = value.value.isNotEmpty
          ? value.value
          : currentValue;

      final bool hasSelectedValue =
          selectedValue.isNotEmpty &&
          selectedValue != 'Select' &&
          items.contains(selectedValue);

      return DropdownButtonFormField<String>(
        value: hasSelectedValue ? selectedValue : null,

        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),

        isExpanded: true,

        hint: Text(currentValue),

        items: items.map((item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),

        onChanged: onChanged,
      );
    });
  }
}
