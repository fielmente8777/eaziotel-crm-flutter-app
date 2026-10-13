// ============================================================
// NOTIFICATION SETTING TAB  (Settings > Notification)
//
// Ye file sirf tay karti hai ki KYA dikhe:
//   data aa raha hai   ->  shimmer
//   error              ->  message + Retry
//   warna              ->  Save button
//                          WhatsApp Notifications card
//                            Enable WhatsApp switch
//                            CallNotificationBox
//                            LeadSourceList (number)
//                          Email Notifications card
//                            LeadSourceList (email)
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../screen/widgets/setting_section_card.dart';
import '../controller/notification_setting_controller.dart';
import 'widgets/call_notification_box.dart';
import 'widgets/lead_source_list.dart';

class NotificationSettingTab extends StatelessWidget {
  const NotificationSettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationSettingController());

    return TResponsiveBuilder(
      builder: (context, r) {
        return Obx(() {
          if (controller.isLoading.value) return _Loading(r: r);

          final error = controller.errorMessage.value;

          if (error != null) {
            return _Error(message: error, onRetry: controller.load);
          }

          return RefreshIndicator(
            onRefresh: controller.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(r.pagePadding),
              child: TCenteredContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Obx(() {
                        final saving = controller.isSaving.value;

                        return ElevatedButton.icon(
                          style: settingSmallButton(),
                          onPressed: saving ? null : controller.save,
                          icon: const Icon(Icons.save_outlined, size: 16),
                          label: Text(saving ? 'Saving...' : 'Save'),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    _WhatsappCard(controller: controller, r: r),
                    const SizedBox(height: 16),
                    SettingSectionCard(
                      icon: Icons.email_outlined,
                      title: 'Email Notifications',
                      child: LeadSourceList(
                        controller: controller,
                        channel: NotificationChannel.email,
                        r: r,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

// ============================================================
// WHATSAPP NOTIFICATIONS CARD
// ============================================================

class _WhatsappCard extends StatelessWidget {
  const _WhatsappCard({required this.controller, required this.r});

  final NotificationSettingController controller;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      icon: Icons.chat_outlined,
      title: 'WhatsApp Notifications',
      child: Obx(() {
        final enabled = controller.whatsappEnabled.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Enable WhatsApp',
                    style: TextStyle(color: p.text, fontSize: 13),
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: (value) =>
                      controller.whatsappEnabled.value = value,
                ),
              ],
            ),

            // WhatsApp band ho to neeche ka sab chhup jata hai
            if (enabled) ...[
              const SizedBox(height: 8),
              CallNotificationBox(controller: controller, r: r),
              const SizedBox(height: 8),
              LeadSourceList(
                controller: controller,
                channel: NotificationChannel.whatsapp,
                r: r,
              ),
            ],
          ],
        );
      }),
    );
  }
}

// ============================================================
// LOADING + ERROR
// ============================================================

class _Loading extends StatelessWidget {
  const _Loading({required this.r});

  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget block(double height) => Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(
        p.border,
        Colors.white,
        p.isDark ? 0.12 : 0.7,
      )!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(r.pagePadding),
        children: [block(40), block(360), block(260)],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 48, color: p.subText),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text, fontSize: 15),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
