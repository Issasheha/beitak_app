import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const MiniChip({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(10),
        vertical: SizeConfig.h(7),
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(SizeConfig.radius(999)),
        border: Border.all(
          color: AppColors.lightGreen.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            icon,
            size: SizeConfig.ts(14),
            color: AppColors.textSecondary,
          ),
          SizedBox(width: SizeConfig.w(6)),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12),
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
