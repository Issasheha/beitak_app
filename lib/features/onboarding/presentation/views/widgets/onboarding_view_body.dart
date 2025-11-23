import 'package:beitak_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'onboarding_single_page.dart';
import 'onboarding_dots_indicator.dart';
import 'onboarding_action_buttons.dart';

class OnboardingViewBody extends StatefulWidget {
  const OnboardingViewBody({super.key});

  @override
  State<OnboardingViewBody> createState() => _OnboardingViewBodyState();
}

class _OnboardingViewBodyState extends State<OnboardingViewBody> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Stack(
        children: [
          // const OnboardingBackground(),
          PageView(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _currentPage = value),
            children: const [
              OnboardingSinglePage(
                title: "انضم لمجتمع المزودين الموثوقين",
                subtitle:
                    "كل مزودي الخدمة تم فحص خلفيتهم وتقييمهم من عملاء حقيقيين",
              ),
              OnboardingSinglePage(
                title: "احجز وتابع فوراً",
                subtitle: "حدد الخدمة، تابع الحجوزات، وأدر كل شيء من مكان واحد",
              ),
              OnboardingSinglePage(
                title: "ابحث عن خدمات منزلية موثوقة في منطقتك",
                subtitle:
                    "تصفح مئات المزودين المحليين الموثوقين لكل احتياجات منزلك",
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 24,
            right: 24,
            child: Column(
              children: [
                OnboardingDotsIndicator(currentPage: _currentPage),
                const SizedBox(height: 32),
                OnboardingActionButtons(
                  currentPage: _currentPage,
                  pageController: _pageController,
                  onFinish: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
