import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class ContactHiddenHint extends StatelessWidget {
  const ContactHiddenHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: SizeConfig.w(30),
            height: SizeConfig.w(30),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
              border: Border.all(
                color: AppColors.lightGreen.withValues(alpha: 0.22),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '🔒',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                height: 1.0,
              ),
            ),
          ),
          SizedBox(width: SizeConfig.w(10)),
          Expanded(
            child: Text(
              'بيانات التواصل (الهاتف/الإيميل) تظهر بعد قبول الطلب.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(12.2),
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
