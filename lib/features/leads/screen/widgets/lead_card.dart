// ============================================================
// LEAD CARD  (Leads list + Home "Recent Leads")
//
//   (R)  Rahul Sharma                          [ Hot ]
//        📞 +91 98765 43210
//        [🤖 Eazbot]                     ⏱ 2 hours ago
//
// Tap = lead ki detail. Rang: source / stage ke hisaab se
// (light + dark dono me theek).
// ============================================================

import 'package:eazotel/features/leads/models/leads_responce_modle.dart';
import 'package:eazotel/features/leads/screen/lead_details/lead_details_screen.dart';
import 'package:flutter/material.dart';

import 'leads_style.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;

  const LeadCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final p = LeadsPalette(context);

    final name = _value(lead.name, 'Unknown');
    final source = _value(lead.createdFrom, 'Unknown');
    final date = _value(lead.createdAtDate, lead.createdAt ?? '');
    final status = _value(lead.status, 'Unknown');
    final contact = _value(lead.contact, _value(lead.email, ''));
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final displayName = name.isNotEmpty
        ? '${name[0].toUpperCase()}${name.substring(1)}'
        : '';

    final src = LeadsStyle.source(source);
    final stageColor = LeadsStyle.stage(status);
    final avatarColor = LeadsStyle.avatar(name);
    final ago = formatTimelineDate(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeadsDetails(leads: lead),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Avatar ----------
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            avatarColor,
                            avatarColor.withValues(alpha: .7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ---------- Info ----------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _Pill(text: status, color: stageColor, dot: true),
                            ],
                          ),
                          if (contact.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  lead.contact?.trim().isNotEmpty == true
                                      ? Icons.call_outlined
                                      : Icons.mail_outline,
                                  size: 13,
                                  color: p.subText,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    contact,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: p.subText,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Flexible(
                                child: _Pill(
                                  text: source.toUpperCase(),
                                  color: src.color,
                                  icon: src.icon,
                                ),
                              ),
                              const Spacer(),
                              if (ago.isNotEmpty) ...[
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: p.subText,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  ago,
                                  style: TextStyle(
                                    color: p.subText,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Baayein taraf stage ke rang ki patli patti
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: stageColor),
              ),
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.color,
    this.icon,
    this.dot = false,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final p = LeadsPalette(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: p.tint(color),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.tintBorder(color)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          else if (icon != null) ...[
            Icon(icon, size: 13, color: p.onTint(color)),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.onTint(color),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
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
