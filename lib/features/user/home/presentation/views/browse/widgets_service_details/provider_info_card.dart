import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderInfoCard extends StatelessWidget {
  const ProviderInfoCard({
    super.key,
    required this.providerName,
    required this.ratingAvg,
    required this.ratingCount,
    required this.bio,
    required this.memberSinceYear,
    required this.onTapReviews,
  });

  final String providerName;
  final double ratingAvg;
  final int ratingCount;
  final String bio;
  final String memberSinceYear; // "2021" أو "—"
  final VoidCallback onTapReviews;

  String _initials(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return '—';
    final parts = cleaned.split(' ').where((e) => e.isNotEmpty).toList();
    String firstChar(String s) => s.characters.isEmpty ? '' : s.characters.first;
    if (parts.length >= 2) {
      final out = (firstChar(parts[0]) + firstChar(parts[1])).toUpperCase();
      return out.isEmpty ? '—' : out;
    }
    final chars = parts.first.characters.toList();
    if (chars.isEmpty) return '—';
    if (chars.length == 1) return chars.first.toUpperCase();
    return (chars[0] + chars[1]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final initials = _initials(providerName);
    final displayBio = bio.trim().isEmpty ? 'لا توجد نبذة حالياً.' : bio.trim();

    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان القسم + خط جانبي أخضر مثل الصورة
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Expanded(
                child: Text(
                  'معلومات مقدم الخدمة',
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.ts(14.5),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.h(12)),

          // صف: أفاتار + اسم + عضو منذ + تقييم
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SizeConfig.h(46),
                height: SizeConfig.h(46),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGreen.withValues(alpha: 0.18),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: SizeConfig.ts(13),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.w(12)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName.trim().isEmpty ? 'مزود خدمة' : providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: SizeConfig.ts(14),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(4)),
                    Text(
                      memberSinceYear == '—' ? 'عضو منذ —' : 'عضو منذ $memberSinceYear',
                      style: AppTextStyles.body.copyWith(
                        fontSize: SizeConfig.ts(12),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // تقييم يمين
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ratingAvg <= 0 ? '—' : ratingAvg.toStringAsFixed(1),
                    style: AppTextStyles.semiBold.copyWith(
                      fontSize: SizeConfig.ts(13.5),
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(4)),
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  SizedBox(width: SizeConfig.w(6)),
                  Text(
                    '($ratingCount)',
                    style: AppTextStyles.body.copyWith(
                      fontSize: SizeConfig.ts(12),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(10)),

          Text(
            displayBio,
            style: AppTextStyles.body.copyWith(
              fontSize: SizeConfig.ts(12.8),
              color: AppColors.textPrimary,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: SizeConfig.h(12)),

          // زر تقييمات المزود (مثل الصورة: أصفر خفيف)
          OutlinedButton.icon(
            onPressed: onTapReviews,
            icon: const Icon(Icons.star_rounded, color: Colors.amber),
            label: Text(
              'تقييمات المزود',
              style: AppTextStyles.semiBold.copyWith(
                fontSize: SizeConfig.ts(13),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFFFF9E6),
              side: const BorderSide(color: Color(0xFFFFE08A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
