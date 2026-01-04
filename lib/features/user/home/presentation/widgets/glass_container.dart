import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;

  const GlassContainer({super.key, required this.child});

  // ✅ cache blur filter (avoid re-creating every build)
  static final ImageFilter _blur = ImageFilter.blur(sigmaX: 6, sigmaY: 6);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // ✅ isolate repaints
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
        child: BackdropFilter(
          filter: _blur,
          child: Container(
            padding: SizeConfig.padding(all: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightGreen.withValues(alpha: 0.3),
                  AppColors.primaryGreen.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.2),
              ),
              boxShadow: [AppColors.primaryShadow],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
