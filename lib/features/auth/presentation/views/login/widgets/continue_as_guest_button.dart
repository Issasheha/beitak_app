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
    final radius = SizeConfig.radius(18);

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: SizeConfig.padding(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.lightGreen.withValues(alpha: 0.45),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: SizeConfig.ts(22),
                color: AppColors.textPrimary,
              ),
              SizedBox(width: SizeConfig.w(10)),
              Text(
                'متابعة كزائر',
                style: AppTextStyles.body16.copyWith(
                  fontSize: SizeConfig.ts(18), // ✅ أكبر وواضحة
                  fontWeight: FontWeight.w700, // ✅ أوضح من w300
                  color: AppColors.lightGreen,
                  height: 1.1,
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: SizeConfig.ts(18),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
