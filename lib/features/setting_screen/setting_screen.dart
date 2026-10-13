// ============================================================
// SETTING SCREEN  (drawer > Settings)
//
// Ye sirf page ka dhancha hai:
//   - upar tab bar  (Profile, WhatsApp, Eazbot ...)
//   - neeche chune hue tab ka screen
//
// Har tab ka apna folder hai:
//   profile/   whatsapp/   eazbot/   integration/
//   team_management/   notification/   subscription/
//
// Naya tab banana ho: us folder me screen banao aur neeche _tabBody me jodo.
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

  /// Har tab apne feature folder ka screen kholta hai
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
        // Phone / tablet / window: milne wali width se layout apne aap badalta hai
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
