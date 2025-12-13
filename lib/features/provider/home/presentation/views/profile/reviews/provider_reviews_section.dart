// lib/features/provider/home/presentation/views/profile/widgets/provider_reviews_section.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderReviewsSection extends StatelessWidget {
  final ProviderProfileState state;

  const ProviderReviewsSection({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderProfileSectionCard(
      title: 'التقييمات والمراجعات',
      child: InkWell(
        onTap: () => context.pushNamed(AppRoutes.providerReviews),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        child: Padding(
          padding: SizeConfig.padding(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Container(
                padding:
                    SizeConfig.padding(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(SizeConfig.radius(14)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.lightGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: SizeConfig.ts(14),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizeConfig.hSpace(12),
              Expanded(
                child: Text(
                  '${state.ratingCount} تقييم',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
