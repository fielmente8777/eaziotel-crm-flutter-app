import 'dart:io';

import 'package:eazotel/features/Calls%20Management/controller/calls_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/dashboard_screen/controllers/lead_details_filter_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/lead_notes_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/leads_controller.dart';
import 'package:eazotel/features/googleAnalytis/controller/analytisController.dart';
import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappTemplateController.dart';
import 'package:eazotel/features/whatsapp/controller/whatsapp_lead_filter_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Logout par purane user ka saara data saaf karta hai:
/// controllers (memory), SharedPreferences aur download hui call recordings.
class SessionCleaner {
  SessionCleaner._();

  /// Ye keys logout par bhi rehti hain (phone ki setting hain, user ka data nahi)
  static const Set<String> _keepKeys = {'selected_theme'};

  static Future<void> clearAll() async {
    deleteControllers();

    await _clearPreferences();
    await _deleteRecordings();
  }

  // ============================================================
  // CONTROLLERS
  // ============================================================

  /// Login ke turant baad bhi chalta hai: logout ke dauran dashboard abhi
  /// screen par hota hai aur bina token ke khali controller dobara bana deta
  /// hai. Unhe hatane par naye user ke liye taaza controller bante hain.
  static void deleteControllers() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().clearDashboardData();
    }

    // WhatsappController band hote hi socket bhi disconnect ho jata hai
    _delete<WhatsappController>();
    _delete<Whatsapptemplatecontroller>();
    _delete<WhatsappLeadFilterController>();
    _delete<WhatsappMediaController>();

    _delete<CallsController>();
    _delete<AnalytisController>();

    _delete<LeadDetailsNotesController>();
    _delete<LeadFilterController>();
    _delete<LeadsController>();

    _delete<DashboardController>();
    _delete<LocationController>();
    _delete<BottomNavController>();
  }

  static void _delete<T>() {
    try {
      if (Get.isRegistered<T>()) Get.delete<T>(force: true);
    } catch (e) {
      debugPrint('LOGOUT: $T delete error: $e');
    }
  }

  // ============================================================
  // SHARED PREFERENCES (token, hotel id ... sab kuch)
  // ============================================================

  static Future<void> _clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final key in prefs.getKeys().toList()) {
        if (!_keepKeys.contains(key)) await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('LOGOUT: preferences clear error: $e');
    }
  }

  // ============================================================
  // DOWNLOADED CALL RECORDINGS
  // ============================================================

  static Future<void> _deleteRecordings() async {
    try {
      final dir = await getTemporaryDirectory();

      await for (final file in dir.list()) {
        final name = file.uri.pathSegments.last;

        if (file is File && name.startsWith('call_recording_')) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('LOGOUT: recordings delete error: $e');
    }
  }
}
