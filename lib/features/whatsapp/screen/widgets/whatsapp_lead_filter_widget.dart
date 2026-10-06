import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/whatsapp/controller/whatsapp_lead_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappLeadFilterWidget extends StatelessWidget {
  final WhatsappLeadFilterController controller;
  final String? status;
  final String? assignedTo;

  const WhatsappLeadFilterWidget({
    super.key,
    required this.controller,
    required this.status,
    this.assignedTo ,
  });

  @override
  Widget build(BuildContext context) {
    final List<UserModel> users =
        controller.dashboardController.userNameResponse()?.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _attemptedBy(users),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Stage',
          value: controller.selectedStage,
          items: controller.stageList,
          onChanged: (v) {
            if (v != null && v.isNotEmpty) controller.onStageChanged(v);
          },
        ),
        const SizedBox(height: 12),
        _dropdown(
          label: 'Turn Away Code',
          value: controller.selectedTurnAwayCode,
          items: controller.turnAwayCodeList,
          onChanged: (v) {
            if (v != null && v.isNotEmpty) controller.onTurnAwayCodeChanged(v);
          },
        ),
        const SizedBox(height: 12),
        _followUp(context),
      ],
    );
  }

  static const _decoration = EdgeInsets.symmetric(horizontal: 12, vertical: 16);

  Widget _followUp(BuildContext context) {
    return Obx(() {
      final d = controller.selectedFollowUpDate.value?.toLocal();
      String text = 'Select Follow Up';
      if (d != null) {
        int h = d.hour;
        final p = h >= 12 ? 'PM' : 'AM';
        h = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        text =
            '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year} '
            '$h:${d.minute.toString().padLeft(2, '0')} $p';
      }

      return InkWell(
        onTap: () => controller.selectFollowUpDateTime(context),
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Follow Up',
            labelStyle: TextStyle(fontSize: 13),
            border: OutlineInputBorder(),
            contentPadding: _decoration,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
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

  Widget _attemptedBy(List<UserModel> users) {
    return Obx(() {
      final valid = users
          .where((u) => (u.displayName?.trim() ?? '').isNotEmpty)
          .toList();
      final selected = controller.selectedAttemptedBy.value.trim();
      final idx = valid.indexWhere((u) => u.displayName!.trim() == selected);
      return DropdownButtonFormField<int>(
        value: idx == -1 ? null : idx,
        isExpanded: true,
        hint: Text(selected.isEmpty ? assignedTo.toString() : selected),
        decoration: const InputDecoration(
          labelText: 'Attempted By',
          labelStyle: TextStyle(fontSize: 13),
          border: OutlineInputBorder(),
          contentPadding: _decoration,
        ),
        items: List.generate(valid.length, (i) {
          return DropdownMenuItem<int>(
            value: i,
            child: Text(
              valid[i].displayName!.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
        onChanged: (i) {
          if (i == null || i < 0 || i >= valid.length) return;
          controller.onAttemptedByChanged(valid[i]);
        },
      );
    });
  }

  Widget _dropdown({
    required String label,
    required RxString value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Obx(() {
      final unique = items
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
      final v = value.value.trim();

      return DropdownButtonFormField<String>(
        value: unique.contains(v) ? v : null,
        isExpanded: true,
        hint: const Text('Select'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          border: const OutlineInputBorder(),
          contentPadding: _decoration,
        ),
        items: unique
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(
                  e,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      );
    });
  }
}
