import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/provider_ratings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'viewmodels/provider_ratings_providers.dart';

class ProviderRatingsView extends ConsumerWidget {
  const ProviderRatingsView({
    super.key,
    required this.providerId,
    this.providerName,
  });

  final int providerId;
  final String? providerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

   final state = ref.watch(providerRatingsControllerProvider(providerId));
final ctrl = ref.read(providerRatingsControllerProvider(providerId).notifier);


    final title = (providerName?.trim().isNotEmpty == true)
        ? providerName!.trim()
        : (state.providerName.trim().isNotEmpty
            ? state.providerName.trim()
            : 'تقييمات المزود');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            title,
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: state.loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.lightGreen),
              )
            : (state.error != null)
                ? _ErrorView(
                    message: state.error!,
                    onRetry: () => ctrl.refresh(),
                  )
                : SafeArea(
                    child: RefreshIndicator(
                      color: AppColors.lightGreen,
                      onRefresh: () => ctrl.refresh(),
                      child: ListView(
                        padding: SizeConfig.padding(horizontal: 16, vertical: 12),
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
                              (i) => Padding(
                                padding: EdgeInsets.only(bottom: SizeConfig.h(10)),
                                child: _ReviewCard(review: state.reviews[i]),
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
                                    onPressed: state.isLoadingMore ? null : () => ctrl.loadMore(),
                                    child: state.isLoadingMore
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
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
                  ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});
  final ProviderRatingsState state;

  @override
  Widget build(BuildContext context) {
    final avg = state.averageRating;
    final total = state.totalReviews;

    final maxCount = state.distribution.values.isEmpty
        ? 1
        : (state.distribution.values.reduce((a, b) => a > b ? a : b)).clamp(1, 999999);

    return Container(
      padding: SizeConfig.padding(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: const Color(0xFFFFE08A)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: SizeConfig.w(86),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avg <= 0 ? '—' : avg.toStringAsFixed(1),
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
          SizeConfig.hSpace(14),
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = state.distribution[star] ?? 0;
                final fraction = maxCount == 0 ? 0.0 : count / maxCount;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: SizeConfig.h(3)),
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
                          borderRadius: BorderRadius.circular(SizeConfig.radius(999)),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: SizeConfig.h(6),
                            backgroundColor: Colors.white.withValues(alpha: 0.7),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107)),
                          ),
                        ),
                      ),
                      SizeConfig.hSpace(6),
                      SizedBox(
                        width: SizeConfig.w(26),
                        child: Text(
                          '$count',
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ProviderRatingItem review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Row(
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
              _StarRow(rating: review.rating.toDouble(), size: SizeConfig.ts(14)),
            ],
          ),
          SizeConfig.v(8),
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
                const Icon(Icons.verified, size: 16, color: Color(0xFF4CAF50)),
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

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.size});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          IconData icon;
          if (i < full) {
            icon = Icons.star;
          } else if (i == full && hasHalf) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          return Icon(icon, size: size, color: const Color(0xFFFFC107));
        }),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightGreen),
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
