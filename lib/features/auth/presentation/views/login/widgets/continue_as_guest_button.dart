import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
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
        style: TextStyle(
          fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
          fontSize: SizeConfig.ts(21), // Adjusted font size for consistency
        ),
      ),
    );
  }
}