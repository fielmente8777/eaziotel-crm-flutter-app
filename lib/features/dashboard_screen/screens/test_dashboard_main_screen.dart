// import 'package:eazotel/features/auth/screens/login_screen.dart';
// import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
// import 'package:eazotel/features/dashboard_screen/screens/dashbord_botum_nav.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(DashboardController());
//     // final controller2 = Get.put(GoogleAuthController());

//     return Scaffold(
//       appBar: AppBar(title: const Text('Dashboard')),

//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const DashboardBottomNav(),
//                   ),
//                 );
//               },
//               child: const Text('Go to Dashboard'),
//             ),
//             Obx(() {
//               // Loading
//               if (controller.isLoading.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               // Data nahi mila
//               if (controller.user.value == null) {
//                 return const Center(child: Text('No user data found'));
//               }

//               final data = controller.user.value!.data;

//               return SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         debugPrint('🚪 LOGOUT BUTTON PRESSED');

//                         await controller.googleAuthController.logout();

//                         debugPrint('✅ LOGOUT RETURNED TO BUTTON');

//                         if (!context.mounted) {
//                           debugPrint('❌ CONTEXT NOT MOUNTED');
//                           return;
//                         }

//                         debugPrint('➡️ NAVIGATING TO LOGIN');

//                         Navigator.of(context).pushAndRemoveUntil(
//                           MaterialPageRoute(
//                             builder: (_) => const LoginScreen(),
//                           ),
//                           (route) => false,
//                         );

//                         debugPrint('✅ LOGIN NAVIGATION CALLED');
//                       },
//                       icon: const Icon(Icons.logout),
//                       label: const Text('Logout'),
//                     ),
//                     const Text(
//                       'User Data',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // Filhal API ka poora response show
//                     ...data.entries.map((entry) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 12),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 '${entry.key}:',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             Expanded(flex: 3, child: Text('${entry.value}')),
//                           ],
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }
