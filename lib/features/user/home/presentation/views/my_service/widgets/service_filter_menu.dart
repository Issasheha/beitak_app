// // lib/features/home/presentation/views/my_service_widgets/service_filter_menu.dart
// import 'package:beitak_app/core/constants/colors.dart';
// import 'package:beitak_app/core/helpers/size_config.dart';
// import 'package:flutter/material.dart';

// class ServiceFilterMenu extends StatelessWidget {
//   final String selectedFilter;
//   final ValueChanged<String> onFilterChanged;
//   final List<String> filterOptions = const [
//     'الكل',
//     'طلباتي القادمة',
//     'طلباتي الملغية',
//     'طلباتي المكتملة',
//   ];

//   const ServiceFilterMenu({
//     super.key,
//     required this.selectedFilter,
//     required this.onFilterChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       icon: Icon(Icons.filter_list_rounded, color: AppColors.textPrimary, size: SizeConfig.w(26)),
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 10,
//       offset: Offset(0, SizeConfig.h(50)),
//       onSelected: onFilterChanged,
//       itemBuilder: (context) => filterOptions.map((option) {
//         return PopupMenuItem(
//           value: option,
//           child: Row(
//             children: [
//               Icon(
//                 selectedFilter == option ? Icons.radio_button_checked : Icons.radio_button_off,
//                 color: selectedFilter == option ? AppColors.lightGreen : AppColors.textSecondary,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 option,
//                 style: TextStyle(
//                   fontSize: SizeConfig.ts(14),
//                   color: AppColors.textPrimary,
//                   fontWeight: selectedFilter == option ? FontWeight.w600 : FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }