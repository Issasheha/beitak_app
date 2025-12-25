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
    if (parts.isEmpty) return 'P';
    final first = parts.first.isNotEmpty ? parts.first[0] : 'P';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  String _s(dynamic v) => (v ?? '').toString().trim();

  String? _profileImageUrl() {
    final p = state.provider;
    final user = (p['user'] is Map) ? (p['user'] as Map) : null;
    final url = _s(user?['profile_image']);
    return url.isEmpty ? null : url;
  }

  bool get _showCategoryChip =>
      state.categoryLabel.trim().isNotEmpty && state.categoryLabel.trim() != '—';

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final initials = _initials(state.displayName);
    final imgUrl = _profileImageUrl();
    final avatarSize = SizeConfig.w(52);

    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ===== Top Row (Avatar + Name/MemberSince) | Category Chip on left =====
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Right block: Avatar (يمين) + اسم + عضو منذ (تحت الاسم)
              Expanded(
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(
                      size: avatarSize,
                      initials: initials,
                      imgUrl: imgUrl,
                    ),
                    SizeConfig.hSpace(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body16.copyWith(
                              fontSize: SizeConfig.ts(16),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1.15,
                            ),
                          ),
                          SizeConfig.v(4),
                          Text(
                            state.memberSinceLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption11.copyWith(
                              fontSize: SizeConfig.ts(12),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Left: Category chip with label
              if (_showCategoryChip) ...[
                SizeConfig.hSpace(10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: SizeConfig.w(155),
                  ),
                  child: _CategoryChip(label: state.categoryLabel),
                ),
              ],
            ],
          ),

          SizeConfig.v(12),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.14)),
          SizeConfig.v(12),

          // ✅ Stats Row (نفس ترتيب التصميم: إجمالي - التقييم - مكتمل)
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: _Stat(
                  value: '${state.totalBookings}',
                  label: 'إجمالي',
                  icon: Icons.calendar_month_outlined,
                ),
              ),
              SizeConfig.hSpace(10),
              Expanded(
                child: _Stat(
                  value: state.ratingCount == 0
                      ? '—'
                      : state.rating.toStringAsFixed(1),
                  label: 'التقييم',
                  icon: Icons.star_border_rounded,
                ),
              ),
              SizeConfig.hSpace(10),
              Expanded(
                child: _Stat(
                  value: '${state.completedBookings}',
                  label: 'مكتمل',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===================== Small Widgets =====================

class _Avatar extends StatelessWidget {
  final double size;
  final String initials;
  final String? imgUrl;

  const _Avatar({
    required this.size,
    required this.initials,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.lightGreen.withValues(alpha: 0.28),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: (imgUrl != null)
          ? Image.network(
              imgUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) {
                return Text(
                  initials,
                  style: AppTextStyles.body16.copyWith(
                    fontSize: SizeConfig.ts(17),
                    fontWeight: FontWeight.w900,
                    color: AppColors.lightGreen,
                  ),
                );
              },
            )
          : Text(
              initials,
              style: AppTextStyles.body16.copyWith(
                fontSize: SizeConfig.ts(17),
                fontWeight: FontWeight.w900,
                color: AppColors.lightGreen,
              ),
            ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        border: Border.all(
          color: AppColors.lightGreen.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'التصنيف',
            style: AppTextStyles.caption11.copyWith(
              fontSize: SizeConfig.ts(11),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizeConfig.v(3),
          Text(
            label,
            // ✅ كامل بدون ...
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption11.copyWith(
              fontSize: SizeConfig.ts(11.6),
              fontWeight: FontWeight.w900,
              color: AppColors.lightGreen,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.body16.copyWith(
              fontSize: SizeConfig.ts(16),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: SizeConfig.ts(16), color: AppColors.textSecondary),
              SizeConfig.hSpace(6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption11.copyWith(
                    fontSize: SizeConfig.ts(11.8),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
