 
 import 'package:eazotel/features/splash_screen/screens/splash_screen.dart';
import 'package:eazotel/routs/app_routs.dart';
 import 'package:eazotel/utils/theme/theme.dart';
import 'package:flutter/material.dart';
  
void main() {
  runApp(const MyApp());
}

// ============================================================
// MY APP
// ============================================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;


// them change krne ke liya use krne ha  using button
  void changeTheme(ThemeMode mode) {
    setState(() {
      themeMode = mode;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeAnimationDuration: const Duration(seconds: 0),
      themeAnimationCurve: Curves.easeInOut,
      debugShowCheckedModeBanner: false,

      themeMode: themeMode,

      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,

      initialRoute: '/',
      routes: AppRoutes.routes,
      // home: const SplashScreen(),
    );
  }
}

// ============================================================
// WELCOME SCREEN
// ============================================================

// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       appBar: AppBar(title: const Text('Welcome')),

//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               onPressed: () async {
//                 await googleController.logout();
//               },
//               icon: const Icon(Icons.logout),
//               label: const Text('Logout'),
//             ),
//             SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }



// // ============================================================
// // SETTINGS SCREEN
// // ============================================================

// class SettingsScreen extends StatelessWidget {
//   final void Function(ThemeMode) onThemeChanged;

//   const SettingsScreen({super.key, required this.onThemeChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),

//       body: Padding(
//         padding: const EdgeInsets.all(20),

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Choose Theme',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),

//             const SizedBox(height: 20),

//             // SYSTEM
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   onThemeChanged(ThemeMode.system);
//                 },
//                 child: const Text('System'),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // LIGHT
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   onThemeChanged(ThemeMode.light);
//                 },
//                 child: const Text('Light'),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // DARK
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   onThemeChanged(ThemeMode.dark);
//                 },
//                 child: const Text('Dark'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(const MyApp());
// }

// // ============================================================
// // CONFIG
// // ============================================================

// class ApiConfig {
//   // CHANGE THIS TO YOUR ACTUAL BACKEND URL
//   static const String baseUrl = 'https://nexon.eazotel.com';

//   static const String googleAuthUrl = '$baseUrl/user/googleauth';
// }

// // ============================================================
// // APP
// // ============================================================

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Google Login',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//         useMaterial3: true,
//       ),
//       home: const LoginPage(),
//     );
//   }
// }

// // ============================================================
// // LOGIN PAGE
// // ============================================================

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

//   bool _isLoading = false;

//   // ==========================================================
//   // GOOGLE WEB CLIENT ID
//   // ==========================================================

//   static const String webClientId =
//       '737012285391-mvm0kikmmfqm8vu8hr3lmcc39lb8blj2.apps.googleusercontent.com';

//   @override
//   void initState() {
//     super.initState();

//     _initializeGoogle();
//   }

//   // ==========================================================
//   // INITIALIZE GOOGLE
//   // ==========================================================

//   Future<void> _initializeGoogle() async {
//     try {
//       await _googleSignIn.initialize(serverClientId: webClientId);

//       debugPrint('Google Sign-In initialized successfully');
//     } catch (e) {
//       debugPrint('Google initialization error: $e');
//     }
//   }

//   // ==========================================================
//   // GOOGLE LOGIN
//   // ==========================================================

//   Future<void> _loginWithGoogle() async {
//     if (_isLoading) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // ------------------------------------------------------
//       // STEP 1: GOOGLE LOGIN
//       // ------------------------------------------------------

//       final GoogleSignInAccount account = await _googleSignIn.authenticate();

//       debugPrint('==========================================');
//       debugPrint('GOOGLE LOGIN SUCCESS');
//       debugPrint('==========================================');

//       debugPrint('Google ID       : ${account.id}');
//       debugPrint('Google Name     : ${account.displayName}');
//       debugPrint('Google Email    : ${account.email}');
//       debugPrint('Google Photo    : ${account.photoUrl}');

//       // ------------------------------------------------------
//       // STEP 2: GET AUTHENTICATION
//       // ------------------------------------------------------

//       final GoogleSignInAuthentication authentication = account.authentication;

//       final String? idToken = authentication.idToken;

//       debugPrint('Google ID Token : $idToken');

//       debugPrint('==========================================');

//       // ------------------------------------------------------
//       // CHECK TOKEN
//       // ------------------------------------------------------

//       if (idToken == null || idToken.isEmpty) {
//         throw Exception('Google ID Token is null or empty');
//       }

//       // ------------------------------------------------------
//       // STEP 3: SEND ID TOKEN TO BACKEND
//       // ------------------------------------------------------

//       debugPrint('Sending Google ID Token to backend...');

//       final http.Response response = await http.post(
//         Uri.parse(ApiConfig.googleAuthUrl),

//         headers: {
//           'Authorization': 'Bearer $idToken',
//           'Content-Type': 'application/json',
//         },

