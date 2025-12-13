import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_controller.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';

class ProviderAboutSection extends ConsumerWidget {
  final ProviderProfileState state;
  final ProviderProfileController controller;

  const ProviderAboutSection({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderProfileSectionCard(
      title: 'نبذة عنك',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _openEditBioSheet(context),
              icon: const Icon(Icons.edit, size: 18, color: AppColors.lightGreen),
              label: Text(
                'تعديل',
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.lightGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Text(
            state.bio,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13.5),
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _openEditBioSheet(BuildContext context) {
    final c = TextEditingController(text: state.bio == '—' ? '' : state.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(22))),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.w(16),
            right: SizeConfig.w(16),
            top: SizeConfig.h(14),
            bottom: MediaQuery.of(context).viewInsets.bottom + SizeConfig.h(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: SizeConfig.w(48),
                height: SizeConfig.h(5),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizeConfig.v(14),
              Text(
                'تعديل النبذة',
                style: AppTextStyles.body16.copyWith(
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(12),
              TextField(
                controller: c,
                maxLines: 5,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13.5),
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب نبذة قصيرة عن خدماتك...',
                  hintStyle: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.textSecondary.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                    borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                    borderSide: const BorderSide(color: AppColors.lightGreen),
                  ),
                ),
              ),
              SizeConfig.v(12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    foregroundColor: Colors.white,
                    padding: SizeConfig.padding(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await controller.updateBio(c.text);
                  },
                  child: Text(
                    'حفظ',
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
