import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderManageAvailabilityCard extends StatelessWidget {
  const ProviderManageAvailabilityCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
          child: Container(
            padding: SizeConfig.padding(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
              border: Border.all(
                color: AppColors.lightGreen.withValues(alpha: 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة التوفر',
                        style: AppTextStyles.title18.copyWith(
                          fontSize: SizeConfig.ts(16),
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(6)),
                      Text(
                        'تحكم في أيام وساعات العمل',
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(12.8),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SizeConfig.w(10)),
                Container(
                  width: SizeConfig.w(46),
                  height: SizeConfig.w(46),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGreen.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.lightGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppColors.lightGreen,
                    size: SizeConfig.ts(22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
