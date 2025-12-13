import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderMyServiceHeader extends StatelessWidget {
  const ProviderMyServiceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SizeConfig.padding(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/Baitak Logo.svg',
            height: SizeConfig.h(52),
            fit: BoxFit.contain,
          ),
          SizeConfig.v(10),
          Text(
            'خدماتي وباقاتي',
            textAlign: TextAlign.center,
            style: AppTextStyles.title18.copyWith(
              color: AppColors.textPrimary,
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizeConfig.v(6),
          Text(
            'إدارة الخدمات والباقات المنشورة',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.copyWith(
              color: AppColors.textSecondary,
              fontSize: SizeConfig.ts(13),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
