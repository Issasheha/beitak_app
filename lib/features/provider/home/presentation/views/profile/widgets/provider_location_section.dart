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

  String _cityOnly(String label) {
    final t = label.trim();
    if (t.isEmpty) return '';

    // جرّب أشهر الفواصل
    final seps = <String>[
      '،', // عربي
      ',', // انجليزي
      ' - ',
      '-',
      '|',
    ];

    for (final s in seps) {
      if (t.contains(s)) {
        final first = t.split(s).first.trim();
        if (first.isNotEmpty) return first;
      }
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final raw = state.locationLabel.trim();
    final city = _cityOnly(raw);

    if (city.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProviderProfileSectionCard(
      title: 'الموقع',
      child: Padding(
        padding: SizeConfig.padding(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: AppColors.lightGreen,
              size: SizeConfig.ts(18),
            ),
            SizeConfig.hSpace(8),
            Expanded(
              child: Text(
                city, // ✅ City فقط
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13.2),
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
