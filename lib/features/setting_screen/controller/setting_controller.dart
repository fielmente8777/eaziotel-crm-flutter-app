// ============================================================
// SETTING CONTROLLER
//
// Sirf ek kaam: yaad rakhna ki upar ka kaunsa tab chuna hua hai.
// Har tab ka apna alag controller uske folder me hai.
// ============================================================

import 'package:get/get.dart';

/// Settings page ka shell: sirf upar ke tabs.
/// Har tab ka apna feature folder hai (profile, whatsapp, eazbot ...).
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
