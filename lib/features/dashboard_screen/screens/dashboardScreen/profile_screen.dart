import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/auth/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  final BottomNavController controller;

  ProfileScreen({
    super.key,
    required this.controller,
  }) {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginController loginController =
        Get.find<LoginController>();

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await loginController.logoutUser(context);
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}