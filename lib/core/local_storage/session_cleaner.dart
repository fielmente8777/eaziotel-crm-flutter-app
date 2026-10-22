import 'dart:io';

import 'package:eazotel/features/Calls%20Management/controller/calls_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/leads/controller/lead_details_filter_controller.dart';
import 'package:eazotel/features/leads/controller/lead_notes_api_controller.dart';
import 'package:eazotel/features/leads/controller/leads_controller.dart';
import 'package:eazotel/features/setting_screen/controller/setting_controller.dart';
import 'package:eazotel/features/setting_screen/profile/controller/profile_setting_controller.dart';
import 'package:eazotel/features/setting_screen/team_management/controller/team_management_controller.dart';
import 'package:eazotel/features/setting_screen/whatsapp/controller/whatsapp_setting_controller.dart';
import 'package:eazotel/features/setting_screen/integration/controller/integration_setting_controller.dart';
import 'package:eazotel/features/setting_screen/notification/controller/notification_setting_controller.dart';
import 'package:eazotel/features/setting_screen/subscription/controller/subscription_controller.dart';
import 'package:eazotel/features/setting_screen/eazbot/controller/eazbot_setting_controller.dart';
import 'package:eazotel/features/googleAnalytis/controller/analytisController.dart';
import 'package:eazotel/features/notifications/controller/notification_controller.dart';
import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappTemplateController.dart';
import 'package:eazotel/features/whatsapp/controller/whatsapp_lead_filter_controller.dart';
import 'package:eazotel/features/whatsapp/controller/whatsapp_handling_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On logout, clears all data of the previous user:
/// controllers (memory), SharedPreferences and downloaded call recordings.
class SessionCleaner {
  SessionCleaner._();

  /// These keys stay after logout (they are phone settings, not user data)
  static const Set<String> _keepKeys = {'selected_theme'};

  static Future<void> clearAll() async {
    deleteControllers();

    await _clearPreferences();
    await _deleteRecordings();
  }

  // ============================================================
  // CONTROLLERS
  // ============================================================

  /// Also runs right after login: during logout the dashboard is still
  /// on screen and recreates empty controllers without a token.
  /// Removing them gives the new user fresh controllers.
  static void deleteControllers() {
    // These keep references and settings belonging to the previous account.
    _delete<ProfileSettingController>();
    _delete<TeamManagementController>();
    _delete<WhatsappSettingController>();
    _delete<IntegrationSettingController>();
    _delete<NotificationSettingController>();
    _delete<SubscriptionController>();
    _delete<EazbotSettingController>();
    _delete<SettingController>();
    // Stop location listeners before clearing the old dashboard's observables.
    _delete<LocationController>();
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().clearDashboardData();
    }

    // Notifications first (it is what drives WhatsappController)
    _delete<NotificationController>();

    // When WhatsappController closes, the socket disconnects too
    _delete<WhatsappController>();
    _delete<Whatsapptemplatecontroller>();
    _delete<WhatsappLeadFilterController>();
    _delete<WhatsappMediaController>();
    WhatsappHandlingController.clearCache();

    _delete<CallsController>();
    _delete<AnalytisController>();

    _delete<LeadDetailsNotesController>();
    _delete<LeadFilterController>();
    _delete<LeadsController>();

    _delete<DashboardController>();
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
  // SHARED PREFERENCES (token, hotel id ... everything)
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
