import 'package:flutter/foundation.dart';

@immutable
class ProviderRatingItem {
  final int id;
  final int rating; // 1..5
  final String review;
  final String? reviewAr;
  final String customerName;
  final String serviceName;
  final String dateLabel;
  final bool isVerifiedPurchase;

  const ProviderRatingItem({
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
      (reviewAr != null && reviewAr!.trim().isNotEmpty) ? reviewAr! : review;
}

@immutable
class ProviderRatingsState {
  final bool loading;
  final String? error;

  final List<ProviderRatingItem> reviews;

  final String providerName;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution;

  final int currentPage;
  final bool hasNext;
  final bool isLoadingMore;

  const ProviderRatingsState({
    required this.loading,
    required this.error,
    required this.reviews,
    required this.providerName,
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
    required this.currentPage,
    required this.hasNext,
    required this.isLoadingMore,
  });

  factory ProviderRatingsState.initial() => const ProviderRatingsState(
        loading: true,
        error: null,
        reviews: [],
        providerName: '',
        averageRating: 0.0,
        totalReviews: 0,
        distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        currentPage: 1,
        hasNext: false,
        isLoadingMore: false,
      );

  ProviderRatingsState copyWith({
    bool? loading,
    String? error,
    List<ProviderRatingItem>? reviews,
    String? providerName,
    double? averageRating,
    int? totalReviews,
    Map<int, int>? distribution,
    int? currentPage,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return ProviderRatingsState(
      loading: loading ?? this.loading,
      error: error,
      reviews: reviews ?? this.reviews,
      providerName: providerName ?? this.providerName,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      distribution: distribution ?? this.distribution,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
