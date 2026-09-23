 import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappConversationHeader.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageInput.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageList.dart';
 import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappConversationMesseg extends StatelessWidget {
  final WhatsappConversationModel chat;

  const WhatsappConversationMesseg({
    super.key,
    required this.chat,
  });

  String get tag => 'whatsapp_chat_${chat.id}';

  @override
  Widget build(BuildContext context) {
    return GetX<WhatsappConversationDetailController>(
      tag: tag,
      init: WhatsappConversationDetailController(
        chat: chat,
        whatsappController: Get.find<WhatsappController>(),
      ),
      builder: (controller) {
        final _ = controller.totalUnreadCount;

        return Scaffold(
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor,
          appBar: WhatsappConversationHeader(
            chat: chat,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: WhatsappMessageList(
                    controller: controller,
                  ),
                ),
                WhatsappMessageInput(
                  controller: controller,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}