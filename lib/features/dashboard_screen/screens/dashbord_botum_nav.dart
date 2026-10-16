// ============================================================
// DASHBOARD BOTTOM NAV
//
//   Home | Leads | WhatsApp | Profile
//
// Chuna hua tab: rangeen "pill" ke andar bhara (filled) icon.
// Profile yahin hai (theme, logout, hotel badalna), isliye drawer me
// alag "Profile" nahi; drawer ke upar "View profile" se yahi khulta hai.
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/dashboard_screen.dart';
import 'package:eazotel/features/leads/screen/leads_screen.dart';
import 'package:eazotel/features/notifications/controller/notification_controller.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/profile_screen.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/whatsapp_screen.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key});

  static const String _whatsappIcon =
      'assets/bottomNavigationIcon/whatsapp.svg';

  Widget _svg(String asset, Color color) => SvgPicture.asset(
    asset,
    width: 22,
    height: 22,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController());

    // App khulte hi: WhatsApp socket judta hai + notifications shuru
    // (WhatsApp tab kholne ka intezaar nahi)
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barColor = isDark ? TAppColors.darkCard : TAppColors.lightCard;
    final border = isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
    final idle = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;
    // Dark theme: chamakdar indigo pill + safed icon + lavender label
    // Light theme: pehle jaisa primary
    final pill = isDark
        ? const Color(0xFF6366F1)
        : TAppColors.primary.withValues(alpha: .12);
    final activeIcon = isDark ? Colors.white : TAppColors.primary;
    final activeLabel = isDark ? const Color(0xFFC7D2FE) : TAppColors.primary;

    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          switch (controller.selectedIndex.value) {
            case 1:
              return LeadsScreen(controller: controller);
            case 2:
              return whatsapp(controller: controller);
            case 3:
              return ProfileScreen(controller: controller);
            default:
              return DashboardScreen(controller: controller);
          }
        }),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: barColor,
            border: Border(top: BorderSide(color: border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .3 : .06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Obx(
            () => NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: barColor,
                surfaceTintColor: Colors.transparent,
                indicatorColor: pill,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                labelTextStyle: WidgetStateProperty.resolveWith(
                  (states) => TextStyle(
                    fontSize: 11.5,
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: states.contains(WidgetState.selected)
                        ? activeLabel
                        : idle,
                  ),
                ),
                iconTheme: WidgetStateProperty.resolveWith(
                  (states) => IconThemeData(
                    size: 24,
                    color: states.contains(WidgetState.selected)
                        ? activeIcon
                        : idle,
                  ),
                ),
              ),
              child: NavigationBar(
                height: 66,
                elevation: 0,
                selectedIndex: controller.selectedIndex.value,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: controller.changeTab,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.space_dashboard_outlined),
                    selectedIcon: Icon(Icons.space_dashboard_rounded),
                    label: 'Home',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_alt_rounded),
                    label: 'Leads',
                  ),
                  NavigationDestination(
                    icon: _svg(_whatsappIcon, idle),
                    selectedIcon: _svg(_whatsappIcon, activeIcon),
                    label: 'WhatsApp',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
