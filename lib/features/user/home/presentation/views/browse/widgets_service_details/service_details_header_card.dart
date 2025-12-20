import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class ServiceDetailsHeaderCard extends StatelessWidget {
  const ServiceDetailsHeaderCard({
    super.key,
    required this.serviceName,
    required this.categoryLabel,
    required this.durationLabel,
    required this.rating,
    required this.priceValueLabel,
    required this.priceHintLabel,
    required this.bookingLoading,
    required this.onBookNow,
  });

  final String serviceName;
  final String categoryLabel;
  final String durationLabel;
  final double rating;

  final String priceValueLabel; // مثال: 30 JD
  final String priceHintLabel; // مثال: حسب حجم المنزل

  final bool bookingLoading;
  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            color: Color(0x1A000000),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  serviceName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.ts(20),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                  const SizedBox(width: 4),
                  Text(
                    rating <= 0 ? '—' : rating.toStringAsFixed(1),
                    style: AppTextStyles.semiBold.copyWith(
                      fontSize: SizeConfig.ts(16),
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            categoryLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              fontSize: SizeConfig.ts(14),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          // ✅ Price box (مثل الصورة)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FBF6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0F0E2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'نطاق السعر',
                    style: AppTextStyles.body.copyWith(
                      fontSize: SizeConfig.ts(14),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  priceValueLabel,
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.ts(26),
                    fontWeight: FontWeight.w900,
                    color: AppColors.lightGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ✅ Center button (مثل الصورة)
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: SizeConfig.w(190),
              height: SizeConfig.h(44),
              child: ElevatedButton(
                onPressed: bookingLoading ? null : onBookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                  disabledBackgroundColor:
                      AppColors.lightGreen.withValues(alpha: 0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  bookingLoading ? 'جارٍ الحجز...' : 'احجز الآن',
                  style: AppTextStyles.semiBold.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: SizeConfig.ts(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
