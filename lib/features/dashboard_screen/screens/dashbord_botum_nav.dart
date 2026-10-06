import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/dashboard_screen.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/leads_screen.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/profile_screen.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/whatsapp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key});

  // Abhi sabhi icons ke liye pehli image use ho rahi hai.
  // Baad mein har icon ka apna path yahan badal dena.
  static const String _dashboardIcon =
      'assets/bottomNavigationIcon/Dashboard.svg';
  static const String _leadsIcon =
      'assets/bottomNavigationIcon/profile-circle-svgrepo-com.svg';
  static const String _whatsappIcon =
      'assets/bottomNavigationIcon/whatsapp.svg';
  static const String _profileIcon =
      'assets/bottomNavigationIcon/setting-svgrepo-com.svg';

  // WhatsApp green (light aur dark dono theme mein same)
  // static const Color _whatsappGreen = Color(0xFF25D366);

  Widget _navIcon(BuildContext context, String assetPath, {Color? fixedColor}) {
    return Builder(
      builder: (iconContext) {
        // fixedColor diya ho to wahi use hoga, warna theme ka color
        final color = fixedColor ?? IconTheme.of(iconContext).color;
        return SvgPicture.asset(
          assetPath,
          width: 24,
          height: 24,
          colorFilter: color == null
              ? null
              : ColorFilter.mode(color, BlendMode.srcIn),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController());

    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          switch (controller.selectedIndex.value) {
            case 0:
              return DashboardScreen(controller: controller);

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
          height: 65,
          child: Obx(
            () => BottomNavigationBar(
              backgroundColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.backgroundColor,

              selectedItemColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedItemColor,

              unselectedItemColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.unselectedItemColor,

              selectedLabelStyle: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedLabelStyle,

              unselectedLabelStyle: Theme.of(
                context,
              ).bottomNavigationBarTheme.unselectedLabelStyle,

              selectedIconTheme: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedIconTheme,

              unselectedIconTheme: Theme.of(
                context,
              ).bottomNavigationBarTheme.unselectedIconTheme,

              type:
                  Theme.of(context).bottomNavigationBarTheme.type ??
                  BottomNavigationBarType.fixed,

              elevation:
                  Theme.of(context).bottomNavigationBarTheme.elevation ?? 0,

              currentIndex: controller.selectedIndex.value,

              onTap: (index) {
                controller.changeTab(index);
              },

              items: [
                BottomNavigationBarItem(
                  icon: _navIcon(context, _dashboardIcon),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  // icon: _navIcon(context, _leadsIcon),
                  icon: Icon(Icons.people_outline),
                  label: "Leads",
                ),
                BottomNavigationBarItem(
                  icon: _navIcon(
                    context,
                    _whatsappIcon,
                    // fixedColor: _whatsappGreen,
                  ),
                  label: "Whatsapp",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
