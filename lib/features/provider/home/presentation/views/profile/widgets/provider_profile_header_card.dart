import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';

class ProviderProfileHeaderCard extends StatelessWidget {
  final ProviderProfileState state;

  const ProviderProfileHeaderCard({
    super.key,
    required this.state,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return ('$a$b').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final expLabel =
        state.experienceYears > 0 ? '${state.experienceYears} سنة' : '—';

    return Container(
      padding: SizeConfig.padding(all: 18),
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
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: SizeConfig.w(32),
            backgroundColor: AppColors.lightGreen.withValues(alpha: 0.95),
            child: Text(
              _initials(state.displayName),
              style: AppTextStyles.title18.copyWith(
                fontSize: SizeConfig.ts(18),
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizeConfig.v(10),
          Text(
            state.displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(16),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            state.categoryLabel,
            style: AppTextStyles.label12.copyWith(
              fontSize: SizeConfig.ts(12.5),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeConfig.v(6),
          Text(
            state.memberSinceLabel,
            style: AppTextStyles.label12.copyWith(
              fontSize: SizeConfig.ts(12),
              color: AppColors.textSecondary,
            ),
          ),

          // ✅ NEW: Experience
          SizeConfig.v(6),
          Text(
            'سنوات الخبرة: $expLabel',
            style: AppTextStyles.label12.copyWith(
              fontSize: SizeConfig.ts(12),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizeConfig.v(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(
                value: state.completedBookings.toString(),
                label: 'مكتملة',
              ),
              _Stat(
                value: state.rating.toStringAsFixed(1),
                label: 'التقييم',
              ),
              _Stat(
                value: state.totalBookings.toString(),
                label: 'إجمالي الحجوزات',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: AppTextStyles.title18.copyWith(
            fontSize: SizeConfig.ts(16),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(4),
        Text(
          label,
          style: AppTextStyles.caption11.copyWith(
            fontSize: SizeConfig.ts(11.5),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
