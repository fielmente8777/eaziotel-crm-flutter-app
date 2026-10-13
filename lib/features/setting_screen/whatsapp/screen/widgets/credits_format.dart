// ============================================================
// CREDITS FORMAT
//
// Credits & Usage page par paise aur tareekh dikhane ke chhote helper.
// Overview aur Transactions dono inhe use karte hain.
// ============================================================

import 'package:intl/intl.dart';

final NumberFormat _count = NumberFormat('#,##0');
final NumberFormat _rate = NumberFormat('0.####');

/// 949.3999 -> "₹949.40"   |   1000 -> "₹1,000.00"
///
/// Pehle paise tak round karte hain (web ki tarah: 52.485 -> 52.49),
/// taaki app aur web par ek hi rakam dikhe. Phir hazaar ka comma lagta hai.
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

/// "7 Oct 2026"  (tareekh na ho to "-")
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
