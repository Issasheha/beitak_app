// import 'package:beitak_app/core/helpers/size_config.dart';
// import 'package:beitak_app/features/auth/presentation/views/widgets/login_widgets/custom_text_field.dart';
// import 'package:flutter/material.dart';

// class PhoneInputSection extends StatelessWidget {
//   final TextEditingController controller;
//   final bool isSmall;

//   const PhoneInputSection({
//     super.key,
//     required this.controller,
//     required this.isSmall,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CustomTextField(
//           controller: controller,
//           hint: '+962 50 123 4567',
//           prefixIcon: Icons.phone,
//           keyboardType: TextInputType.phone,
//         ),
//         SizedBox(height: SizeConfig.h(14.62)), // كان scaleHeight(1.8)
//       ],
//     );
//   }
// }
