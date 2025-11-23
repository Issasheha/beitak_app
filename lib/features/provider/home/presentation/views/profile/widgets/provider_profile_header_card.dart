import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_viewmodel.dart';
import 'package:flutter/material.dart';

class ProviderProfileHeaderCard extends StatelessWidget {
  final ProviderProfileViewModel viewModel;

  const ProviderProfileHeaderCard({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(all: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: SizeConfig.w(32),
                backgroundColor: AppColors.lightGreen.withValues(alpha: 0.9),
                child: Text(
                  viewModel.initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.ts(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizeConfig.hSpace(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.businessName,
                      style: TextStyle(
                        fontSize: SizeConfig.ts(18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizeConfig.v(4),
                    Text(
                      viewModel.memberSinceLabel,
                      style: TextStyle(
                        fontSize: SizeConfig.ts(13),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizeConfig.v(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            viewModel.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.ts(13),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '• ${viewModel.reviewsCount} تقييم',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.ts(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizeConfig.v(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderStat(
                label: 'الحجوزات',
                value: viewModel.totalBookings.toString(),
              ),
              _HeaderStat(
                label: 'معدل الاستجابة',
                value: '${viewModel.responseRate}٪',
              ),
              _HeaderStat(
                label: 'متوسط الرد',
                value: viewModel.avgResponseTimeLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: SizeConfig.ts(16),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(2),
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.ts(12),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
