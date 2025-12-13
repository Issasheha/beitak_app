// lib/features/provider/home/presentation/views/profile/widgets/provider_location_section.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';

class ProviderLocationSection extends StatelessWidget {
  final ProviderProfileState state;

  const ProviderLocationSection({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    String locationLabel = state.locationLabel;

    try {
      final provider = state.provider;
      final user = provider['user'] as Map<String, dynamic>?;
      final city = user?['city'] as Map<String, dynamic>?;

      if (city != null) {
        final nameAr = city['name_ar'] as String?;
        final nameEn = city['name_en'] as String?;
        final name = city['name'] as String?;
        final slug = city['slug'] as String?;

        final computed = (nameAr ?? nameEn ?? name ?? slug)?.trim();

        if (computed != null && computed.isNotEmpty) {
          locationLabel = computed; // مثال: "عمان"
        }
      }
    } catch (_) {
      // لو صار أي خطأ، نرجع لقيمة state.locationLabel بدون كراش
    }

    return ProviderProfileSectionCard(
      title: 'موقع الخدمة',
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.lightGreen,
          ),
          SizeConfig.hSpace(10),
          Expanded(
            child: Text(
              locationLabel,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13.5),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // حالياً UI فقط زي ما اتفقنا
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريبًا')),
              );
            },
            child: Text(
              'تعديل',
              style: AppTextStyles.body14.copyWith(
                color: AppColors.lightGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
