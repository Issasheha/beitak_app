import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class HistoryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const HistoryFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final bg = selected ? (selectedColor ?? AppColors.lightGreen) : Colors.white;
    final borderColor = selected
        ? (selectedColor ?? AppColors.lightGreen)
        : AppColors.borderLight.withValues(alpha: 0.9);
    final textColor = selected ? Colors.white : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
      child: Container(
        height: SizeConfig.h(38),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
