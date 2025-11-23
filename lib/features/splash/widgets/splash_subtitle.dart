import 'package:flutter/material.dart';

class SplashSubtitle extends StatelessWidget {
  const SplashSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'خدمات منزلية في دقيقة',
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
        letterSpacing: 1.5,
      ),
    );
  }
}