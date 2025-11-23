// import 'package:beitak_app/core/constants/colors.dart';
// import 'package:flutter/material.dart';

// class LoginBackground extends StatelessWidget {
//   const LoginBackground({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context);
//     final height = media.size.height;
//     final bool keyboardVisible = media.viewInsets.bottom > 0;
//     final bool isSmallHeight = height < 700;
//     final bool showBottomCircle = !keyboardVisible && !isSmallHeight;
//     return IgnorePointer(
//       ignoring: true,
//       child: Stack(
//         children: [
//           const Positioned(
//             top: -80,
//             left: -80,
//             child: _Circle(size: 250, opacity: 0.08),
//           ),
//           if (showBottomCircle)
//             const Positioned(
//               bottom: -120,
//               right: -120,
//               child: _Circle(size: 320, opacity: 0.10),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _Circle extends StatelessWidget {
//   final double size;
//   final double opacity;
//   const _Circle({
//     required this.size,
//     required this.opacity,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: AppColors.lightGreen.withOpacity(
//             opacity), // تغيير إلى لون أخضر خفيف للتوافق مع الـ profile
//       ),
//     );
//   }
// }
