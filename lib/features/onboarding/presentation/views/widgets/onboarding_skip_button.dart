// widgets/onboarding_skip_button.dart

import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  const OnboardingSkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'تخطي',
        style: AppTextStyles.body14.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }
}
