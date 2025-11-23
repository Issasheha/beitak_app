// features/splash/presentation/views/widgets/splash_view_body.dart
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_animated_content.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // ابدأ الأنيميشن + انتقل بعد ما يخلّص تمامًا
    _controller.forward().then((_) => _completeSplash());
  }

  /// دالة منفصلة عشان نحافظ على الـ Single Responsibility
  Future<void> _completeSplash() async {
    // 1. احفظ إنو شاف الـ Splash
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_splash', true);

    // 2. انتقل للـ Onboarding بأمان
    if (!mounted) return;
    context.go(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF12332C), Color(0xFF64AB68)],
          ),
        ),
        child: Stack(
          children: [
            // const SplashBackground(),
            SplashAnimatedContent(controller: _controller),
          ],
        ),
      ),
    );
  }
}