import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappTemplateController.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappHeadeerWidget/whatsappConversationHeader.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappbotumwidget/whatsappMessageInput.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageList.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappConversationMesseg extends StatelessWidget {
  final WhatsappConversationModel chat;
  final Whatsapptemplatecontroller whatsapptemplate;
  const WhatsappConversationMesseg({
    super.key,
    required this.chat,
    required this.whatsapptemplate,
  });

  String get tag => 'whatsapp_chat_${chat.id}';

  @override
  Widget build(BuildContext context) {
    final lastmesttime = chat.createdAt.toString();
    // final whatsapptemplatel =
    final controller = Get.put(
      WhatsappConversationDetailController(
        chat: chat,
        whatsappController: Get.find<WhatsappController>(),
      ),
      tag: tag,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WhatsappConversationHeader(chat: chat),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: WhatsappMessageList(
                chatdetail: chat,
                controller: controller,
              ),
            ),
            // FloatingActionButton(
            //   onPressed: () {
            //     debugPrint(lastmesttime);
            //     // debugPrint(whatsappTemplateResponse2.toString());
            //   },

            //   child: const Icon(Icons.add),
            // ),
            WhatsappMessageInput(controller: controller,chatdetail:chat),
          ],
        ),
      ),
    );
  }
}
