import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class ContinueAsGuestButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ContinueAsGuestButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final height = SizeConfig.h(52);
    final radius = SizeConfig.radius(30);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.lightGreen.withValues(alpha: 0.08),
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.lightGreen.withValues(alpha: 0.55),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: SizeConfig.padding(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: SizeConfig.ts(20),
              color: AppColors.textPrimary,
            ),
            SizedBox(width: SizeConfig.w(10)),
            Text(
              'متابعة كزائر',
              style: AppTextStyles.body16.copyWith(
                fontSize: SizeConfig.ts(17),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: SizeConfig.w(10)),
            Icon(
              Icons.arrow_back_ios_new_rounded, // ✅ RTL: سهم لليسار
              size: SizeConfig.ts(16),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
