// ============================================================
// TEAM USER REQUEST (model)
//
// Create / Edit user ki API ka body banata hai.
// Controller sirf form ki value deta hai; body ki shakal yahin tay hoti hai.
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

  /// Optional. Edit me server ko hamesha khali jata hai.
  final String password;

  final LocationOption location;

  /// Chune hue Access Control checkbox (TeamAccess.permissions ki keys)
  final Set<String> selected;

  /// null = naya user (Create), warna jis user ko badalna hai (Edit)
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
        // Edit me user ke baaki hotel jaise the waise hi rahein
        if (user != null)
          for (final other in user.assignedLocation)
            if (other.hid != location.hid) other.toJson(),

        // Chuna hua hotel, nayi access setting ke saath
        {
          'hid': location.hid,
          // Web ka spelling aisa hi hai, aur ye sirf Create me jata hai
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
