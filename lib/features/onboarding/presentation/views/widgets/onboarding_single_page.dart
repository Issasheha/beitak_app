import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // إضافة استيراد لـ flutter_svg

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
            // decoration: BoxDecoration(
            //   shape: BoxShape.circle,
            //   color: AppColors.white.withOpacity(0.1), // خلفية فاتحة إذا رغبت
            //   boxShadow: [AppColors.primaryShadow],
            // ),
            child: SvgPicture.asset(
              'assets/images/Baitak white.svg',  // استبدال الأيقونة بالشعار
              width: 80,  // تحديد عرض الشعار
              height: 80,  // تحديد ارتفاع الشعار
            ),
          ),

          const SizedBox(height: 60),

          // العنوان بالعربي
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 30,
              fontWeight: FontWeight.w900,
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
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 19,
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
