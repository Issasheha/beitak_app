// lib/features/provider/home/presentation/views/reviews/provider_reviews_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/reviews/provider_reviews_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/reviews/provider_reviews_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProviderReviewsView extends ConsumerWidget {
  const ProviderReviewsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final asyncState = ref.watch(providerReviewsControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'التقييمات والمراجعات',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorView(
            message: err.toString(),
            onRetry: () => ref
                .read(providerReviewsControllerProvider.notifier)
                .refresh(),
          ),
          data: (state) {
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(providerReviewsControllerProvider.notifier)
                    .refresh(),
                child: ListView(
                  padding: SizeConfig.padding(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    _SummaryCard(state: state),
                    SizeConfig.v(16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'آراء العملاء',
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(14.5),
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizeConfig.v(10),
                    if (state.reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'لا توجد تقييمات حتى الآن',
                            style: AppTextStyles.body14.copyWith(
                              fontSize: SizeConfig.ts(13),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      ...List.generate(
                        state.reviews.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: SizeConfig.h(10),
                          ),
                          child: _ReviewCard(
                            review: state.reviews[index],
                          ),
                        ),
                      ),
                      if (state.hasNext)
                        Padding(
                          padding: EdgeInsets.only(
                            top: SizeConfig.h(4),
                            bottom: SizeConfig.h(8),
                          ),
                          child: Center(
                            child: TextButton(
                              onPressed: state.isLoadingMore
                                  ? null
                                  : () => ref
                                      .read(providerReviewsControllerProvider
                                          .notifier)
                                      .loadMore(),
                              child: state.isLoadingMore
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'تحميل المزيد',
                                      style: AppTextStyles.body14.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===================== Summary Card =====================

class _SummaryCard extends StatelessWidget {
  final ProviderReviewsState state;

  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final avg = state.averageRating;
    final total = state.totalReviews;

    final maxCount = state.distribution.values.isEmpty
        ? 1
        : (state.distribution.values
                .reduce((a, b) => a > b ? a : b))
            .clamp(1, 9999);

    return Container(
      padding: SizeConfig.padding(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: const Color(0xFFFFE08A),
        ),
      ),
      child: Row(
        children: [
          // اليسار: الرقم الكبير
          SizedBox(
            width: SizeConfig.w(80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: AppTextStyles.display28.copyWith(
                    fontSize: SizeConfig.ts(28),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFA000),
                  ),
                ),
                SizeConfig.v(4),
                _StarRow(rating: avg, size: SizeConfig.ts(16)),
                SizeConfig.v(4),
                Text(
                  '$total تقييم',
                  style: AppTextStyles.label12.copyWith(
                    fontSize: SizeConfig.ts(12),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizeConfig.hSpace(16),
          // اليمين: البارات
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index; // 5 -> 1
                final count = state.distribution[star] ?? 0;
                final fraction = maxCount == 0 ? 0.0 : count / maxCount;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.h(3),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: SizeConfig.w(18),
                        child: Text(
                          '$star',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption11.copyWith(
                            fontSize: SizeConfig.ts(11.5),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizeConfig.hSpace(4),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            SizeConfig.radius(999),
                          ),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: SizeConfig.h(6),
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.7),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFFFC107),
                            ),
                          ),
                        ),
                      ),
                      SizeConfig.hSpace(6),
                      SizedBox(
                        width: SizeConfig.w(26),
                        child: Text(
                          count.toString(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption11.copyWith(
                            fontSize: SizeConfig.ts(11.5),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== Review Card =====================

class _ReviewCard extends StatelessWidget {
  final ProviderReviewItem review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // السطر الأول: التاريخ
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              review.dateLabel,
              style: AppTextStyles.caption11.copyWith(
                fontSize: SizeConfig.ts(11.5),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizeConfig.v(4),

          // اسم العميل + اسم الخدمة + النجوم
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(13),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizeConfig.v(2),
                    Text(
                      review.serviceName,
                      style: AppTextStyles.caption11.copyWith(
                        fontSize: SizeConfig.ts(11.5),
                        color: AppColors.lightGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StarRow(
                rating: review.rating.toDouble(),
                size: SizeConfig.ts(14),
              ),
            ],
          ),
          SizeConfig.v(8),

          // نص التقييم
          Text(
            review.displayReview,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.5),
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),

          if (review.isVerifiedPurchase) ...[
            SizeConfig.v(6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified,
                  size: 16,
                  color: Color(0xFF4CAF50),
                ),
                SizeConfig.hSpace(4),
                Text(
                  'حجز موثّق',
                  style: AppTextStyles.caption11.copyWith(
                    fontSize: SizeConfig.ts(11),
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ===================== Widgets مساعدة =====================

class _StarRow extends StatelessWidget {
  final double rating; // 0..5
  final double size;

  const _StarRow({
    required this.rating,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    final stars = List.generate(5, (index) {
      IconData icon;
      if (index < fullStars) {
        icon = Icons.star;
      } else if (index == fullStars && hasHalf) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }

      return Icon(
        icon,
        size: size,
        color: const Color(0xFFFFC107),
      );
    });

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: stars,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizeConfig.v(12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.body14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
