// ============================================================
// SETTING SCREEN  (drawer > Settings)
//
// This is only the page frame:
//   - tab bar on top  (Profile, WhatsApp, Eazbot ...)
//   - the selected tab's screen below
//
// Each tab has its own folder:
//   profile/   whatsapp/   eazbot/   integration/
//   team_management/   notification/   subscription/
//
// To add a new tab: make the screen in that folder and add it to _tabBody below.
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/setting_controller.dart';
import 'eazbot/screen/eazbot_setting_tab.dart';
import 'integration/screen/integration_setting_tab.dart';
import 'notification/screen/notification_setting_tab.dart';
import 'profile/screen/profile_setting_tab.dart';
import 'subscription/screen/subscription_setting_tab.dart';
import 'team_management/screen/team_management_setting_tab.dart';
import 'whatsapp/screen/whatsapp_setting_tab.dart';
import 'screen/widgets/setting_tabs.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  /// Each tab opens the screen from its own feature folder
  Widget _tabBody(SettingTab tab) {
    switch (tab) {
      case SettingTab.profile:
        return const ProfileSettingTab();
      case SettingTab.whatsapp:
        return const WhatsappSettingTab();
      case SettingTab.eazbot:
        return const EazbotSettingTab();
      case SettingTab.integration:
        return const IntegrationSettingTab();
      case SettingTab.teamManagement:
        return const TeamManagementSettingTab();
      case SettingTab.notification:
        return const NotificationSettingTab();
      case SettingTab.subscription:
        return const SubscriptionSettingTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingController());

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        // Phone / tablet / window: the layout changes by itself with the available width
        child: TResponsiveBuilder(
          builder: (context, r) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingTabs(controller: controller, padding: r.pagePadding),
                Expanded(
                  child: Obx(() => _tabBody(controller.selectedTab.value)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
