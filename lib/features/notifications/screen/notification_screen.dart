// ============================================================
// NOTIFICATIONS SCREEN
//
//   ← Notifications                 [✓✓ Read all] [🗑]
//   [ All (12) ] [ Unread (3) ]
//   TODAY
//     (R) Rahul Sharma                    2m   ●
//         Hello, room available hai?
//   YESTERDAY ...
//
// Tap = WhatsApp chat khulti hai. Side me kheencho = hatao.
// ============================================================

import 'package:eazotel/features/notifications/controller/notification_controller.dart';
import 'package:eazotel/features/notifications/models/app_notification.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsapp_ui.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.find<NotificationController>();

  /// false = All, true = sirf Unread
  bool _onlyUnread = false;

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This removes them from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) controller.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: p.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          // Notification sound on / off
          Obx(
            () => IconButton(
              tooltip: controller.soundOn.value
                  ? 'Sound on (tap to mute)'
                  : 'Sound off (tap to turn on)',
              onPressed: controller.toggleSound,
              icon: Icon(
                controller.soundOn.value
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: controller.soundOn.value ? p.accent : p.subText,
              ),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'Mark all as read',
              onPressed: controller.unreadCount == 0
                  ? null
                  : controller.markAllRead,
              icon: const Icon(Icons.done_all_rounded),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'Clear all',
              onPressed: controller.items.isEmpty ? null : _confirmClear,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        // Tablet / desktop par beech me, zyada chauda nahi
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Obx(() {
            final all = controller.items;
            final unread = controller.unreadCount;
            final list = _onlyUnread
                ? all.where((n) => !n.isRead).toList()
                : all;

            return Column(
              children: [
                // ---------- All / Unread ----------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: all.length,
                        selected: !_onlyUnread,
                        onTap: () => setState(() => _onlyUnread = false),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Unread',
                        count: unread,
                        selected: _onlyUnread,
                        onTap: () => setState(() => _onlyUnread = true),
                      ),
                    ],
                  ),
                ),

                // ---------- List ----------
                Expanded(
                  child: list.isEmpty
                      ? _Empty(onlyUnread: _onlyUnread)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          children: _grouped(context, list),
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Today / Yesterday / tareekh ke hisaab se heading
  List<Widget> _grouped(BuildContext context, List<AppNotification> list) {
    final p = WaPalette(context);
    final widgets = <Widget>[];
    String? last;

    for (final n in list) {
      final label = _dayLabel(n.createdAt);

      if (label != last) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                color: p.subText,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
          ),
        );
        last = label;
      }

      widgets.add(
        _NotificationTile(
          key: ValueKey(n.id),
          notification: n,
          onTap: () => controller.open(n),
          onDismiss: () => controller.remove(n),
        ),
      );
    }

    return widgets;
  }

  static String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);

    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (d.year == now.year) return DateFormat('d MMMM').format(d);
    return DateFormat('d MMMM y').format(d);
  }
}

// ============================================================
// EK NOTIFICATION
// ============================================================

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  static String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('d MMM').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);
    final n = notification;
    final unread = !n.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('dismiss_${n.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: TAppColors.error.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: TAppColors.error),
        ),
        child: Material(
          color: unread ? p.tint(WaPalette.green) : p.card,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unread
                      ? WaPalette.green.withValues(alpha: .35)
                      : p.border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + chhota WhatsApp nishaan
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      WaAvatar(name: n.title, size: 46),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: WaPalette.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.card, width: 2),
                          ),
                          child: const Icon(
                            Icons.chat_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 14.5,
                                  fontWeight: unread
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeAgo(n.createdAt),
                              style: TextStyle(
                                color: unread ? p.accent : p.subText,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'New WhatsApp message',
                          style: TextStyle(color: p.accent, fontSize: 11.5),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                n.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: unread ? p.text : p.subText,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (unread)
                              Container(
                                width: 9,
                                height: 9,
                                margin: const EdgeInsets.only(left: 8, top: 4),
                                decoration: const BoxDecoration(
                                  color: WaPalette.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ALL / UNREAD CHIP
// ============================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? WaPalette.green : p.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? WaPalette.green : p.border),
          ),
          child: Text(
            '$label ($count)',
            style: TextStyle(
              color: selected ? Colors.white : p.text,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// KHALI
// ============================================================

class _Empty extends StatelessWidget {
  const _Empty({required this.onlyUnread});

  final bool onlyUnread;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: p.tint(WaPalette.green),
                shape: BoxShape.circle,
              ),
              child: Icon(
                onlyUnread
                    ? Icons.mark_chat_read_outlined
                    : Icons.notifications_none_rounded,
                size: 38,
                color: p.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              onlyUnread ? 'All caught up!' : 'No notifications yet',
              style: TextStyle(
                color: p.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'New WhatsApp messages will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subText, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
