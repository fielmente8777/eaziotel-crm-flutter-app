import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
 
class ProfileScreen extends StatelessWidget {
  final BottomNavController controller;

  const ProfileScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Setting -> Search
            controller.changeTab(0);
          },
          child: const Text("Go To Search"),
        ),
      ),
    );
  }
}
