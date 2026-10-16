// ============================================================
// NOTIFICATION BELL  (Home ke upar, avatar ke paas)
//
//   🔔(3)   3 = bina padhi notifications. Tap = Notifications page.
// ============================================================

import 'package:eazotel/features/notifications/controller/notification_controller.dart';
import 'package:eazotel/features/notifications/screen/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<NotificationController>();

    return Obx(() {
      final count = controller.unreadCount;

      return Tooltip(
        message: count == 0 ? 'Notifications' : '$count new notifications',
        child: Material(
          color: Colors.white.withValues(alpha: .18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: .35)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Get.to(() => const NotificationScreen()),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    count == 0
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                  if (count > 0)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 19),
                        height: 19,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
