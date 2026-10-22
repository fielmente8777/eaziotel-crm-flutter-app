// ============================================================
// TEAM USER REQUEST (model)
//
// Builds the body for the Create / Edit user API.
// The controller only gives the form values; the body shape is decided here.
//
//   POST /user/create/<token>   (Create)
//   POST /user/edit/<token>     (Edit)
// ============================================================

import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';

import 'location_option.dart';
import 'team_access.dart';

class TeamUserRequest {
  const TeamUserRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.location,
    required this.selected,
    this.existing,
  });

  final String name;
  final String phone;
  final String email;

  /// Optional. On Edit it is always sent empty to the server.
  final String password;

  final LocationOption location;

  /// Chosen Access Control checkboxes (keys of TeamAccess.permissions)
  final Set<String> selected;

  /// null = new user (Create), otherwise the user being changed (Edit)
  final UserModel? existing;

  bool get isEdit => existing != null;

  Map<String, dynamic> toJson() {
    final user = existing;

    return {
      'emailId': email,
      'phone': phone,
      'displayName': name,
      'userName': name,
      'role': 'admin',
      'access_id': isEdit ? '' : password,
      'isAdmin': false,
      'assigned_location': [
        // On Edit, the user's other hotels stay as they were
        if (user != null)
          for (final other in user.assignedLocation)
            if (other.hid != location.hid) other.toJson(),

        // The chosen hotel, with the new access setting
        {
          'hid': location.hid,
          // The web spells it this way, and it is sent only on Create
          if (!isEdit) 'disPlayLocation': location.name,
          'accessScope': TeamAccess.buildScope(
            selected,
            botKey: isEdit ? 'eazbot' : 'eazobot',
          ),
        },
      ],
    };
  }
}
