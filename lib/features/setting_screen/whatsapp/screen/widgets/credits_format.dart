// ============================================================
// CREDITS FORMAT
//
// Small helpers to show money and dates on the Credits & Usage page.
// Both Overview and Transactions use them.
// ============================================================

import 'package:intl/intl.dart';

final NumberFormat _count = NumberFormat('#,##0');
final NumberFormat _rate = NumberFormat('0.####');

/// 949.3999 -> "₹949.40"   |   1000 -> "₹1,000.00"
///
/// First round to paise (like the web: 52.485 -> 52.49),
/// so the app and web show the same amount. Then add thousands commas.
String formatMoney(double value) {
  final paise = (value * 100).round(); // 100000
  final fixed = (paise / 100).toStringAsFixed(2); // "1000.00"
  final parts = fixed.split('.');

  final rupees = _count.format(int.parse(parts[0])); // "1,000"

  return '₹$rupees.${parts[1]}';
}

/// 0.115 -> "₹0.115"   |   0.7846 -> "₹0.7846"
String formatRate(double value) => '₹${_rate.format(value)}';

/// 1000 -> "1,000"
String formatCount(int value) => _count.format(value);

/// "7 Oct 2026"  ("-" if there is no date)
String formatDate(DateTime? date) {
  return date == null ? '-' : DateFormat('d MMM yyyy').format(date);
}

/// "07 Oct 2026, 12:00 pm"
String formatDateTime(DateTime? date) {
  if (date == null) return '-';

  final day = DateFormat('dd MMM yyyy').format(date);
  final time = DateFormat('hh:mm a').format(date).toLowerCase();

  return '$day, $time';
}
