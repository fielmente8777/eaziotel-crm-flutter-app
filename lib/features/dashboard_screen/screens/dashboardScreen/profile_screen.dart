import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  final BottomNavController controller;

  ProfileScreen({
    super.key,
    required this.controller,
  });

  final DashboardController controller2 =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await controller2
                .loginController
                .logoutUser(context);
          },
          child: const Text(
            'Logout',
          ),
        ),
      ),
    );
  }
}