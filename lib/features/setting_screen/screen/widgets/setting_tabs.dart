// ============================================================
// SETTING TABS
//
// Tab bar at the top of the Settings page. Scrolls sideways on small screens.
// Tapping a tab changes SettingController.selectedTab.
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/setting_controller.dart';

/// Top tabs (scroll sideways on small screens)
class SettingTabs extends StatelessWidget {
  const SettingTabs({
    super.key,
    required this.controller,
    required this.padding,
  });

  final SettingController controller;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final border = isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
    final text = isDark ? TAppColors.darkText : TAppColors.lightText;
    final subText = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
        child: Obx(() {
          final selected = controller.selectedTab.value.index;

          return Row(
            children: [
              for (var i = 0; i < SettingTab.values.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () =>
                        controller.selectedTab.value = SettingTab.values[i],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: i == selected
                            ? theme.colorScheme.primary.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        SettingTab.values[i].label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: i == selected
                              ? theme.colorScheme.primary
                              : (i == selected ? text : subText),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
