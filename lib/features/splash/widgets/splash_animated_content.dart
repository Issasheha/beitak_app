import 'package:flutter/material.dart';
import 'splash_logo.dart';
import 'splash_subtitle.dart';
import 'splash_loading_indicator.dart';

class SplashAnimatedContent extends StatelessWidget {
  final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> opacity;
  late final Animation<double> slide;

  SplashAnimatedContent({super.key, required this.controller}) {
    scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );
    opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: controller,
          curve: const Interval(0.3, 0.7, curve: Curves.easeIn)),
    );
    slide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
          parent: controller,
          curve: const Interval(0.5, 1.0, curve: Curves.decelerate)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Opacity(
            opacity: opacity.value,
            child: Transform.scale(
              scale: scale.value,
              child: Transform.translate(
                offset: Offset(0, slide.value),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SplashLogo(),
                    SizedBox(height: 40),
                     SplashSubtitle(),
                    SizedBox(height: 80),
                    SplashLoadingIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
