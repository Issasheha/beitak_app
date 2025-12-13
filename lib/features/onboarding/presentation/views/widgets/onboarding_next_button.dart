// onboarding_next_button.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

// widgets/onboarding_next_button.dart

class OnboardingNextButton extends StatelessWidget {
  final PageController pageController;
  const OnboardingNextButton({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return _GradientButton(
      text: "التالي",
      onPressed: () => pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }
}

class OnboardingStartButton extends StatelessWidget {
  final VoidCallback onPressed;
  const OnboardingStartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _GradientButton(text: "ابدأ الآن", onPressed: onPressed);
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.buttonBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: AppTextStyles.body16.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
