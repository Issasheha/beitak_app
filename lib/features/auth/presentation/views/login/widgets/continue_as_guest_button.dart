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
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'متابعة كزائر',
        style: AppTextStyles.body16.copyWith(
          fontSize: SizeConfig.ts(21), // نفس اللي كان موجود
          fontWeight: FontWeight.w300, // نفس الوزن
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
