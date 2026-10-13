// ============================================================
// PROFILE SETTING TAB  (Settings > Profile)
//
// Chaar card ek ke neeche ek (sab widgets/ folder me hain):
//   1. profile_card           : user / organization / contact
//   2. profile_hotels_card    : hotels ki list
//   3. profile_urls_card      : landing pages + websites
//   4. profile_password_card  : password badalna
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/profile_setting_controller.dart';
import 'widgets/profile_hotels_card.dart';
import 'widgets/profile_password_card.dart';
import 'widgets/profile_card.dart';
import 'widgets/profile_urls_card.dart';

/// Profile tab: chaaron card ek ke neeche ek
class ProfileSettingTab extends StatelessWidget {
  const ProfileSettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileSettingController());

    return TResponsiveBuilder(
      builder: (context, r) {
        final gap = r.gap + 6;

        return SingleChildScrollView(
          padding: EdgeInsets.all(r.pagePadding),
          child: TCenteredContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingProfileCard(controller: controller, r: r),
                SizedBox(height: gap),
                SettingHotelsCard(controller: controller, r: r),
                SizedBox(height: gap),
                SettingUrlsCard(controller: controller, r: r),
                SizedBox(height: gap),
                SettingPasswordCard(controller: controller),
                SizedBox(height: gap),
              ],
            ),
          ),
        );
      },
    );
  }
}
