import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';
import 'package:flutter/material.dart';

class ProviderBusinessInfoSection extends StatelessWidget {
  final ProviderProfileViewModel viewModel;

  const ProviderBusinessInfoSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderProfileSectionCard(
      title: 'معلومات العمل',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadOnlyField(
            label: 'اسم النشاط التجاري',
            value: viewModel.businessName,
            icon: Icons.business_center_outlined,
          ),
          SizeConfig.v(12),
          _ReadOnlyField(
            label: 'اسم المالك',
            value: viewModel.ownerName,
            icon: Icons.person_outline,
          ),
          SizeConfig.v(12),
          _ReadOnlyField(
            label: 'فئة الخدمة',
            value: viewModel.category,
            icon: Icons.category_outlined,
            trailing: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
          ),
          SizeConfig.v(12),
          _ReadOnlyField(
            label: 'وصف النشاط التجاري',
            value: viewModel.description,
            icon: Icons.description_outlined,
            multiLine: true,
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
  final Widget? trailing;
  final bool multiLine;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.trailing,
    this.multiLine = false,
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
            crossAxisAlignment:
                multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                  maxLines: multiLine ? 3 : 1,
                  overflow:
                      multiLine ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13.5),
                    color: AppColors.textPrimary,
                    height: multiLine ? 1.4 : 1.2,
                  ),
                ),
              ),
              if (trailing != null) ...[
                SizeConfig.hSpace(6),
                trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
