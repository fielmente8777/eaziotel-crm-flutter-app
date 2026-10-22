// ============================================================
// TEAM MEMBER DISPLAY
//
// Small helpers on UserModel (the dashboard's model), so the card and the table
// both show the name, role and date the same way.
//
//   user.isSuperAdmin   -> true / false
//   user.displayLabel   -> "Rachita kumar"  ("-" if empty)
//   user.roleLabel      -> "superadmin" / "admin" / "user"
//   user.addedOnLabel   -> "19/03/2026, 08:28 am"
// ============================================================

import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';

extension TeamMemberDisplay on UserModel {
  /// A superadmin cannot be edited / deleted
  bool get isSuperAdmin => (role ?? '').toLowerCase() == 'superadmin';

  /// Name, first letter capital
  String get displayLabel {
    final name = (displayName ?? userName ?? '').trim();

    if (name.isEmpty) return '-';

    return name[0].toUpperCase() + name.substring(1);
  }

  /// The role if there is one, otherwise from isAdmin
  String get roleLabel {
    final value = role ?? '';

    if (value.isNotEmpty) return value;

    return isAdmin == true ? 'admin' : 'user';
  }

  /// "2026-03-19 08:28:21.634434" -> "19/03/2026, 08:28 am"
  String get addedOnLabel {
    final date = DateTime.tryParse(createdAt ?? '');
    if (date == null) return '-';

    String two(int n) => n.toString().padLeft(2, '0');

    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour >= 12 ? 'pm' : 'am';

    return '${two(date.day)}/${two(date.month)}/${date.year}, '
        '${two(hour12)}:${two(date.minute)} $period';
  }
}
