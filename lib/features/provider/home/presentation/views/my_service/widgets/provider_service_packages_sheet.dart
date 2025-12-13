// import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_package_details_sheet.dart';
// import 'package:flutter/material.dart';
// import 'package:beitak_app/core/constants/colors.dart';
// import 'package:beitak_app/core/helpers/size_config.dart';

// import '../models/provider_service_model.dart';
// import '../models/provider_package_model.dart';

// class ProviderServicePackagesSheet extends StatelessWidget {
//   final ProviderServiceModel service;

//   const ProviderServicePackagesSheet({
//     super.key,
//     required this.service,
//   });

//   void _openPackageDetails(BuildContext context, ProviderPackageModel pkg) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => ProviderPackageDetailsSheet(
//         serviceName: service.name,
//         package: pkg,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height * 0.80;

//     return Container(
//       height: height,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(
//           left: SizeConfig.w(18),
//           right: SizeConfig.w(18),
//           top: SizeConfig.h(14),
//           bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 46,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.black.withValues(alpha: 0.08),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),
//             SizeConfig.v(14),

//             Text(
//               'باقات خدمة: ${service.name}',
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w900,
//                 fontSize: SizeConfig.ts(16),
//               ),
//             ),
//             SizeConfig.v(10),

//             Expanded(
//               child: service.packages.isEmpty
//                   ? const Center(
//                       child: Text(
//                         'لا توجد باقات لهذه الخدمة',
//                         style: TextStyle(color: AppColors.textSecondary),
//                       ),
//                     )
//                   : ListView.separated(
//                       physics: const BouncingScrollPhysics(),
//                       itemCount: service.packages.length,
//                       separatorBuilder: (_, __) => SizeConfig.v(10),
//                       itemBuilder: (context, i) {
//                         final p = service.packages[i];
//                         return _PackageTile(
//                           package: p,
//                           onTap: () => _openPackageDetails(context, p),
//                         );
//                       },
//                     ),
//             ),

//             SizeConfig.v(10),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: OutlinedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: AppColors.lightGreen,
//                   side: const BorderSide(color: AppColors.lightGreen),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                 ),
//                 child: const Text('إغلاق'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _PackageTile extends StatelessWidget {
//   final ProviderPackageModel package;
//   final VoidCallback onTap;

//   const _PackageTile({
//     required this.package,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final price = (package.price == package.price.roundToDouble())
//         ? package.price.toStringAsFixed(0)
//         : package.price.toStringAsFixed(2);

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         padding: SizeConfig.padding(all: 14),
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: AppColors.lightGreen.withValues(alpha: 0.14),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.view_module_rounded, color: AppColors.lightGreen),
//             ),
//             SizedBox(width: SizeConfig.w(12)),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     package.name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: AppColors.textPrimary,
//                       fontWeight: FontWeight.w800,
//                       fontSize: SizeConfig.ts(14.5),
//                     ),
//                   ),
//                   if ((package.description ?? '').trim().isNotEmpty) ...[
//                     SizeConfig.v(4),
//                     Text(
//                       package.description!,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: AppColors.textSecondary,
//                         fontSize: SizeConfig.ts(12.5),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             SizedBox(width: SizeConfig.w(10)),
//             Text(
//               '$price د.أ',
//               style: TextStyle(
//                 color: AppColors.lightGreen,
//                 fontWeight: FontWeight.w900,
//                 fontSize: SizeConfig.ts(13.5),
//               ),
//             ),
//             SizedBox(width: SizeConfig.w(6)),
//             const Icon(Icons.chevron_left, color: AppColors.textSecondary),
//           ],
//         ),
//       ),
//     );
//   }
// }
