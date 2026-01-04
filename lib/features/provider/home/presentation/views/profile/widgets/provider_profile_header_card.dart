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
    final avatarSize = SizeConfig.w(56);

    final city = state.cityLabel.trim();
    final hasCity = city.isNotEmpty && city != '—';

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
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========= Right side (Avatar + texts) =========
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
                    SizeConfig.hSpace(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // الاسم + شارة تحقق
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: Text(
                                  state.displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body16.copyWith(
                                    fontSize: SizeConfig.ts(16),
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    height: 1.12,
                                  ),
                                ),
                              ),
                              if (state.isFullyVerified) ...[
                                SizeConfig.hSpace(6),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.lightGreen,
                                  size: SizeConfig.ts(18),
                                ),
                              ],
                            ],
                          ),

                          SizeConfig.v(4),

                          // سطر الوصف (زي فيجما)
                          Text(
                            'مقدم خدمات محترف',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body14.copyWith(
                              fontSize: SizeConfig.ts(12.8),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizeConfig.v(6),

                          // عضو منذ + أيقونة
                          _MetaRow(
                            icon: Icons.emoji_events_outlined,
                            text: state.memberSinceLabel,
                          ),

                          // الموقع داخل الهيدر ✅ (إضافة QA)
                          if (hasCity) ...[
                            SizeConfig.v(6),
                            _MetaRow(
                              icon: Icons.location_on_rounded,
                              text: city,
                              iconColor: AppColors.lightGreen,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ========= Left side (Category chip) =========
              if (_showCategoryChip) ...[
                SizeConfig.hSpace(10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: SizeConfig.w(150)),
                  child: _CategoryChip(label: state.categoryLabel),
                ),
              ],
            ],
          ),

          SizeConfig.v(12),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.14)),
          SizeConfig.v(12),

          // ✅ Stats Row (نفس ترتيبك)
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: _Stat(
                  value: '${state.totalBookings}',
                  label: 'إجمالي الحجوزات',
                ),
              ),
              _VLine(),
              Expanded(
                child: _Stat(
                  value: state.ratingCount == 0 ? '—' : state.rating.toStringAsFixed(1),
                  label: 'التقييم',
                ),
              ),
              _VLine(),
              Expanded(
                child: _Stat(
                  value: '${state.completedBookings}',
                  label: 'مكتملة',
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

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const _MetaRow({
    required this.icon,
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = text.trim();
    if (t.isEmpty) return const SizedBox.shrink();

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          icon,
          size: SizeConfig.ts(16),
          color: iconColor ?? const Color(0xFFFFC107),
        ),
        SizeConfig.hSpace(6),
        Expanded(
          child: Text(
            t,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption11.copyWith(
              fontSize: SizeConfig.ts(12.3),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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

class _VLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: SizeConfig.h(44),
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(10)),
      color: Colors.grey.withValues(alpha: 0.18),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.body16.copyWith(
            fontSize: SizeConfig.ts(17),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(4),
        Text(
          label,
          maxLines: 2, // ✅ كان 1
          softWrap: true,
          overflow: TextOverflow.visible, // ✅ بدل ellipsis عشان يبين كامل
          textAlign: TextAlign.center, // ✅ أجمل مع سطرين
          style: AppTextStyles.caption11.copyWith(
            fontSize: SizeConfig.ts(11.4), // ✅ أصغر شوي عشان يركب دايمًا
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}
