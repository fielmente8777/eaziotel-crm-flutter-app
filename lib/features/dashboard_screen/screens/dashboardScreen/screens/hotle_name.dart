import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';


  Widget hotelNameWidget(BuildContext context) {
      final LocationController locationController = Get.put(LocationController());

    return Obx(
      () => Text(
        locationController.selectedHotel.value?.local ?? 'Select Hotel',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
