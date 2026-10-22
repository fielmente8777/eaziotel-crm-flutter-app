import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/Calls%20Management/screen/widgets/make_call_dialog.dart';
import 'package:eazotel/features/leads/controller/lead_notes_api_controller.dart';
import 'package:eazotel/features/whatsapp/services/whatsapp_chat_opener.dart';
import 'package:eazotel/features/leads/models/leads_responce_modle.dart';
import 'package:eazotel/features/leads/screen/lead_details/widgets/lead_details_notes.dart';
import 'package:eazotel/features/leads/screen/lead_details/widgets/lead_details_overview.dart';
import 'package:eazotel/features/leads/screen/lead_details/widgets/lead_details_timeline.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Container leads_detail_body(
  ThemeData theme,
  BuildContext context,
  bool isDark,
  String phone,
  LeadModel leads,
) {
  // ======================================================
  // GETX CONTROLLER
  // ======================================================

  Get.put(LeadDetailsNotesController(leads));

  final RxInt selectedTab = 0.obs;

  return Container(
    width: double.infinity,
    color: theme.scaffoldBackgroundColor,
    padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // ACTION BUTTONS
        // ======================================================
        Row(
          children: [
            Expanded(
              child: _actionButton(
                context,
                title: 'Call Now',
                icon: Icons.call,
                iconColor: TAppColors.success,
                onTap: () {
                  showMakeCallDialog(context, number: phone);
                },
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _actionButton(
                context,
                title: 'WhatsApp',
                icon: Icons.chat,
                iconColor: isDark
                    ? TAppColors.whatsappDark
                    : TAppColors.whatsappLight,
                onTap: () {
                  // In-app WhatsApp chat (Add Contact if there is none)
                  WhatsappChatOpener.open(
                    context,
                    phone: phone,
                    hid: Get.find<DashboardController>().selectedHotelId.value,
                  );
                },
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _actionButton(
                context,
                title: 'Convert',
                icon: Icons.check_circle_outline,
                iconColor: theme.colorScheme.primary,
                onTap: () {},
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ======================================================
        // LEAD INFORMATION
        // ======================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _infoRow(
                context,
                icon: Icons.email_outlined,
                title: 'EMAIL',
                value: leads.email ?? '-',
              ),

              _divider(context),

              _infoRow(
                context,
                icon: Icons.phone_outlined,
                title: 'PHONE',
                value: phone.isEmpty ? '-' : phone,
              ),

              _divider(context),

              _infoRow(
                context,
                icon: Icons.calendar_today_outlined,
                title: 'CHECK-IN / CHECK-OUT',
                value: _checkInOut(leads),
              ),

              _divider(context),

              _infoRow(
                context,
                icon: Icons.star_border,
                title: 'ROOM PREFERENCE',
                value: 'Deluxe Room · 2 guests',
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ======================================================
        // LEAD AGE
        // ======================================================
        Text(
          'Lead Age: ${_getLeadAge(leads)}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 14),

        // ======================================================
        // TABS
        // ======================================================
        Obx(
          () => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    selectedTab.value = 0;
                  },
                  child: _tabItem(
                    context,
                    'Overview',
                    selected: selectedTab.value == 0,
                  ),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    selectedTab.value = 1;
                  },
                  child: _tabItem(
                    context,
                    'Notes',
                    selected: selectedTab.value == 1,
                  ),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    selectedTab.value = 2;
                  },
                  child: _tabItem(
                    context,
                    'Timeline',
                    selected: selectedTab.value == 2,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ======================================================
        // TAB CONTENT
        // ======================================================
        Obx(() => _buildTabContent(context, selectedTab.value, leads)),
      ],
    ),
  );
}

// ============================================================
// TAB CONTENT
// ============================================================

Widget _buildTabContent(BuildContext context, int tabIndex, LeadModel leads) {
  switch (tabIndex) {
    case 0:
      return LeadsDetailsOverviewContent(context, leads);

    case 1:
      return const LeadDetailsNoteScreen();

    case 2:
      return LeadDetailsTimelineScreen(lead: leads);

    default:
      return LeadsDetailsOverviewContent(context, leads);
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

Widget _actionButton(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);

  return Material(
    color: theme.cardTheme.color,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 19),

            const SizedBox(height: 5),

            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ============================================================
// INFO ROW
// ============================================================

Widget _infoRow(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String value,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: theme.colorScheme.primary),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.80,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: isDark ? Colors.white : TAppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// DIVIDER
// ============================================================

Widget _divider(BuildContext context) {
  return Divider(height: 1, color: Theme.of(context).dividerTheme.color);
}

// ============================================================
// TAB
// ============================================================

Widget _tabItem(BuildContext context, String title, {bool selected = false}) {
  final theme = Theme.of(context);

  return Container(
    height: 32,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
    ),
    child: Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        fontSize: 12,
        color: selected
            ? theme.colorScheme.primary
            : theme.textTheme.bodySmall?.color,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}

// ============================================================
// TIMELINE ITEM
// ============================================================

Widget _timelineItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String time,
  String? message,
}) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: theme.colorScheme.primary),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                time,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),

              if (message != null) ...[
                const SizedBox(height: 7),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// FIRST LETTER
// ============================================================

String _firstLetter(String name) {
  if (name.trim().isEmpty) {
    return 'U';
  }

  return name.trim()[0].toUpperCase();
}

// ============================================================
// SOURCE
// ============================================================

String _getSource(dynamic leads) {
  final source = leads.createdFrom?.trim();

  if (source != null && source.isNotEmpty) {
    return source;
  }

  return 'Webform';
}

// ============================================================
// CHECK IN / CHECK OUT
// ============================================================

String _checkInOut(dynamic leads) {
  final checkIn = leads.checkIn?.trim() ?? '';
  final checkOut = leads.checkOut?.trim() ?? '';

  if (checkIn.isEmpty && checkOut.isEmpty) {
    return '-';
  }

  if (checkIn.isEmpty) {
    return checkOut;
  }

  if (checkOut.isEmpty) {
    return checkIn;
  }

  return '$checkIn → $checkOut';
}

// ============================================================
// LEAD AGE
// ============================================================

String _getLeadAge(dynamic leads) {
  try {
    final createdAt = leads.createdAt;

    if (createdAt == null) {
      return 'Unknown';
    }

    final date = DateTime.tryParse(createdAt.toString());

    if (date == null) {
      return 'Unknown';
    }

    final now = DateTime.now();

    final difference = now.difference(date).inDays;

    if (difference <= 0) {
      return 'Today';
    }

    if (difference == 1) {
      return '1d ago';
    }

    return '${difference}d ago';
  } catch (_) {
    return 'Unknown';
  }
}
