import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
 // ============================================================
// SEARCH
// ============================================================

class LeadsScreen extends StatelessWidget {
  final BottomNavController controller;

  const LeadsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar nahi chahiye to nahi lagao
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Search -> Setting
            controller.changeTab(0);
          },
          child: const Text("Go To Setting"),
        ),
      ),
    );
  }
}
