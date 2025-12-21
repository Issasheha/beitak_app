import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProviderStepperHeader extends StatelessWidget {
  final int currentStep;

  const ProviderStepperHeader({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = [
      'المعلومات الشخصية',
      'معلومات العمل',
      'التوفر',
      'التحقق',
    ];

    return Container(
      color: AppColors.cardBackground,
      padding: SizeConfig.padding(left: 16, right: 16, top: 8, bottom: 6),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;

              Color color;
              if (isActive) {
                color = AppColors.primaryGreen;
              } else if (isCompleted) {
                color = AppColors.primaryGreen.withValues(alpha: 0.4);
              } else {
                color = AppColors.borderLight;
              }

              return Expanded(
                child: Container(
                  height: SizeConfig.h(3),
                  margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(2)),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
          SizeConfig.v(6),
          Row(
            children: List.generate(steps.length, (index) {
              final isActive = index == currentStep;

              return Expanded(
                child: Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.overline10.copyWith(
                    fontSize: SizeConfig.ts(10),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? AppColors.primaryGreen
                        : AppColors.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
