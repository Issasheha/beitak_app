import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingSinglePage extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingSinglePage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 0),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: SvgPicture.asset(
              'assets/images/Baitak white.svg',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 60),

          // العنوان
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.display32.copyWith(
              fontSize: 30, // نفس السابق
              fontWeight: FontWeight.w700, // بدل w900 (Poppins غالبًا ما فيه 900 إذا انت محمّل Regular فقط)
              color: Colors.white,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 32),

          // النص الفرعي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body16.copyWith(
                fontSize: 19, // نفس السابق
                color: Colors.white70,
                height: 1.7,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
