// widgets/onboarding_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'onboarding_next_button.dart';
import 'onboarding_skip_button.dart';

class OnboardingActionButtons extends StatelessWidget {
  final int currentPage;
  final PageController pageController;
  final VoidCallback onFinish;

  const OnboardingActionButtons({
    super.key,
    required this.currentPage,
    required this.pageController,
    required this.onFinish,
  });

  Future<void> _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OnboardingSkipButton(onPressed: () => _finishOnboarding(context)),
        currentPage == 2
            ? OnboardingStartButton(onPressed: () => _finishOnboarding(context))
            : OnboardingNextButton(pageController: pageController),
      ],
    );
  }
}