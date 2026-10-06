import 'package:eazotel/features/googleAnalytis/controller/analytisController.dart';
import 'package:eazotel/features/googleAnalytis/models/featuresModels/filateDateRange.dart';
 import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateRangeDropdown extends StatelessWidget {
  final AnalytisController controller;
  const DateRangeDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    const accent = TAppColors.primary;

    return Obx(
      () => PopupMenuButton<DateRangeOption>(
        color: c.card,
        elevation: 6,
        offset: const Offset(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
        onSelected: controller.changeDateRange,
        itemBuilder: (context) => DateRangeOption.options.map((option) {
          final isSelected =
              option.label == controller.selectedRange.value.label;
          return PopupMenuItem<DateRangeOption>(
            value: option,
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected ? accent : c.text,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check, size: 16, color: accent),
              ],
            ),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 15, color: accent),
              const SizedBox(width: 8),
              Text(
                controller.selectedRange.value.label,
                style: TextStyle(
                  color: c.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 18, color: c.subText),
            ],
          ),
        ),
      ),
    );
  }
}