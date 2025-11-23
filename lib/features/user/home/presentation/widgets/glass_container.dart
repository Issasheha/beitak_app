import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;

  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
            border: Border.all(color: AppColors.white.withValues(alpha: 0.2),),
            boxShadow: [AppColors.primaryShadow],
          ),
          child: child,
        ),
      ),
    );
  }
}
