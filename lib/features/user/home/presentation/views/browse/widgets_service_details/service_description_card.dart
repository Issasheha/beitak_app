import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class ServiceDescriptionCard extends StatelessWidget {
  const ServiceDescriptionCard({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    final text = description.trim().isEmpty ? '—' : description.trim();

    return Container(
      width: double.infinity,
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(title: 'وصف الخدمة'),
          SizeConfig.v(10),
          Text(
            text,
            textAlign: TextAlign.right,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              height: 1.55,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: SizeConfig.w(4),
          height: SizeConfig.h(18),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(SizeConfig.radius(99)),
          ),
        ),
        SizeConfig.hSpace(8),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.semiBold.copyWith(
              fontSize: SizeConfig.ts(14.5),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
