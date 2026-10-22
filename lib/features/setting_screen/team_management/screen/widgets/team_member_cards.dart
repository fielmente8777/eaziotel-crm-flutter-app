// ============================================================
// TEAM MEMBER CARDS  (phone)
//
// One card per member: avatar, name, role, email, phone, date,
// and Edit / Delete at the bottom (not for superadmin).
// ============================================================

import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:flutter/material.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/team_management_controller.dart';
import '../../models/team_member_display.dart';
import 'team_delete_dialog.dart';
import 'team_user_form_dialog.dart';

class TeamMemberCards extends StatelessWidget {
  const TeamMemberCards({
    super.key,
    required this.members,
    required this.controller,
  });

  final List<UserModel> members;
  final TeamManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final user in members)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MemberCard(user: user, controller: controller),
          ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.user, required this.controller});

  final UserModel user;
  final TeamManagementController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final name = user.displayLabel;
    final phone = (user.phone ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.primary.withValues(alpha: 0.04),
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Avatar + name + role ----------
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: p.primary.withValues(alpha: 0.18),
                child: Text(
                  name == '-' ? '?' : name[0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: p.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
              ),
              _RoleChip(label: user.roleLabel),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: p.border),
          const SizedBox(height: 12),

          // ---------- Jaankari ----------
          _InfoRow(icon: Icons.mail_outline, text: user.emailId ?? '-'),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.phone_outlined, text: phone),
          ],
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: user.addedOnLabel,
          ),

          // ---------- Edit / Delete (not for superadmin) ----------
          if (!user.isSuperAdmin) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        showTeamUserForm(context, controller, existing: user),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        confirmDeleteTeamUser(context, controller, user),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: p.subText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: p.subText),
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: p.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: p.primary,
        ),
      ),
    );
  }
}
