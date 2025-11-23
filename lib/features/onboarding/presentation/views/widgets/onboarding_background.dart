// // widgets/onboarding_background.dart
// import 'package:flutter/material.dart';

// class OnboardingBackground extends StatelessWidget {
//   const OnboardingBackground({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           top: -100,
//           left: -100,
//           child: _circle(300, 0.08),
//         ),
//         Positioned(
//           bottom: -150,
//           right: -150,
//           child: _circle(400, 0.1),
//         ),
//       ],
//     );
//   }

//   Widget _circle(double size, double opacity) {
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