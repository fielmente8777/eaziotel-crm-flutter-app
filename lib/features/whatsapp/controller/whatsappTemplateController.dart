import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:eazotel/features/whatsapp/services/whatsappTemplate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Whatsapptemplatecontroller extends GetxController {
  // ============================================================
  // STORAGE KEY
  // ============================================================

  static const String hotelIdKey = 'selected_hotel_id';

  // ============================================================
  // WHATSAPP TEMPLATE RESPONSE
  // ============================================================

  final whatsappTemplateResponse = Rxn<WhatsappTemplateResponse>();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    getWhatsappTemplate();
  }

  // ============================================================
  // GET WHATSAPP TEMPLATES
  // ============================================================

  Future<void> getWhatsappTemplate() async {
    try {
      // ========================================================
      // GET HOTEL ID FROM SHARED PREFERENCES
      // ========================================================

      final prefs = await SharedPreferences.getInstance();

      final hid = prefs.getString(hotelIdKey);

      if (hid == null || hid.isEmpty) {
        debugPrint('❌ Hotel ID not found in SharedPreferences');
        return;
      }

      debugPrint('🏨 WhatsApp Template HID: $hid');

      // ========================================================
      // API CALL
      // ========================================================

      final WhatsappTemplateResponse response =
          await WhatsappTemaplate.getWhatsappTemplates(hid: hid);

      // ========================================================
      // STORE RESPONSE
      // ========================================================

      whatsappTemplateResponse.value = response;

      debugPrint('✅ WhatsApp templates loaded');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP TEMPLATE API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    whatsappTemplateResponse.value = null;

    super.onClose();
  }
}
