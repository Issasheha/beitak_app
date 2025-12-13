import '../models/marketplace_filters.dart';
import '../models/marketplace_request_ui_model.dart';

class MarketplaceState {
  final bool isLoading;
  final String? errorMessage;

  final List<MarketplaceRequestUiModel> allRequests;
  final String searchQuery;
  final MarketplaceFilters filters;

  // pagination
  final int page;
  final int limit;
  final bool hasMore;

  final bool isLoadingMore;
  final bool loadMoreFailed;

  const MarketplaceState({
    required this.isLoading,
    required this.errorMessage,
    required this.allRequests,
    required this.searchQuery,
    required this.filters,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreFailed,
  });

  factory MarketplaceState.initial() => MarketplaceState(
        isLoading: false,
        errorMessage: null,
        allRequests: const [],
        searchQuery: '',
        filters: MarketplaceFilters.initial(),
        page: 1,
        limit: 10,
        hasMore: false,
        isLoadingMore: false,
        loadMoreFailed: false,
      );

  MarketplaceState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MarketplaceRequestUiModel>? allRequests,
    String? searchQuery,
    MarketplaceFilters? filters,
    int? page,
    int? limit,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return MarketplaceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      allRequests: allRequests ?? this.allRequests,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  List<String> get activeChips {
    final chips = <String>[];

    final city = filters.cityLabel;
    if (city != null && city.trim().isNotEmpty) chips.add(city);

    final cat = filters.categoryLabel;
    if (cat != null && cat.trim().isNotEmpty) chips.add(cat);

    if (filters.minBudget != null || filters.maxBudget != null) {
      final min = filters.minBudget?.toStringAsFixed(0) ?? '0';
      final max = filters.maxBudget?.toStringAsFixed(0) ?? '∞';
      chips.add('السعر: $min - $max');
    }

    chips.add(filters.sort.label);

    final q = searchQuery.trim();
    if (q.isNotEmpty) chips.add('بحث: $q');

    return chips;
  }

  List<MarketplaceRequestUiModel> get visibleRequests {
    final q = searchQuery.trim().toLowerCase();
    List<MarketplaceRequestUiModel> items = allRequests;

    if (q.isNotEmpty) {
      items = items.where((r) {
        return r.customerName.toLowerCase().contains(q) ||
            r.title.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q) ||
            (r.cityName?.toLowerCase().contains(q) ?? false) ||
            (r.areaName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (filters.cityId != null) {
      items = items.where((r) => r.cityId == filters.cityId).toList();
    }

    final cat = filters.categoryLabel;
    if (cat != null && cat.trim().isNotEmpty) {
      items = items.where((r) => r.categoryLabel == cat).toList();
    }

    if (filters.minBudget != null) {
      items = items.where((r) => (r.budgetMin ?? 0) >= filters.minBudget!).toList();
    }
    if (filters.maxBudget != null) {
      items = items.where((r) => (r.budgetMax ?? 0) <= filters.maxBudget!).toList();
    }

    items.sort((a, b) => filters.sort == MarketplaceSort.newest
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));

    return items;
  }
}
