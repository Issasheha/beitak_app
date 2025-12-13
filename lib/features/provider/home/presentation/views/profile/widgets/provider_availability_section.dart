import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_controller.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';

class ProviderAvailabilitySection extends StatelessWidget {
  final ProviderProfileState state;
  final ProviderProfileController controller;

  const ProviderAvailabilitySection({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderProfileSectionCard(
      title: 'حالة التوفر',
      child: Row(
        children: [
          Expanded(
            child: Text(
              state.isAvailable ? 'متاح لحجز جديد' : 'غير متاح',
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13.5),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: state.isAvailable,
            onChanged: (v) => controller.updateAvailability(v),
            activeTrackColor: AppColors.lightGreen,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
