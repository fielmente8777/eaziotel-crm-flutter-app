// import 'package:flutter/material.dart';

// class AttachmentSheet extends StatelessWidget {
//   final VoidCallback onGallery;
//   final VoidCallback onLocation;

//   const AttachmentSheet({
//     super.key,
//     required this.onGallery,
//     required this.onLocation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _item(Icons.photo_library, 'Gallery', Colors.purple, onGallery),
//             _item(Icons.location_on, 'Location', Colors.green, onLocation),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _item(IconData icon, String label, Color color, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundColor: color,
//               child: Icon(icon, color: Colors.white, size: 26),
//             ),
//             const SizedBox(height: 8),
//             Text(label),
//           ],
//         ),
//       ),
//     );
//   }
// }