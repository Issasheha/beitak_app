import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderEmptyWhiteBox extends StatelessWidget {
  const ProviderEmptyWhiteBox({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SizeConfig.padding(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(0.04),
            blurRadius: 12,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

