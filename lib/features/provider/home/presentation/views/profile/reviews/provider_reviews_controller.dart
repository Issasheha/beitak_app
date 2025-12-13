// lib/features/provider/home/presentation/views/reviews/provider_reviews_controller.dart

import 'dart:async';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_reviews_state.dart';

class ProviderReviewsController
    extends AsyncNotifier<ProviderReviewsState> {
  @override
  FutureOr<ProviderReviewsState> build() async {
    return _fetchPage(page: 1, mergeWithExisting: false);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final s = await _fetchPage(page: 1, mergeWithExisting: false);
      state = AsyncData(s);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasNext || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final s = await _fetchPage(
        page: current.currentPage + 1,
        mergeWithExisting: true,
      );
      state = AsyncData(s);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<ProviderReviewsState> _fetchPage({
    required int page,
    required bool mergeWithExisting,
  }) async {
    final current = state.asData?.value;

    final res = await ApiClient.dio.get(
      ApiConstants.providerMyReviews,
      queryParameters: {
        'page': page,
        'limit': 10,
      },
    );

    final root = res.data ?? {};
    final List rawList = (root['data'] as List?) ?? [];
    final pagination = root['pagination'] ?? {};

    List<ProviderReviewItem> newItems = rawList.map((raw) {
      String _s(dynamic v) => (v ?? '').toString();

      final customer = raw['customer'] ?? {};
      final service = raw['service'] ?? {};
      final booking = raw['booking'] ?? {};

      final firstName = _s(customer['first_name']);
      final lastName = _s(customer['last_name']);
      final customerName = (firstName.isEmpty && lastName.isEmpty)
          ? 'عميل'
          : '$firstName $lastName';

      final serviceName =
          _s(service['name_ar'].toString().isNotEmpty
              ? service['name_ar']
              : service['name']);

      // نستخدم booking_date للفورمات
      final dateStr = _s(booking['booking_date']).isNotEmpty
          ? _s(booking['booking_date'])
          : _s(raw['created_at']);
      final dateLabel = _arabicDate(dateStr);

      final rating = int.tryParse(_s(raw['rating'])) ?? 0;

      return ProviderReviewItem(
        id: raw['id'] as int,
        rating: rating.clamp(1, 5),
        review: _s(raw['review']),
        reviewAr: _s(raw['review_ar']).isEmpty ? null : _s(raw['review_ar']),
        customerName: customerName,
        serviceName:
            serviceName.isEmpty ? 'خدمة بدون اسم' : serviceName,
        dateLabel: dateLabel,
        isVerifiedPurchase: raw['is_verified_purchase'] == true,
      );
    }).toList();

    List<ProviderReviewItem> all;
    if (mergeWithExisting && current != null) {
      all = [...current.reviews, ...newItems];
    } else {
      all = newItems;
    }

    // حساب المعدل والتوزيع
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    double sum = 0;

    for (final r in all) {
      distribution[r.rating] = (distribution[r.rating] ?? 0) + 1;
      sum += r.rating.toDouble();
    }

    final avg = all.isEmpty ? 0.0 : sum / all.length;

    final totalReviews = pagination['total_reviews'] is int
        ? pagination['total_reviews'] as int
        : all.length;

    return ProviderReviewsState(
      reviews: all,
      totalReviews: totalReviews,
      currentPage:
          pagination['current_page'] is int ? pagination['current_page'] : page,
      hasNext: pagination['has_next'] == true,
      isLoadingMore: false,
      averageRating: avg,
      distribution: distribution,
    );
  }

  /// تحويل 2025-11-23 -> "23 نوفمبر 2025" (تقريبية بدون intl)
  static String _arabicDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final d = DateTime.parse(isoDate);
      const months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      final m = months[d.month - 1];
      return '${d.day} $m ${d.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
