import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';
import 'dart:ui';


class OrbitCategoryWidget extends StatelessWidget {
  const OrbitCategoryWidget({super.key});

  static final List<Map<String, dynamic>> _categories = [
    {'name': 'كهربائي', 'icon': Icons.electrical_services},
    {'name': 'تنظيف منازل', 'icon': Icons.cleaning_services},
    {'name': 'مواسرجي', 'icon': Icons.plumbing},
    {'name': 'الدهان', 'icon': Icons.format_paint},
    {'name': 'البناء', 'icon': Icons.construction},
    {'name': 'تكييف', 'icon': Icons.ac_unit},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3, // 3 لكل صف لعرض الكل دون تمرير أفقي
      shrinkWrap: true, // لتقليل الـ scroll، يجعلها تتناسب مع المحتوى
      physics: const NeverScrollableScrollPhysics(), // منع التمرير الداخلي
      mainAxisSpacing: SizeConfig.h(12),
      crossAxisSpacing: SizeConfig.w(12),
      childAspectRatio: 1.0, // نسبة مربعة للتوازن
      children: _categories.map((cat) => GestureDetector(
        onTap: () {
          // لاحقاً: navigation
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: SizeConfig.padding(all: 8),
              decoration: BoxDecoration(
                color: AppColors.buttonBackground.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5),),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'], color: AppColors.lightGreen, size: SizeConfig.ts(32)),
                  SizeConfig.v(8),
                  Text(cat['name'], style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}