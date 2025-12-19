// // lib/features/home/presentation/views/my_service_widgets/service_info_row.dart
// import 'package:beitak_app/core/constants/colors.dart';
// import 'package:beitak_app/core/helpers/size_config.dart';
// import 'package:flutter/material.dart';

// class ServiceInfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final bool isLong;

//   const ServiceInfoRow({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.icon,
//     this.isLong = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: SizeConfig.w(18), color: AppColors.textSecondary),
//               const SizedBox(width: 8),
//               Text(label, style: TextStyle(fontSize: SizeConfig.ts(12), color: AppColors.textSecondary)),
//             ],
//           ),
//           SizeConfig.v(6),
//           Text(
//             value,
//             style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textPrimary, fontWeight: FontWeight.w600),
//             maxLines: isLong ? 2 : 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }