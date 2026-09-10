// void main() {
//   runApp(const MyApp());
// }

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

//   // Your Google Cloud Web OAuth Client ID
//   static const String webClientId =
//       '737012285391-mvm0kikmmfqm8vu8hr3lmcc39lb8blj2.apps.googleusercontent.com';

//   // by hem    737012285391-mvm0kikmmfqm8vu8hr3lmcc39lb8blj2.apps.googleusercontent.com
//   //  737012285391-9546siotjr7vsa62idg77thife8j3gut.apps.googleusercontent.com

//   // 50839699197-plbbimvfa71hf6ujqvqlkkeg71hkepgr.apps.googleusercontent.com
//   // 50839699197-plbbimvfa71hf6ujqvqlkkeg71hkepgr.apps.googleusercontent.com
//   @override
//   void initState() {
//     super.initState();
//     _initializeGoogle();
//   }

//   Future<void> _initializeGoogle() async {
//     try {
//       await _googleSignIn.initialize(serverClientId: webClientId);
//     } catch (e) {
//       debugPrint('Google initialization error: $e');
//     }
//   }

//   Future<void> _loginWithGoogle() async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Start Google Sign-In
//       final GoogleSignInAccount account = await _googleSignIn.authenticate();

//       // Get Google authentication information
//       final GoogleSignInAuthentication authentication = account.authentication;

//       final String? idToken = authentication.idToken;

//       debugPrint('=================================');
//       debugPrint('Google Login Successful');
//       debugPrint('authentication: ${authentication}');
//       debugPrint('Email: ${account.email}');
//       debugPrint('Photo: ${account.photoUrl}');
//       debugPrint('ID Token: $idToken');
//       debugPrint('=================================');

//       if (!mounted) return;

//       // Go to Home page
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomePage(
//             name: account.displayName ?? 'User',
//             email: account.email,
//             photoUrl: account.photoUrl,
//           ),
//         ),
//       );
//     } on GoogleSignInException catch (e) {
//       debugPrint('Google Sign-In Error: ${e.code}');
//       debugPrint('Message: ${e.description}');

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.description ?? 'Google Sign-In failed')),
//       );
//     } catch (e) {
//       debugPrint('Google Sign-In Error: $e');

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

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
//                   'Welcoddme',
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

//   const HomePage({
//     super.key,
//     required this.name,
//     required this.email,
//     this.photoUrl,
//   });

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

//               Text(
//                 'Welcome, $name',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               Text(
//                 email,
//                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//               ),

//               const SizedBox(height: 40),

//               ElevatedButton(
//                 onPressed: () async {
//                   await GoogleSignIn.instance.signOut();

//                   if (!context.mounted) return;

//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const LoginPage()),
//                   );
//                 },
//                 child: const Text('Sign out'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }