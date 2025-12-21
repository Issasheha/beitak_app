import '../models/marketplace_filters.dart';
import '../models/marketplace_request_ui_model.dart';

class MarketplaceState {
  final bool isLoading;
  final String? errorMessage;

  /// ✅ رسائل خفيفة للـ UI (SnackBar) بدون ما نوقف الشاشة
  final String? uiMessage;

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
    required this.uiMessage,
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
        uiMessage: null,
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
    bool clearError = false,
    String? uiMessage,
    bool clearUiMessage = false,
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      uiMessage: clearUiMessage ? null : (uiMessage ?? this.uiMessage),
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
    Iterable<MarketplaceRequestUiModel> items = allRequests;

    // 🔎 search
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((r) {
        final hay = [
          r.customerName,
          r.title,
          r.description,
          r.cityName ?? '',
          r.areaName ?? '',
          r.categoryLabel ?? '',
        ].join(' ').toLowerCase();

        return hay.contains(q);
      });
    }

    // 🏙️ city (حتى لو السيرفر بفلترها، خليه احتياط)
    if (filters.cityId != null) {
      items = items.where((r) => r.cityId == filters.cityId);
    }

    // ✅ category (مهم: نفلتر بالـ ID مش بالـ label)
    if (filters.categoryId != null) {
      items = items.where((r) => r.categoryId == filters.categoryId);
    }

    // 💰 budget range (overlap)
    if (filters.minBudget != null || filters.maxBudget != null) {
      final fMin = filters.minBudget ?? double.negativeInfinity;
      final fMax = filters.maxBudget ?? double.infinity;

      items = items.where((r) {
        final min = r.budgetMin;
        final max = r.budgetMax ?? min;

        // لو المستخدم فعّل فلتر السعر والطلب ما فيه ميزانية نخفيه
        if (min == null && max == null) return false;

        final reqMin = min ?? 0.0;
        final reqMax = max ?? reqMin;

        // overlap range
        return reqMax >= fMin && reqMin <= fMax;
      });
    }

    final list = items.toList();

    // ترتيب محلي حسب createdAt (حتى لو السيرفر بيرجع مرتب)
    list.sort(
      (a, b) => filters.sort == MarketplaceSort.newest
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );

    return list;
  }
}
