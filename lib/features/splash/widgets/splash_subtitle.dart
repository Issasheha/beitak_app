import 'package:flutter/material.dart';

import 'package:beitak_app/core/utils/app_text_styles.dart';

class SplashSubtitle extends StatelessWidget {
  const SplashSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'خدمات منزلية في دقيقة',
      style: AppTextStyles.body16.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
        letterSpacing: 1.5,
      ),
    );
  }
}
