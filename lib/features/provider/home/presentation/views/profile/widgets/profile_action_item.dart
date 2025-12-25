import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProfileActionGroupCard extends StatelessWidget {
  final List<Widget> children;

  const ProfileActionGroupCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class ProfileActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  final bool showDivider;

  const ProfileActionItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.lightGreen.withValues(alpha: 0.10),
        highlightColor: AppColors.lightGreen.withValues(alpha: 0.06),
        child: Column(
          children: [
            Padding(
              padding: SizeConfig.padding(vertical: 14, horizontal: 14),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    icon,
                    color: itemColor.withValues(alpha: 0.85),
                    size: SizeConfig.ts(20),
                  ),
                  SizeConfig.hSpace(12),
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(14),
                        fontWeight: FontWeight.w800,
                        color: itemColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    size: SizeConfig.ts(18),
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderLight.withValues(alpha: 0.75),
              ),
          ],
        ),
      ),
    );
  }
}
