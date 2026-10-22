// ============================================================
// APP ENV  (like src/config/env.js in the web dashboard)
//
// On web:   RAZORPAY_BILLING_KEY_ID = env.VITE_RAZORPAY_BILLING_KEY_ID || "rzp_test_..."
// Here:     the same default key; you can change it at build time:
//   flutter build apk --release --dart-define=RAZORPAY_BILLING_KEY_ID=rzp_live_xxx
//
// Key IDs are public (the secret stays only on the server).
// ============================================================

class AppEnv {
  AppEnv._();

  /// Razorpay Key ID of the Billing page (Plans & billing).
  /// NOTE (same as web): this is a TEST key, payments made with it are not real.
  /// When billing goes live, put the live key here (or pass it with --dart-define).
  static const String razorpayBillingKeyId = String.fromEnvironment(
    'RAZORPAY_BILLING_KEY_ID',
    defaultValue: 'rzp_test_UZ0V9jh3jMC0C9',
  );
}
