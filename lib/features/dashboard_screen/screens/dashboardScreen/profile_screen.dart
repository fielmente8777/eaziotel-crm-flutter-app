import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
 
class SettingPage extends StatelessWidget {
  final BottomNavController controller;

  const SettingPage({super.key, required this.controller});

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
