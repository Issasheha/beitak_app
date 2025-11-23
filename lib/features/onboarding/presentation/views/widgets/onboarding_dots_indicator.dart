// widgets/onboarding_dots_indicator.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final int currentPage;
  const OnboardingDotsIndicator({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: currentPage == index ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: currentPage == index ? AppColors.buttonBackground : Colors.white38,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}