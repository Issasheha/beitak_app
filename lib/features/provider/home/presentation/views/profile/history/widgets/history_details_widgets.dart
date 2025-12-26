import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class HistoryDetailsCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? bgColor;

  const HistoryDetailsCard({
    super.key,
    required this.child,
    this.borderColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      padding: SizeConfig.padding(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: borderColor ?? AppColors.borderLight.withValues(alpha: 0.8),
        ),
      ),
      child: child,
    );
  }
}

class HistoryDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final FontWeight? valueWeight;

  const HistoryDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Row(
      children: [
        Container(
          width: SizeConfig.w(36),
          height: SizeConfig.w(36),
          decoration: BoxDecoration(
            color: AppColors.lightGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.lightGreen, size: SizeConfig.w(20)),
        ),
        SizeConfig.hSpace(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption11.copyWith(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizeConfig.v(2),
              Text(
                value.trim().isEmpty ? '—' : value,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13.5),
                  color: AppColors.textPrimary,
                  fontWeight: valueWeight ?? FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
