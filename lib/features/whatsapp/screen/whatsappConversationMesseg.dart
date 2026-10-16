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

    // Chat band ho to "khuli chat" hata do, warna is chat ke naye message
    // par na unread badhta, na notification aata
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop &&
            whatsappController.currentConversationId.value == chat.id) {
          whatsappController.clearCurrentConversation();
        }

        // Agli baar khule to taaza haal (AI / flow) dobara pata chale
        if (didPop && Get.isRegistered<WhatsappHandlingController>(tag: tag)) {
          Get.delete<WhatsappHandlingController>(tag: tag);
        }
      },
      child: Scaffold(
        // WhatsApp jaisa chat background (light: beige, dark: gehra)
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
              // AI / teammate / flow reply kar raha ho to message box ki
              // jagah "Take over" bar (web dashboard jaisa)
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
