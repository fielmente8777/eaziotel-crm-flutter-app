import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/screen/whatsappConversationList.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsapp_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class whatsapp extends StatelessWidget {
  final BottomNavController controller;

  const whatsapp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    return Obx(() {
      final hid = dashboard.selectedHotelId.value;
      if (hid.isEmpty) {
        return const Scaffold(
          body: SafeArea(child: WaConversationShimmer(withHeader: true)),
        );
      }
      return WhatsappScreen(key: ValueKey(hid));
    });
  }
}
