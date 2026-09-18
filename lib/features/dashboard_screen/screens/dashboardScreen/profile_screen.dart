import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class ProfileScreen extends StatelessWidget {
  final BottomNavController controller;

  ProfileScreen({super.key, required this.controller});
  final controller2 = Get.put(DashboardController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Setting -> Search

            debugPrint(
              'DISPLAY NAMES: ${controller2.userNameResponse()?.data.map((e) => e.displayName).toList()}',
            );
          },
          child: const Text("Go To Sejjjjarch"),
        ),
      ),
    );
  }
}
