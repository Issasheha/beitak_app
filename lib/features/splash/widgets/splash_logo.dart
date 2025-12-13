import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: SvgPicture.asset(
        'assets/images/Baitak white.svg',
        width: 140,
        height: 140,
        fit: BoxFit.contain,
      ),
    );
  }
}
