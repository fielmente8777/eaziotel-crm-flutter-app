import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
// ============================================================
// HOME
// ============================================================

class HomePage extends StatelessWidget {
  final BottomNavController controller;

  const HomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar optional
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Koi bhi index pass karo
            controller.changeTab(0);
          },
          child: const Text("Go To Profile"),
        ),
      ),
    );
  }
}
