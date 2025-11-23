import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';


class PopularSearchesWidget extends StatelessWidget {
  const PopularSearchesWidget({super.key});

  static final List<String> _searches = [
    'تنظيف المنزل',
    'إصلاح التكييف',
    'خدمات النقل',
    'السباكة',
    'أعمال كهربائية',
    'الدهان',
    'عناية بالحيوانات',
    'عامل ماهر',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البحث الشائع',
          style: TextStyle(
            fontSize: SizeConfig.ts(18),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(8),
        Wrap(
          spacing: SizeConfig.w(8),
          runSpacing: SizeConfig.h(8),
          children: _searches.map((search) => ActionChip(
            label: Text(search, style: TextStyle(fontSize: SizeConfig.ts(14))),
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizeConfig.radius(20))),
            onPressed: () {
              // لاحقاً: بحث
            },
          )).toList(),
        ),
      ],
    );
  }
}