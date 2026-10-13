// ============================================================
// NOTIFICATION RECIPIENT (model)
//
// Team ka ek member jise notification ja sakta hai.
// Server sirf number / email rakhta hai, screen par member ka naam dikhta hai.
//
//   "9528295631"            -> "Abhijeet"
//   "abhijeet@eazotel.com"  -> "Abhijeet"
//
// Jo number / email kisi member se na mile, wo jaisa hai waisa dikhta hai.
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
