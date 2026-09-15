import 'package:eazotel/features/dashboard_screen/controllers/leads_controller.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsTabs extends StatelessWidget {
  final LeadsController controller;

  const LeadsTabs({super.key, required this.controller});

  static const List<String> tabs = ['All Leads', 'Contact', 'Converted', 'Hot'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tabs.length,
        itemBuilder: (_, index) {
          return _TabItem(
            controller: controller,
            index: index,
            title: tabs[index],
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final LeadsController controller;
  final int index;
  final String title;

  const _TabItem({
    required this.controller,
    required this.index,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unselectedColor = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;

    return Obx(() {
      final selected = controller.selectedLeadTab.value == index;

      return GestureDetector(
        onTap: () => controller.changeLeadTab(index),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

          decoration: BoxDecoration(
            color: selected ? TAppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : unselectedColor,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    });
  }
}
