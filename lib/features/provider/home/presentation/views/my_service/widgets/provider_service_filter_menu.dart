// import 'package:flutter/material.dart';
// import 'package:beitak_app/core/constants/colors.dart';

// class ProviderServiceFilterMenu extends StatelessWidget {
//   final String selectedFilter;
//   final ValueChanged<String> onFilterChanged;

//   const ProviderServiceFilterMenu({
//     super.key,
//     required this.selectedFilter,
//     required this.onFilterChanged,
//   });

//   final List<String> filters = const [
//     'الكل',
//     'الوظائف الحالية',
//     'الوظائف المكتملة',
//     'الملغاة',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.filter_list_rounded,
//           color: AppColors.textPrimary, size: 26),
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       onSelected: onFilterChanged,
//       itemBuilder: (context) => filters.map((option) {
//         return PopupMenuItem(
//           value: option,
//           child: Row(
//             children: [
//               Icon(
//                 selectedFilter == option
//                     ? Icons.check_circle
//                     : Icons.circle_outlined,
//                 color: selectedFilter == option
//                     ? AppColors.lightGreen
//                     : AppColors.textSecondary,
//                 size: 18,
//               ),
//               const SizedBox(width: 10),
//               Text(option,
//                   style: TextStyle(
//                       color: AppColors.textPrimary,
//                       fontWeight: selectedFilter == option
//                           ? FontWeight.w600
//                           : FontWeight.w400)),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
