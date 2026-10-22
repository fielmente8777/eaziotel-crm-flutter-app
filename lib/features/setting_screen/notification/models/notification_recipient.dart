// ============================================================
// NOTIFICATION RECIPIENT (model)
//
// A team member who can receive notifications.
// The server keeps only the number / email; the screen shows the member's name.
//
//   "9528295631"            -> "Abhijeet"
//   "abhijeet@eazotel.com"  -> "Abhijeet"
//
// A number / email that matches no member is shown as it is.
// ============================================================

import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';

class NotificationRecipient {
  const NotificationRecipient({
    required this.name,
    required this.phone,
    required this.email,
  });

  final String name;
  final String phone;
  final String email;

  factory NotificationRecipient.fromUser(UserModel user) {
    final display = (user.displayName ?? user.userName ?? '').trim();

    return NotificationRecipient(
      name: display.isEmpty ? (user.emailId ?? '-') : display,
      phone: (user.phone ?? '').trim(),
      email: (user.emailId ?? '').trim(),
    );
  }

  /// "+91 95282 95631" / "919528295631" -> "9528295631"
  static String last10(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  bool hasPhone(String value) =>
      phone.isNotEmpty && last10(phone) == last10(value);

  bool hasEmail(String value) =>
      email.isNotEmpty && email.toLowerCase() == value.trim().toLowerCase();
}
