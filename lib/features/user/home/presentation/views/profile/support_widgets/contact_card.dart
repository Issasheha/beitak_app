// // lib/features/support/presentation/views/support_widgets/contact_card.dart

// import 'package:beitak_app/core/constants/colors.dart';
// import 'package:beitak_app/core/helpers/size_config.dart';
// import 'package:flutter/material.dart';

// class ContactCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final Color color;

//   const ContactCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: SizeConfig.w(82),
//       padding: SizeConfig.padding(vertical: 20, horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(26),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.7),
//             blurRadius: 16,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.15),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 34, color: color),
//           ),
//           SizeConfig.v(14),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: SizeConfig.ts(12.5),
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//               height: 1.3,
//             ),
//           ),
//           SizeConfig.v(6),
//           Text(
//             subtitle,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: SizeConfig.ts(11),
//               color: AppColors.textSecondary,
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
