// import 'package:flutter/material.dart';
//
// class EmergencyButton extends StatelessWidget {
//   const EmergencyButton({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.red.shade400, Colors.red.shade600],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.red.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(30),
//           onTap: () => _handleEmergency(context),
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.emergency, color: Colors.white, size: 28),
//               SizedBox(width: 12),
//               Text(
//                 'EMERGENCY SOS',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _handleEmergency(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.warning, color: Colors.red),
//             SizedBox(width: 8),
//             Text('Emergency SOS'),
//           ],
//         ),
//         content: const Text('Are you sure you want to send an emergency alert?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Emergency alert sent!'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Send Alert', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }
