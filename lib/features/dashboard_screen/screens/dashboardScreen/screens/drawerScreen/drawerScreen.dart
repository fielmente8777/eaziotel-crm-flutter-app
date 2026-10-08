import 'package:eazotel/features/Calls%20Management/screen/calls_management_screen.dart';
import 'package:eazotel/features/googleAnalytis/analytis_screen.dart';
import 'package:eazotel/features/googleAnalytis/binding/analytis_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';

class DashboardDrawer extends StatelessWidget {
  final BottomNavController controller;
  final LocationController locationController;

  const DashboardDrawer({
    super.key,
    required this.controller,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Obx(() {
              final hotelName =
                  locationController.selectedHotel.value?.local.trim() ?? '';

              final firstWord = hotelName.split(RegExp(r'\s+')).first;

              final profileName = firstWord.isNotEmpty
                  ? firstWord[0].toUpperCase()
                  : '';

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: profileName.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 25,
                            )
                          : Text(
                              profileName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        hotelName.isEmpty ? 'Hotel' : hotelName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              );
            }),

            const Divider(),

            // Analytis
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Google Analytis'),
              onTap: () {
                                Navigator.pop(context);

                Get.to(() => const Analytis(), binding: AnalytisBinding());
              },
            ),

            // Profile
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                controller.changeTab(3);
              },
            ),

            // Settings
            
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Calls Management'),
              onTap: () {
                Navigator.pop(context);

                Get.to(() => const CallsManagementScreen());
              },
            ),
            const Spacer(),

            // // Logout
            // ListTile(
            //   leading: const Icon(Icons.logout),
            //   title: const Text('Logout'),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
