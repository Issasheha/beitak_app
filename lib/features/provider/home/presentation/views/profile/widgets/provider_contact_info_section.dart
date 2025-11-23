import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';
import 'package:flutter/material.dart';

class ProviderContactInfoSection extends StatelessWidget {
  final ProviderProfileViewModel viewModel;

  const ProviderContactInfoSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderProfileSectionCard(
      title: 'معلومات التواصل',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadOnlyField(
            label: 'البريد الإلكتروني',
            value: viewModel.email,
            icon: Icons.email_outlined,
          ),
          SizeConfig.v(12),
          _ReadOnlyField(
            label: 'رقم الجوال',
            value: viewModel.phone,
            icon: Icons.phone_outlined,
          ),
          SizeConfig.v(12),
          _ReadOnlyField(
            label: 'منطقة تقديم الخدمة',
            value: viewModel.location,
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            color: AppColors.textSecondary,
          ),
        ),
        SizeConfig.v(6),
        Container(
          padding: SizeConfig.padding(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.lightGreen,
                size: SizeConfig.ts(20),
              ),
              SizeConfig.hSpace(10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13.5),
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
