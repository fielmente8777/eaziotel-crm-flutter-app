// ============================================================
// TEAM DELETE DIALOG
//
// Asks "Delete user?". On yes, controller.deleteUser.
// ============================================================

import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:flutter/material.dart';

import '../../controller/team_management_controller.dart';

Future<void> confirmDeleteTeamUser(
  BuildContext context,
  TeamManagementController controller,
  UserModel user,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete user'),
      content: Text('Delete ${user.displayName ?? user.emailId}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) controller.deleteUser(user);
}
