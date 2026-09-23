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
              // Theme se colors automatically aayenge
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
                  icon: SvgPicture.asset(
                    'assets/bottomNavigationIcon/Dashboard.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: "Dashboard",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.percent_outlined),
                  label: "Leads",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Whatsapp",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.person_4),
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
