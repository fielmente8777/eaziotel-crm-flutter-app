import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappTemplateController.dart';
import 'package:eazotel/features/whatsapp/controller/whatsapp_handling_controller.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappHeadeerWidget/whatsappConversationHeader.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappbotumwidget/whatsappMessageInput.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsappbotumwidget/whatsapp_handling_footer.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageList.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsapp_ui.dart';
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
    final whatsappController = Get.find<WhatsappController>();
    // final whatsapptemplatel =
    final controller = Get.put(
      WhatsappConversationDetailController(
        chat: chat,
        whatsappController: Get.find<WhatsappController>(),
      ),
      tag: tag,
    );

    // Kaun reply karega (AI / team / flow) -> Take over
    final handling = Get.put(WhatsappHandlingController(chat: chat), tag: tag);

    // When the chat closes, clear the "open chat", otherwise this chat's new messages
    // so neither unread grows nor a notification comes
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop &&
            whatsappController.currentConversationId.value == chat.id) {
          whatsappController.clearCurrentConversation();
        }

        // Next time it opens, find out the fresh state (AI / flow) again
        if (didPop && Get.isRegistered<WhatsappHandlingController>(tag: tag)) {
          Get.delete<WhatsappHandlingController>(tag: tag);
        }
      },
      child: Scaffold(
        // Chat background like WhatsApp (light: beige, dark: deep)
        backgroundColor: WaPalette(context).wallpaper,
        appBar: WhatsappConversationHeader(
          chat: chat,
          whatsappController: whatsappController,
        ),
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
              // When AI / a teammate / a flow is replying, a "Take over" bar instead of
              // the message box (same as the web dashboard)
              WhatsappHandlingFooter(
                controller: handling,
                input: WhatsappMessageInput(
                  controller: controller,
                  chatdetail: chat,
                  whatsappController: whatsappController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
