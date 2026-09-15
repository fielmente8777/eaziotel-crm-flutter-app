import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/LeadsDeatils/leads_details.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;

  const LeadCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? TAppColors.darkCard : TAppColors.lightCard;

    final borderColor = isDark ? TAppColors.darkBorder : TAppColors.lightBorder;

    final name = _value(lead.name, 'Unknown');

    final source = _value(lead.createdFrom, 'Unknown');

    final date = _value(lead.createdAtDate, lead.createdAt ?? '');

    final status = _value(lead.status, 'Unknown');

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LeadsDetails(leads: lead)),
        );
      },
      child: Container(
        height: 120,

        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color: cardColor,

          borderRadius: BorderRadius.circular(20),

          border: Border(left: BorderSide(color: borderColor, width: 5)),
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

          child: Row(
            children: [
              _Avatar(initial: initial),

              const SizedBox(width: 14),

              Expanded(
                child: _LeadInfo(name: name, source: source, date: date),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 35, right: 5),

                  child: Text(
                    formatTimelineDate(date),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: TAppColors.darkSecondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              _Status(status: status),
            ],
          ),
        ),
      ),
    );
  }

  String _value(String? value, String fallback) {
    return value?.trim().isNotEmpty == true ? value!.trim() : fallback;
  }
}

// ============================================================
// AVATAR
// ============================================================

class _Avatar extends StatelessWidget {
  final String initial;

  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? TAppColors.lightBackground
        : TAppColors.lightBackground;

    final textColor = isDark ? TAppColors.primary : TAppColors.primary;

    return Container(
      width: 48,
      height: 48,

      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),

      alignment: Alignment.center,

      child: Text(
        initial,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// LEAD INFO
// ============================================================

class _LeadInfo extends StatelessWidget {
  final String name;
  final String source;
  final String date;

  const _LeadInfo({
    required this.name,
    required this.source,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sourceBackground = isDark
        ? TAppColors.lightBackground
        : TAppColors.lightBackground;

    final primaryTextColor = isDark
        ? TAppColors.darkText
        : TAppColors.lightText;

    final secondaryTextColor = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text(
          name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : '',

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: sourceBackground,
            borderRadius: BorderRadius.circular(20),
          ),

          padding: const EdgeInsets.all(8),

          child: Text(
            source.toUpperCase(),

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(color: secondaryTextColor, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STATUS
// ============================================================

class _Status extends StatelessWidget {
  final String status;

  const _Status({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? TAppColors.lightBackground
        : TAppColors.lightBackground;

    final textColor = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Text(
        status,

        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

String formatTimelineDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return '';
  }

  final date = DateTime.tryParse(dateString);

  if (date == null) {
    return '';
  }

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.isNegative) {
    final futureDifference = date.difference(now);

    if (futureDifference.inDays > 0) {
      return 'in ${futureDifference.inDays} days';
    }

    if (futureDifference.inHours > 0) {
      return 'in ${futureDifference.inHours} hours';
    }

    return 'in ${futureDifference.inMinutes} minutes';
  }

  if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }

  if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  }

  if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  }

  return 'Just now';
}
