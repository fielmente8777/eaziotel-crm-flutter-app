import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
 
class ProfilePage extends StatelessWidget {
  final BottomNavController controller;

  const ProfilePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Profile -> Home
            controller.changeTab(0);
          },
          child: const Text("Go To Home"),
        ),
      ),
    );
  }
}