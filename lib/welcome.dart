import 'package:eazotel/features/auth/controllers/google_auth_controller.dart';
import 'package:eazotel/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final googleController = Get.put(GoogleAuthController());

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            // Logout + SharedPreferences clear
            await googleController.logout();

            if (!context.mounted) return;

            // LoginScreen par redirect
            // Purani navigation history completely remove
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ),
    );
  }
}
