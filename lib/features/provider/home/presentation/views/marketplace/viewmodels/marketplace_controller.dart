import 'package:beitak_app/features/provider/home/domain/repositories/marketplace_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/marketplace_filters.dart';
import '../models/marketplace_request_ui_model.dart';
import 'marketplace_state.dart';

class MarketplaceController extends StateNotifier<MarketplaceState> {
  final MarketplaceRepository repo;

  MarketplaceController({required this.repo}) : super(MarketplaceState.initial());

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      page: 1,
      hasMore: false,
      isLoadingMore: false,
      loadMoreFailed: false,
      allRequests: refresh ? const [] : state.allRequests,
    );

    try {
      final result = await repo.getMarketplaceRequests(
        page: 1,
        limit: state.limit,
        filters: state.filters,
      );

      final ui = result.items.map(MarketplaceRequestUiModel.fromEntity).toList();

      final hasMore = result.page < result.totalPages;

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        allRequests: ui,
        page: result.page,
        limit: result.limit,
        hasMore: hasMore,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'صار خطأ أثناء تحميل الطلبات',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, loadMoreFailed: false);

    try {
      final nextPage = state.page + 1;

      final result = await repo.getMarketplaceRequests(
        page: nextPage,
        limit: state.limit,
        filters: state.filters,
      );

      final newUi = result.items.map(MarketplaceRequestUiModel.fromEntity).toList();
      final merged = [...state.allRequests, ...newUi];

      final hasMore = result.page < result.totalPages;

      state = state.copyWith(
        isLoadingMore: false,
        loadMoreFailed: false,
        allRequests: merged,
        page: result.page,
        limit: result.limit,
        hasMore: hasMore,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        loadMoreFailed: true,
      );
    }
  }

  void setSearchQuery(String v) {
    state = state.copyWith(searchQuery: v);
  }

  Future<void> applyFilters(MarketplaceFilters filters) async {
    final old = state.filters;
    state = state.copyWith(filters: filters);

    // ✅ إذا تغيّر sort أو cityId نعيد تحميل من السيرفر (لأنه مرتبط بالباك + pagination)
    final serverRelevantChanged =
        old.sort != filters.sort || old.cityId != filters.cityId;

    if (serverRelevantChanged) {
      await load(refresh: true);
    }
  }

  Future<void> resetFilters() async {
    state = state.copyWith(filters: MarketplaceFilters.initial());
    await load(refresh: true);
  }

  void dismiss(int requestId) {
    state = state.copyWith(
      allRequests: state.allRequests.where((r) => r.id != requestId).toList(),
    );
  }

  Future<void> accept(int requestId) async {
    try {
      await repo.acceptRequest(requestId);
      dismiss(requestId);
    } catch (_) {
      state = state.copyWith(errorMessage: 'فشل قبول الطلب، حاول مرة أخرى');
    }
  }
}
