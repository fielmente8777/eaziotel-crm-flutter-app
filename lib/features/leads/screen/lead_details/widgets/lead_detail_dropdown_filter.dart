import 'package:eazotel/features/leads/controller/lead_details_filter_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/leads/models/leads_responce_modle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadDetailsFilterWidget extends StatelessWidget {
  final LeadModel leads;

  LeadDetailsFilterWidget({super.key, required this.leads});

  final LeadFilterController controller = Get.put(LeadFilterController());

  @override
  Widget build(BuildContext context) {
    controller.setCurrentLead(leads);

    final String attemptedBy = leads.assignee?.trim().isNotEmpty == true
        ? leads.assignee!.trim()
        : 'Select';

    final String status = leads.status?.trim().isNotEmpty == true
        ? leads.status!.trim()
        : 'Select';

    final String turnAwayCode = leads.turnAwayCode?.trim().isNotEmpty == true
        ? leads.turnAwayCode!.trim()
        : 'Select';

    final List<UserModel> users =
        controller.dashboardController.userNameResponse()?.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // ATTEMPTED BY
        // ========================================================
        _attemptedByDropdown(users: users, currentValue: attemptedBy),

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

        const SizedBox(height: 12),

        // ========================================================
        // FOLLOW UP
        // ========================================================
        _followUpDateTime(context),
      ],
    );
  }

  // ============================================================
  // FOLLOW UP DATE + TIME
  // ============================================================

  Widget _followUpDateTime(BuildContext context) {
    return Obx(() {
      final DateTime? date = controller.selectedFollowUpDate.value;

      String displayValue = '';

      if (date != null) {
        final DateTime localDate = date.toLocal();

        final String day = localDate.day.toString().padLeft(2, '0');

        final String month = localDate.month.toString().padLeft(2, '0');

        final String year = localDate.year.toString();

        int hour = localDate.hour;

        final String minute = localDate.minute.toString().padLeft(2, '0');

        final String period = hour >= 12 ? 'PM' : 'AM';

        if (hour == 0) {
          hour = 12;
        } else if (hour > 12) {
          hour -= 12;
        }

        displayValue =
            '$day/$month/$year '
            '$hour:$minute $period';
      }

      return InkWell(
        onTap: () async {
          await controller.selectFollowUpDateTime(context);
        },
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Follow Up',
            labelStyle: TextStyle(fontSize: 13),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayValue.isEmpty ? 'Select Follow Up' : displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
      );
    });
  }

  // ============================================================
  // ATTEMPTED BY
  // ============================================================

  Widget _attemptedByDropdown({
    required List<UserModel> users,
    required String currentValue,
  }) {
    return Obx(() {
      final validUsers = users.where((user) {
        final name = user.displayName?.trim() ?? '';

        return name.isNotEmpty;
      }).toList();

      int? selectedIndex;

      final String selectedName = controller.selectedAttemptedBy.value.trim();

      if (selectedName.isNotEmpty) {
        final int index = validUsers.indexWhere(
          (user) => (user.displayName?.trim() ?? '') == selectedName,
        );

        if (index != -1) {
          selectedIndex = index;
        }
      } else if (currentValue != 'Select') {
        final int index = validUsers.indexWhere(
          (user) => (user.displayName?.trim() ?? '') == currentValue,
        );

        if (index != -1) {
          selectedIndex = index;
        }
      }

      return DropdownButtonFormField<int>(
        value: selectedIndex,

        decoration: const InputDecoration(
          labelText: 'Attempted By',
          labelStyle: TextStyle(fontSize: 13),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),

        isExpanded: true,

        hint: Text(currentValue),

        items: List.generate(validUsers.length, (index) {
          final user = validUsers[index];

          final String name = user.displayName?.trim() ?? '';

          return DropdownMenuItem<int>(
            value: index,
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),

        onChanged: (int? index) async {
          if (index == null) {
            return;
          }

          if (index < 0 || index >= validUsers.length) {
            return;
          }

          final UserModel user = validUsers[index];

          await controller.onAttemptedByChanged(user);
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
      final List<String> uniqueItems = items
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();

      final String controllerValue = value.value.trim();

      final String selectedValue = controllerValue.isNotEmpty
          ? controllerValue
          : currentValue;

      final bool hasSelectedValue =
          selectedValue.isNotEmpty &&
          selectedValue != 'Select' &&
          uniqueItems.contains(selectedValue);

      return DropdownButtonFormField<String>(
        value: hasSelectedValue ? selectedValue : null,

        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),

        isExpanded: true,

        hint: Text(currentValue),

        items: uniqueItems.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),

        onChanged: onChanged,
      );
    });
  }
}
