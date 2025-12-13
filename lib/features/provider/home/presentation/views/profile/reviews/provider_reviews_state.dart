// lib/features/provider/home/presentation/views/reviews/provider_reviews_state.dart

import 'package:flutter/foundation.dart';

@immutable
class ProviderReviewItem {
  final int id;
  final int rating; // 1..5
  final String review;
  final String? reviewAr;
  final String customerName;
  final String serviceName;
  final String dateLabel; // مثال: 15 نوفمبر 2025
  final bool isVerifiedPurchase;

  const ProviderReviewItem({
    required this.id,
    required this.rating,
    required this.review,
    required this.reviewAr,
    required this.customerName,
    required this.serviceName,
    required this.dateLabel,
    required this.isVerifiedPurchase,
  });

  String get displayReview =>
      (reviewAr != null && reviewAr!.trim().isNotEmpty)
          ? reviewAr!
          : review;
}

@immutable
class ProviderReviewsState {
  final List<ProviderReviewItem> reviews;

  final int totalReviews;
  final int currentPage;
  final bool hasNext;
  final bool isLoadingMore;

  final double averageRating;
  final Map<int, int> distribution; // key: النجوم 1..5

  const ProviderReviewsState({
    required this.reviews,
    required this.totalReviews,
    required this.currentPage,
    required this.hasNext,
    required this.isLoadingMore,
    required this.averageRating,
    required this.distribution,
  });

  factory ProviderReviewsState.initial() => const ProviderReviewsState(
        reviews: [],
        totalReviews: 0,
        currentPage: 1,
        hasNext: false,
        isLoadingMore: false,
        averageRating: 0,
        distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );

  ProviderReviewsState copyWith({
    List<ProviderReviewItem>? reviews,
    int? totalReviews,
    int? currentPage,
    bool? hasNext,
    bool? isLoadingMore,
    double? averageRating,
    Map<int, int>? distribution,
  }) {
    return ProviderReviewsState(
      reviews: reviews ?? this.reviews,
      totalReviews: totalReviews ?? this.totalReviews,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      averageRating: averageRating ?? this.averageRating,
      distribution: distribution ?? this.distribution,
    );
  }
}
