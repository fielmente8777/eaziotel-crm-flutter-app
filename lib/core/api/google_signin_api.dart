// import 'package:google_sign_in/google_sign_in.dart';

// class GoogleSigninApi {
//   static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

//   static bool _initialized = false;

//   static Future<void> initialize() async {
//     if (_initialized) return;

//     await _googleSignIn.initialize(
//       serverClientId:
//           'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com.50839699197-vl6qonl4otau47b3t4ll2qdcuh0o89qd.apps.googleusercontent.com',
//     );

//     _initialized = true;
//   }

//   static Future<GoogleSignInAccount?> login() async {
//     try {
//       await initialize();

//       if (!_googleSignIn.supportsAuthenticate()) {
//         throw UnsupportedError(
//           'Google Sign-In is not supported on this platform',
//         );
//       }

//       final user = await _googleSignIn.authenticate();

//       return user;
//     } catch (e) {
//       print('Google Sign-In Error: $e');
//       return null;
//     }
//   }

//   static Future<void> logout() async {
//     await _googleSignIn.signOut();
//   }
// }
