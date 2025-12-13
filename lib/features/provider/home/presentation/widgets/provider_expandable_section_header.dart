import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderExpandableSectionHeader extends StatelessWidget {
  const ProviderExpandableSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.emoji,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int count;
  final String emoji;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        child: Container(
          padding: SizeConfig.padding(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
            border: Border.all(color: AppColors.lightGreen.o(0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.o(0.06),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: SizeConfig.w(38),
                height: SizeConfig.w(38),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                  color: AppColors.lightGreen.o(0.12),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: AppTextStyles.title18.copyWith(
                    fontSize: SizeConfig.ts(20),
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title18.copyWith(
                        fontSize: SizeConfig.ts(15.2),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(6)),
                    Text(
                      subtitle,
                      style: AppTextStyles.body16.copyWith(
                        fontSize: SizeConfig.ts(12.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: SizeConfig.w(26),
                height: SizeConfig.w(26),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: count == 0
                      ? AppColors.lightGreen.o(0.12)
                      : const Color(0xFFFFC107),
                ),
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: AppTextStyles.body16.copyWith(
                    fontSize: SizeConfig.ts(12),
                    fontWeight: FontWeight.w900,
                    color: count == 0 ? AppColors.lightGreen : Colors.black,
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Container(
                width: SizeConfig.w(34),
                height: SizeConfig.w(34),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGreen.o(0.10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: SizeConfig.ts(22),
                  color: AppColors.lightGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
