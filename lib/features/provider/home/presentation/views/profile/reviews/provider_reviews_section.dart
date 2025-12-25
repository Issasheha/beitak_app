// lib/features/provider/home/presentation/views/profile/reviews/provider_reviews_section.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';

class ProviderReviewsSection extends StatelessWidget {
  final ProviderProfileState state;

  const ProviderReviewsSection({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final hasReviews = state.ratingCount > 0;

    return ProviderProfileSectionCard(
      title: 'التقييمات',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
          onTap: hasReviews ? () => context.push(AppRoutes.providerReviews) : null,
          child: Padding(
            padding: SizeConfig.padding(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: SizeConfig.w(40),
                  height: SizeConfig.w(40),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.lightGreen,
                    size: SizeConfig.w(22),
                  ),
                ),
                SizeConfig.hSpace(12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasReviews ? '${state.rating.toStringAsFixed(1)} من 5' : 'لا يوجد تقييمات بعد',
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(13.6),
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizeConfig.v(4),
                      Text(
                        hasReviews ? 'عدد التقييمات: ${state.ratingCount}' : 'ابدأ بجمع تقييمات من أول عميل 👌',
                        style: AppTextStyles.caption11.copyWith(
                          fontSize: SizeConfig.ts(12),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_left,
                  color: hasReviews ? AppColors.textSecondary : AppColors.textSecondary.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
