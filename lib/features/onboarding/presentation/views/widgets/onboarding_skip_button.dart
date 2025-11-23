// widgets/onboarding_skip_button.dart
import 'package:flutter/material.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  const OnboardingSkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
        'تخطي',
        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}