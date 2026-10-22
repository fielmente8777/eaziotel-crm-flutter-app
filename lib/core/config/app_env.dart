// ============================================================
// APP ENV  (web dashboard ke src/config/env.js jaisa)
//
// Web me:   RAZORPAY_BILLING_KEY_ID = env.VITE_RAZORPAY_BILLING_KEY_ID || "rzp_test_..."
// Yahan:    wahi default key; chaho to build ke time badal sakte ho:
//   flutter build apk --release --dart-define=RAZORPAY_BILLING_KEY_ID=rzp_live_xxx
//
// Key IDs public hoti hain (secret sirf server par rehta hai).
// ============================================================

class AppEnv {
  AppEnv._();

  /// Billing page (Plans & billing) ki Razorpay Key ID.
  /// NOTE (web ki tarah): ye TEST key hai, isse payment asli nahi hote.
  /// Billing live karte waqt yahan (ya --dart-define se) live key do.
  static const String razorpayBillingKeyId = String.fromEnvironment(
    'RAZORPAY_BILLING_KEY_ID',
    defaultValue: 'rzp_test_UZ0V9jh3jMC0C9',
  );
}
