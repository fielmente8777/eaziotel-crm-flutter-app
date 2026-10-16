import 'dart:convert';

import 'package:eazotel/features/leads/models/leads_responce_modle.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappTemplateController.dart';
import 'package:eazotel/features/whatsapp/models/FlowResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/services/markConversationAsRead.dart';
import 'package:eazotel/features/whatsapp/services/whatsappConversation.dart';
import 'package:eazotel/features/whatsapp/services/whatsappFlow.dart';
import 'package:eazotel/features/whatsapp/services/whatsappLeadsDelete.dart';
import 'package:eazotel/features/whatsapp/services/whatsappMessegSand.dart';
import 'package:eazotel/features/whatsapp/services/whatsapp_Integration_api.dart';
import 'package:eazotel/features/whatsapp/services/whatsapp_socket_services.dart';
import 'package:eazotel/features/whatsapp/services/whatsappdelete.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

part 'whatsapp_controller/whatsapp_state_mixin.dart';
part 'whatsapp_controller/whatsapp_helpers_mixin.dart';
part 'whatsapp_controller/whatsapp_conversation_list_mixin.dart';
part 'whatsapp_controller/whatsapp_chat_mixin.dart';
part 'whatsapp_controller/whatsapp_flow_mixin.dart';
part 'whatsapp_controller/whatsapp_socket_mixin.dart';

// ============================================================
// WHATSAPP CONTROLLER
//
// Ye file sirf jodti hai. Asli kaam whatsapp_controller/ ke mixins me hai:
//   state             : saari Rx state
//   helpers           : saanjhe helper, copy, lead NDID
//   conversation_list : list, tab, search, delete, read
//   chat              : khuli chat ke messages
//   flow              : form (flow) bhejna
//   socket            : live events
// ============================================================

class WhatsappController extends GetxController
    with
        WhatsappStateMixin,
        WhatsappHelpersMixin,
        WhatsappConversationListMixin,
        WhatsappChatMixin,
        WhatsappFlowMixin,
        WhatsappSocketMixin {
  // ============================================================
  // HID (dynamic - screen se pass hota hai)
  // ============================================================

  @override
  final String hid;

  WhatsappController({required this.hid});

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    getflow();

    // leadResponse kahin bhi set ho, NDID cache apne aap update ho jayega.
    _leadWorker = ever<LeadResponseModel?>(leadResponse, (_) {
      _rebuildLeadNdids();
    });

    if (!Get.isRegistered<Whatsapptemplatecontroller>()) {
      Get.put(Whatsapptemplatecontroller());
    }

    getWhatsappIntegration();

    getConversations();

    WhatsappSocketService.connect(onMessage: handleSocketMessage);
  }

  @override
  void onClose() {
    _leadWorker?.dispose();

    if (Get.isRegistered<Whatsapptemplatecontroller>()) {
      Get.delete<Whatsapptemplatecontroller>();
    }

    flow.value = null;
    WhatsappSocketService.disconnect();

    super.onClose();
  }
}
