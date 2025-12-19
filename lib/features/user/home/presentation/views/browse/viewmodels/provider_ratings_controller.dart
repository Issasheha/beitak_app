// lib/features/user/home/presentation/views/browse/viewmodels/provider_ratings_controller.dart
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'provider_ratings_state.dart';

class ProviderRatingsController extends StateNotifier<ProviderRatingsState> {
  ProviderRatingsController({required this.providerId})
      : super(ProviderRatingsState.initial()) {
    // ✅ دايمًا يحمّل أول صفحة
    loadInitial();
  }

  final int providerId;

  Future<void> loadInitial() async {
    state = state.copyWith(loading: true, error: null, isLoadingMore: false);

    try {
      final next = await _fetchPage(page: 1, mergeWithExisting: false);
      if (!mounted) return; // ✅ مهم
      state = next.copyWith(loading: false, error: null);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadInitial();

  Future<void> loadMore() async {
    if (state.loading || state.isLoadingMore || !state.hasNext) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final next = await _fetchPage(
        page: state.currentPage + 1,
        mergeWithExisting: true,
      );
      if (!mounted) return;
      state = next.copyWith(isLoadingMore: false, error: null);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<ProviderRatingsState> _fetchPage({
    required int page,
    required bool mergeWithExisting,
  }) async {
    final res = await ApiClient.dio.get(
      ApiConstants.providerRatings(providerId),
      queryParameters: {'page': page, 'limit': 10},
    );

    final root = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    if (root['success'] != true) {
      throw Exception((root['message'] ?? 'unknown_error').toString());
    }

    final rawList = (root['data'] as List?) ?? const [];
    final pagination = (root['pagination'] as Map?)?.cast<String, dynamic>() ?? {};
    final meta = (root['meta'] as Map?)?.cast<String, dynamic>() ?? {};
    final metaProvider = (meta['provider'] as Map?)?.cast<String, dynamic>() ?? {};
    final summary = (meta['rating_summary'] as Map?)?.cast<String, dynamic>() ?? {};

    final providerName = _s(metaProvider['business_name']);
    final averageRating = _d(summary['average_rating']);
    final totalReviews = _i(pagination['total_reviews'] ?? summary['total_reviews'] ?? 0);

    final distRaw =
        (summary['rating_distribution'] as Map?)?.cast<String, dynamic>() ?? {};
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final entry in distRaw.entries) {
      final k = int.tryParse(entry.key) ?? 0;
      if (k >= 1 && k <= 5) distribution[k] = _i(entry.value);
    }

    final newItems = rawList
        .whereType<Map>()
        .map((raw) => ProviderRatingItem(
              id: _i(raw['id']),
              rating: (_i(raw['rating'])).clamp(1, 5),
              review: _s(raw['review']),
              reviewAr: _s(raw['review_ar']).trim().isEmpty ? null : _s(raw['review_ar']),
              isVerifiedPurchase: raw['is_verified_purchase'] == true,
              customerName: _customerName(raw['customer']),
              serviceName: _serviceName(raw['service']),
              dateLabel: _arabicDate(_s(raw['created_at'])),
            ))
        .toList();

    final merged = mergeWithExisting ? [...state.reviews, ...newItems] : newItems;

    return state.copyWith(
      loading: false,
      error: null,
      reviews: merged,
      providerName: providerName,
      averageRating: averageRating,
      totalReviews: totalReviews,
      distribution: distribution,
      currentPage: _i(pagination['current_page'] ?? page),
      hasNext: pagination['has_next'] == true,
      isLoadingMore: false,
    );
  }

  static String _customerName(dynamic customerRaw) {
    final c = (customerRaw as Map?)?.cast<String, dynamic>() ?? {};
    final first = _s(c['first_name']).trim();
    final last = _s(c['last_name']).trim();
    final full = ('$first $last').trim();
    return full.isEmpty ? 'عميل' : full;
  }

  static String _serviceName(dynamic serviceRaw) {
    final sMap = (serviceRaw as Map?)?.cast<String, dynamic>() ?? {};
    final ar = _s(sMap['name_ar']).trim();
    if (ar.isNotEmpty) return ar;
    final en = _s(sMap['name']).trim();
    return en.isEmpty ? 'خدمة بدون اسم' : en;
  }

  static String _arabicDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      const months = [
        'يناير','فبراير','مارس','أبريل','مايو','يونيو',
        'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  static int _i(dynamic v) => int.tryParse((v ?? '').toString()) ?? 0;
  static double _d(dynamic v) => double.tryParse((v ?? '').toString()) ?? 0.0;
  static String _s(dynamic v) => (v ?? '').toString();
}
