// import 'package:eazotel/features/whatsapp/services/whatsappMessegSand.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

//  class WhatsappFlutterMessageController extends GetxController {
//   final TextEditingController textController =
//       TextEditingController();

//   final RxBool isSending = false.obs;

//   final String hid;
//   final String phone;

//   WhatsappFlutterMessageController({
//     required this.hid,
//     required this.phone,
//   });

//   Future<void> sendMessage() async {
//     final text = textController.text.trim();

//     if (text.isEmpty || isSending.value) {
//       return;
//     }

//     isSending.value = true;

//     try {
//       final response =
//           await WhatsappMessageSand.sendWhatsappMessage(
//         hid: hid,
//         phone: phone,
//         text: text,
//       );

//       if (response.statusCode >= 200 &&
//           response.statusCode < 300) {
//         textController.clear();
//       }
//     } finally {
//       isSending.value = false;
//     }
//   }

//   @override
//   void onClose() {
//     textController.dispose();
//     super.onClose();
//   }
// }