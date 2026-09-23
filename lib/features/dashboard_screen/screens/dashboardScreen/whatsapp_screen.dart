import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/whatsapp/screen/whatsappConversationList.dart';
import 'package:flutter/material.dart';

class whatsapp extends StatelessWidget {
  final BottomNavController controller;

  const whatsapp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return WhatsappScreen();
  }
}