//         body: jsonEncode({}),
//       );

//       print('📡 API Status Code: ${response.statusCode}');
//       print('📦 API Response: ${response.body}');

//       // ------------------------------------------------------
//       // STEP 4: PRINT API RESPONSE
//       // ------------------------------------------------------

//       debugPrint('==========================================');
//       debugPrint('GOOGLE AUTH API RESPONSE');
//       debugPrint('==========================================');

//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Headers: ${response.headers}');
//       debugPrint('Body: ${response.body}');

//       debugPrint('==========================================');

//       // ------------------------------------------------------
//       // TRY TO PARSE JSON
//       // ------------------------------------------------------

//       dynamic responseData;

//       try {
//         responseData = jsonDecode(response.body);

//         debugPrint('Parsed Response: $responseData');
//       } catch (e) {
//         responseData = response.body;

//         debugPrint('Response is not JSON');
//       }

//       // ------------------------------------------------------
//       // API SUCCESS
//       // ------------------------------------------------------

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         debugPrint('Google authentication API SUCCESS');

//         if (!mounted) {
//           return;
//         }

//         // ----------------------------------------------------
//         // GO TO HOME PAGE
//         // ----------------------------------------------------

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HomePage(
//               name: account.displayName ?? 'User',
//               email: account.email,
//               photoUrl: account.photoUrl,

//               // Pass backend response to Home if needed
//               apiResponse: responseData,
//             ),
//           ),
//         );
//       } else {
//         // ----------------------------------------------------
//         // API ERROR
//         // ----------------------------------------------------

//         debugPrint(
//           'Google authentication API FAILED: '
//           '${response.statusCode}',
//         );

//         if (!mounted) {
//           return;
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Google authentication failed '
//               '(${response.statusCode})',
//             ),
//           ),
//         );
//       }
//     } on GoogleSignInException catch (e) {
//       debugPrint('==========================================');
//       debugPrint('GOOGLE SIGN-IN ERROR');
//       debugPrint('==========================================');

//       debugPrint('Code: ${e.code}');
//       debugPrint('Description: ${e.description}');

//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.description ?? 'Google Sign-In failed')),
//       );
//     } catch (e) {
//       debugPrint('==========================================');
//       debugPrint('LOGIN ERROR');
//       debugPrint('==========================================');

//       debugPrint('$e');

//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // ==========================================================
//   // UI
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.account_circle, size: 100, color: Colors.blue),

//                 const SizedBox(height: 30),

//                 const Text(
//                   'Welcome',
//                   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 10),

//                 const Text(
//                   'Sign in to continue',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),

//                 const SizedBox(height: 40),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _loginWithGoogle,
//                     icon: _isLoading
//                         ? const SizedBox(
//                             width: 22,
//                             height: 22,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.login, color: Colors.red),
//                     label: Text(
//                       _isLoading ? 'Signing in...' : 'Continue with Google',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ============================================================
// // HOME PAGE
// // ============================================================

// class HomePage extends StatelessWidget {
//   final String name;
//   final String email;
//   final String? photoUrl;

//   final dynamic apiResponse;

//   const HomePage({
//     super.key,
//     required this.name,
//     required this.email,
//     this.photoUrl,
//     this.apiResponse,
//   });

//   // ==========================================================
//   // SIGN OUT
//   // ==========================================================

//   Future<void> _signOut(BuildContext context) async {
//     try {
//       await GoogleSignIn.instance.signOut();

//       debugPrint('Google signed out');

//       if (!context.mounted) {
//         return;
//       }

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     } catch (e) {
//       debugPrint('Sign out error: $e');
//     }
//   }

//   // ==========================================================
//   // UI
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home'), centerTitle: true),

//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // ------------------------------------------------
//               // PROFILE PHOTO
//               // ------------------------------------------------
//               if (photoUrl != null)
//                 CircleAvatar(
//                   radius: 45,
//                   backgroundImage: NetworkImage(photoUrl!),
//                 )
//               else
//                 const CircleAvatar(
//                   radius: 45,
//                   child: Icon(Icons.person, size: 45),
//                 ),

//               const SizedBox(height: 20),

//               // ------------------------------------------------
//               // NAME
//               // ------------------------------------------------
//               Text(
//                 'Welcome, $name',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               // ------------------------------------------------
//               // EMAIL
//               // ------------------------------------------------
//               Text(
//                 email,
//                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//               ),

//               const SizedBox(height: 20),

//               // ------------------------------------------------
//               // BACKEND RESPONSE
//               // ------------------------------------------------
//               if (apiResponse != null)
//                 Text(
//                   'API Response:\n$apiResponse',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 13),
//                 ),

//               const SizedBox(height: 40),

//               // ------------------------------------------------
//               // SIGN OUT
//               // ------------------------------------------------
//               ElevatedButton(
//                 onPressed: () => _signOut(context),
//                 child: const Text('Sign Out'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
