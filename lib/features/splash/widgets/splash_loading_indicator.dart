import 'package:flutter/material.dart';

class SplashLoadingIndicator extends StatelessWidget {
  const SplashLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: CircularProgressIndicator(
        strokeWidth: 5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.8),),
        backgroundColor: Colors.white.withValues(alpha: 0.2),
      ),
    );
  }
}