// // splash_background.dart
// import 'package:flutter/material.dart';

// class SplashBackground extends StatelessWidget {
//   const SplashBackground({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           top: -100,
//           left: -100,
//           child: _buildCircle(300, 0.05),
//         ),
//         Positioned(
//           bottom: -150,
//           right: -150,
//           child: _buildCircle(400, 0.08),
//         ),
//       ],
//     );
//   }

//   Widget _buildCircle(double size, double opacity) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white.withOpacity(opacity),
//       ),
//     );
//   }
// }