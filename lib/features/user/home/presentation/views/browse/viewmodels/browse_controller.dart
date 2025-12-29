// lib/features/user/home/presentation/views/browse/viewmodels/browse_controller.dart

import 'dart:async';

import 'package:beitak_app/core/error/error_text.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/models/service_summary.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_services_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class BrowseController extends StateNotifier<BrowseState> {
  final BrowseServicesViewModel _viewModel;

  int _requestId = 0;

  BrowseController({
    required BrowseServicesViewModel viewModel,
    required BrowseArgs args,
  })  : _viewModel = viewModel,
        super(BrowseState.initial(args));

  Future<void> bootstrap() async {
    if (state.initialized) return;
    state = state.copyWith(initialized: true);
    await loadInitial();
  }

  String _norm(String s) {
    var x = s.trim().toLowerCase();
    x = x.replaceAll(RegExp(r'[\+_\-]+'), ' ');
    x = x.replaceAll(RegExp(r'\s+'), ' ').trim();
    return x;
  }

  bool _looksLikeCategoryQuery(String q) {
    final x = _norm(q);
    if (x.isEmpty) return false;

    const exact = <String>{
      'house cleaning',
      'cleaning',
      'plumbing',
      'plumber',
      'electrical',
      'electricity',
      'electric',
      'electrician',
      'maintenance',
      'repair',
      'design',
      'painting',
      'تنظيف المنازل',
      'تنظيف',
      'سباكة',
      'كهرباء',
      'كهربائي',
      'صيانة',
      'صيانه',
      'اصلاح',
      'إصلاح',
      'رسم',
      'دهان',
      'دهانات',
    };

    if (exact.contains(x)) return true;

    const containsAny = <String>[
      'clean',
      'plumb',
      'electr',
      'mainten',
      'repair',
      'paint',
      'design',
      'تنظيف',
      'سباك',
      'سباكة',
      'كهرب',
      'صيانة',
      'صيانه',
      'اصلاح',
      'رسم',
      'دهان',
    ];

    return containsAny.any((k) => x.contains(k));
  }

  Future<void> loadInitial() async {
    final rid = ++_requestId;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      clearError: true,
    );

    try {
      final q = state.searchTerm.trim();

      await _viewModel.loadInitialServices(
        // ✅ أهم تعديل: مرر المدينة/المنطقة
        cityId: state.userCityId,
        areaId: state.userAreaId,

        searchTerm: q.isEmpty ? null : q,
        categoryKey: state.categoryKey,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        minRating: state.minRating,
        sortBy: state.sortBy,
      );

      if (rid != _requestId) return;

      final all = List<ServiceSummary>.unmodifiable(_viewModel.services);

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasMore: _viewModel.hasMore,
        services: all,
        visible: all,
      );
    } catch (e) {
      if (rid != _requestId) return;

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: errorText(e),
        services: const [],
        visible: const [],
        hasMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final rid = _requestId;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final q = state.searchTerm.trim();

      await _viewModel.loadMoreServices(
        cityId: state.userCityId,
        areaId: state.userAreaId,

        searchTerm: q.isEmpty ? null : q,
        categoryKey: state.categoryKey,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        minRating: state.minRating,
        sortBy: state.sortBy,
      );

      if (rid != _requestId) return;

      final all = List<ServiceSummary>.unmodifiable(_viewModel.services);
      state = state.copyWith(
        isLoadingMore: false,
        hasMore: _viewModel.hasMore,
        services: all,
        visible: all,
      );
    } catch (e) {
      if (rid != _requestId) return;
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: errorText(e),
      );
    }
  }

  Future<void> refresh() => loadInitial();

  void submitSearch(String value) {
    final v = value.trim();
    state = state.copyWith(searchTerm: v);
    unawaited(loadInitial());
  }

  void clearSearch() {
    state = state.copyWith(searchTerm: '');
    unawaited(loadInitial());
  }

  void applyFilters({
    required String? categoryKey,
    required double? minPrice,
    required double? maxPrice,
    required double minRating,
  }) {
    final prevKey = state.categoryKey;
    final newKey = (categoryKey == null || categoryKey.trim().isEmpty)
        ? null
        : categoryKey.trim();

    final shouldClearQuery = _looksLikeCategoryQuery(state.searchTerm) &&
        ((prevKey != newKey) || newKey == null);

    state = state.copyWith(
      categoryKey: newKey,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      searchTerm: shouldClearQuery ? '' : state.searchTerm,
    );

    unawaited(loadInitial());
  }
}
