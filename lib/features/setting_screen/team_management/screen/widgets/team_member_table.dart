// ============================================================
// TEAM MEMBER TABLE  (tablet / window)
//
// Name | Email | Phone | Admin | Date Added | Action
//
// Columns use flex, so on big screens the table fills the full width.
// When space is short it stops at _minWidth and scrolls sideways.
// ============================================================

import 'dart:math' as math;

import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:flutter/material.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/team_management_controller.dart';
import '../../models/team_member_display.dart';
import 'team_delete_dialog.dart';
import 'team_user_form_dialog.dart';

/// The table's minimum width. Below this the table scrolls.
const double _minWidth = 760;

// Column width (the same in the heading and every row)
const int _nameFlex = 3;
const int _emailFlex = 5;
const int _phoneFlex = 3;
const int _roleFlex = 2;
const int _dateFlex = 4;
const double _actionWidth = 90;

class TeamMemberTable extends StatelessWidget {
  const TeamMemberTable({
    super.key,
    required this.members,
    required this.controller,
  });

  final List<UserModel> members;
  final TeamManagementController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = math.max(constraints.maxWidth, _minWidth);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    const _HeaderRow(),
                    for (final user in members)
                      _MemberRow(user: user, controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One table cell (with flex)
Widget _cell(
  String text,
  int flex,
  SettingPalette p, {
  bool header = false,
  bool strong = false,
}) {
  return Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: (header || strong) ? FontWeight.w600 : FontWeight.w400,
          color: header ? p.primary : (strong ? p.text : p.subText),
        ),
      ),
    ),
  );
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      color: p.primary.withValues(alpha: 0.15),
      child: Row(
        children: [
          _cell('Name', _nameFlex, p, header: true),
          _cell('Email', _emailFlex, p, header: true),
          _cell('Phone', _phoneFlex, p, header: true),
          _cell('Admin', _roleFlex, p, header: true),
          _cell('Date Added', _dateFlex, p, header: true),
          SizedBox(
            width: _actionWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Text(
                'Action',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: p.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.user, required this.controller});

  final UserModel user;
  final TeamManagementController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          _cell(user.displayLabel, _nameFlex, p, strong: true),
          _cell(user.emailId ?? '-', _emailFlex, p),
          _cell(user.phone ?? '', _phoneFlex, p),
          _cell(user.roleLabel, _roleFlex, p),
          _cell(user.addedOnLabel, _dateFlex, p),
          SizedBox(
            width: _actionWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              // No edit / delete for a superadmin, just "-"
              child: user.isSuperAdmin
                  ? Text('-', style: TextStyle(color: p.subText))
                  : Row(
                      children: [
                        InkWell(
                          onTap: () =>
                              confirmDeleteTeamUser(context, controller, user),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => showTeamUserForm(
                            context,
                            controller,
                            existing: user,
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: p.subText,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
