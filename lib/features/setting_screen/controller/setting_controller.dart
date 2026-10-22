// ============================================================
// SETTING CONTROLLER
//
// Only one job: remember which top tab is selected.
// Each tab has its own controller in its folder.
// ============================================================

import 'package:get/get.dart';

/// Shell of the Settings page: only the top tabs.
/// Each tab has its own feature folder (profile, whatsapp, eazbot ...).
enum SettingTab {
  profile('Profile'),
  whatsapp('WhatsApp'),
  eazbot('Eazbot'),
  integration('Integration'),
  teamManagement('Team Management'),
  notification('Notification'),
  subscription('Subscription');

  const SettingTab(this.label);

  final String label;
}

class SettingController extends GetxController {
  final selectedTab = SettingTab.profile.obs;
}
