// import 'package:beitak_app/core/constants/colors.dart';
// import 'package:beitak_app/core/helpers/size_config.dart';
// import 'package:flutter/material.dart';

// class CreateAccountButton extends StatelessWidget {
//   const CreateAccountButton(
//       {super.key, this.onPressed, this.isLoading = false});
//   final VoidCallback? onPressed;
//   final bool isLoading;
//   @override
//   Widget build(BuildContext context) {
//     final radius = SizeConfig.w(30);

//     return SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: isLoading ? null : onPressed,
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(radius), // تحديد الدائرية
//               side: const BorderSide(
//                 color: AppColors.buttonBackground, // تحديد لون الحد
//                 width: 2, // تحديد سماكة الحد
//               ),
//             ),
//             elevation: 8,
//           ),
//           child: Text(
//             'إنشاء حساب',
//             style: TextStyle(
//               color: AppColors.lightGreen,
//                   fontSize: SizeConfig.ts(15),
//                   fontWeight: FontWeight.bold,
//             ),
//           ),
//         ));
//   }
// }
