import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/models/FlowResponseModel.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../services/whatsapp_setting_service.dart';

enum FlowTab {
  flowName('Flow Name'),
  createFlow('Create Flow');

  const FlowTab(this.label);

  final String label;
}

class WhatsappFlowPageController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ---------- Tab ----------
  final selectedTab = FlowTab.flowName.obs;

  void changeTab(FlowTab tab) => selectedTab.value = tab;

  // ---------- Flow list ----------
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final flow = Rxn<FlowResponseModel>();

  List<FlowItemModel> get flows => flow.value?.result?.docs?.flows ?? [];

  @override
  void onInit() {
    super.onInit();
    loadFlows();
  }

  Future<void> loadFlows() async {
    if (hid.isEmpty) {
      errorMessage.value = 'No hotel selected';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      flow.value = await WhatsappSettingService.getFlows(hid: hid);
    } catch (e) {
      debugPrint('WHATSAPP FLOW: load error: $e');
      errorMessage.value = 'Unable to load flows. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
