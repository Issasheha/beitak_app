import 'dart:math' as math;

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class SendCodeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const SendCodeButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ امن: لا تخلي الزر يصير أصغر من 48 حتى بالـLandscape
    final height = math.max(SizeConfig.h(55.22), 48.0);
    final radius = SizeConfig.w(30);

    // ✅ امن: loader كمان ما يصير صغير زيادة
    final loaderSize = math.max(SizeConfig.h(24.36), 18.0);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: const BorderSide(
              color: AppColors.buttonBackground,
              width: 2,
            ),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? SizedBox(
                height: loaderSize,
                width: loaderSize,
                child: const CircularProgressIndicator(
                  color: AppColors.lightGreen,
                  strokeWidth: 2,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown, // ✅ يمنع تكسر النص بالعرض الضيق
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body16.copyWith(
                    color: AppColors.lightGreen,
                    fontSize: SizeConfig.ts(15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ),
    );
  }
}
