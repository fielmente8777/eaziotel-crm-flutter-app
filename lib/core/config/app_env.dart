// ============================================================
// APP ENV  (like src/config/env.js in the web dashboard)
//
// Values come from lib/core/config/app_secrets.dart. That file is in
// .gitignore, so keys never go to GitHub. A new machine copies
// app_secrets.example.dart to app_secrets.dart and fills in the values.
//
// A --dart-define with the same name overrides the value at build time.
// ============================================================

import 'package:eazotel/core/config/app_secrets.dart';

class AppEnv {
  AppEnv._();

  /// Razorpay Key ID of the Billing page (Plans & billing).
  static const String razorpayBillingKeyId = String.fromEnvironment(
    'RAZORPAY_BILLING_KEY_ID',
    defaultValue: AppSecrets.razorpayKeyId,
  );
}
