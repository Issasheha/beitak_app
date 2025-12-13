// lib/features/user/home/presentation/views/browse/viewmodels/browse_controller.dart

import 'dart:async';


import 'package:beitak_app/features/user/home/presentation/views/browse/models/service_summary.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_services_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

class BrowseController extends StateNotifier<BrowseState> {
  final BrowseServicesViewModel _viewModel;

  int _requestId = 0;

  BrowseController({
    required BrowseServicesViewModel viewModel,
    required BrowseArgs args,
  })  : _viewModel = viewModel,
        super(BrowseState.initial(args));

  /// Call once from the view
  Future<void> bootstrap() async {
    if (state.initialized) return;
    state = state.copyWith(initialized: true);
    await loadInitial();
  }

  List<ServiceSummary> _applyLocalFilters(List<ServiceSummary> list) {
    final minRating = state.minRating;
    if (minRating <= 0) return list;
    return list.where((s) => s.rating >= minRating).toList();
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      // Dio v5
      final msg = e.message?.trim();
      if (msg != null && msg.isNotEmpty) return msg;
      return 'تعذر الاتصال بالشبكة. حاول مرة أخرى.';
    }
    if (e is Exception) {
      return 'حدث خطأ أثناء تحميل الخدمات. حاول مرة أخرى.';
    }
    return 'حدث خطأ غير متوقع.';
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
        searchTerm: q.isEmpty ? null : q,
        categoryKey: state.categoryKey,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        userCityId: state.userCityId,
        userAreaId: state.userAreaId,
        sortBy: state.sortBy,
      );

      // Ignore stale responses
      if (rid != _requestId) return;

      final all = List<ServiceSummary>.unmodifiable(_viewModel.services);
      final visible = List<ServiceSummary>.unmodifiable(_applyLocalFilters(all));

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasMore: _viewModel.hasMore,
        services: all,
        visible: visible,
      );
    } catch (e) {
      if (rid != _requestId) return;

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: _friendlyError(e),
        services: const [],
        visible: const [],
        hasMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final q = state.searchTerm.trim();

      await _viewModel.loadMoreServices(
        searchTerm: q.isEmpty ? null : q,
        categoryKey: state.categoryKey,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        userCityId: state.userCityId,
        userAreaId: state.userAreaId,
        sortBy: state.sortBy,
      );

      final all = List<ServiceSummary>.unmodifiable(_viewModel.services);
      final visible = List<ServiceSummary>.unmodifiable(_applyLocalFilters(all));

      state = state.copyWith(
        isLoadingMore: false,
        hasMore: _viewModel.hasMore,
        services: all,
        visible: visible,
      );
    } catch (_) {
      // لا نوقف الشاشة بسبب loadMore
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() => loadInitial();

  void submitSearch(String value) {
    final v = value.trim();
    state = state.copyWith(searchTerm: v);
    // نفس سلوكك السابق: البحث على Submit فقط
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
    state = state.copyWith(
      categoryKey: categoryKey,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
    );
    unawaited(loadInitial());
  }
}
