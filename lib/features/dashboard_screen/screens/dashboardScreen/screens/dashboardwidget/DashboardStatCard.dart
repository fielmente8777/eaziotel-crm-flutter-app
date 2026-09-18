import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';

class DashboardStatCard extends StatelessWidget {
  final String value;
  final String title;
  final String bottomText;
  final IconData icon;

  final Color accentColor;
  final Color iconColor;
  final Color? valueColor;

  const DashboardStatCard({
    super.key,
    required this.value,
    required this.title,
    required this.bottomText,
    required this.icon,
    required this.accentColor,
    required this.iconColor,
    this.valueColor,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();

    return Obx(() {
      final isLoading = dashboardController.isAnalyticsLoading.value;

      if (isLoading) {
        return _shimmerCard(context);
      }

      final theme = Theme.of(context);

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border(top: BorderSide(color: accentColor, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),

            const SizedBox(height: 8),

            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: valueColor ?? theme.textTheme.titleLarge?.color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.brightness == Brightness.dark
                    ? TAppColors.darkSecondaryText
                    : TAppColors.lightSecondaryText,
              ),
            ),

            const Spacer(),

            Text(
              bottomText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: iconColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _shimmerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? TAppColors.darkCard : TAppColors.lightBorder,
      highlightColor: isDark ? TAppColors.darkBorder : TAppColors.lightCard,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 10),

            Container(height: 22, width: 70, color: Colors.white),

            const SizedBox(height: 7),

            Container(height: 10, width: 80, color: Colors.white),

            const Spacer(),

            Container(height: 9, width: 65, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
