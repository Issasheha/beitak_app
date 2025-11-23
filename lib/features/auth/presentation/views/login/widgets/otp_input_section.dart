// import 'package:beitak_app/core/constants/colors.dart';
// import 'package:beitak_app/core/helpers/size_config.dart';
// import 'package:flutter/material.dart';

// class OtpInputSection extends StatelessWidget {
//   final List<TextEditingController> controllers;
//   final List<FocusNode> focusNodes;
//   final bool isSmall;

//   const OtpInputSection({
//     super.key,
//     required this.controllers,
//     required this.focusNodes,
//     required this.isSmall,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final totalGap = SizeConfig.w(11.25) * 5;          // كان scaleWidth(3) * 5
//         final boxWidth = (constraints.maxWidth - totalGap) / 6;
//         final boxHeight = SizeConfig.h(52.78);             // كان scaleHeight(6.5)

//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(6, (i) {
//             return SizedBox(
//               width: boxWidth,
//               height: boxHeight,
//               child: _OtpBox(
//                 index: i,
//                 controllers: controllers,
//                 focusNodes: focusNodes,
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
// }

// class _OtpBox extends StatelessWidget {
//   final int index;
//   final List<TextEditingController> controllers;
//   final List<FocusNode> focusNodes;

//   const _OtpBox({
//     required this.index,
//     required this.controllers,
//     required this.focusNodes,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final fontSize = SizeConfig.ts(16.88);     // كان scaleText(4.5)
//     final radius = SizeConfig.w(13.5);        // كان scaleWidth(3.6)

//     return TextField(
//       controller: controllers[index],
//       focusNode: focusNodes[index],
//       keyboardType: TextInputType.number,
//       textAlign: TextAlign.center,
//       maxLength: 1,
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: FontWeight.bold,
//         color: Colors.black87,
//       ),
//       decoration: InputDecoration(
//         counterText: '',
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: EdgeInsets.symmetric(
//           vertical: SizeConfig.h(9.74),        // كان scaleHeight(1.2)
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: const BorderSide(
//             color: AppColors.lightGreen,
//             width: 2.5,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: const BorderSide(
//             color: Colors.red,
//             width: 2,
//           ),
//         ),
//       ),
//       onChanged: (value) {
//         if (value.length == 1 && index < 5) {
//           focusNodes[index + 1].requestFocus();
//         } else if (value.isEmpty && index > 0) {
//           focusNodes[index - 1].requestFocus();
//         }
//       },
//     );
//   }
// }
