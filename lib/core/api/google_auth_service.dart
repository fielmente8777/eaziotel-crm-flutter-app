import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  static const String webClientId =
      '737012285391-mvm0kikmmfqm8vu8hr3lmcc39lb8blj2.apps.googleusercontent.com';

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _googleSignIn.initialize(
      serverClientId: webClientId,
    );

    _initialized = true;

    print('✅ Google initialized');
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  static Future<GoogleSignInAccount?>
      signIn() async {
    await initialize();

    try {
      final account =
          await _googleSignIn.authenticate();

      print(
        '✅ Google Sign In Successful',
      );

      print(
        '👤 Google User: ${account.email}',
      );

      return account;
    } catch (e) {
      print(
        '❌ Google Sign In Error: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();

      print(
        '🚪 Google Sign Out Successful',
      );
    } catch (e) {
      print(
        '❌ Google Sign Out Error: $e',
      );

      rethrow;
    }
  }
}