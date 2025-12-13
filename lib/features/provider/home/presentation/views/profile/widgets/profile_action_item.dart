import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProfileActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const ProfileActionItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
      onTap: onTap,
      child: Container(
        padding: SizeConfig.padding(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: itemColor,
              size: SizeConfig.ts(20),
            ),
            SizeConfig.hSpace(12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(14),
                  fontWeight: FontWeight.w500,
                  color: itemColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
              size: SizeConfig.ts(20),
            ),
          ],
        ),
      ),
    );
  }
}
