import 'package:flutter/foundation.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/models/service_summary.dart';

@immutable
class BrowseArgs {
  final String? initialSearch;
  final int? initialCityId;
  final int? initialAreaId;

  // ✅ جديد
  final String? initialCategoryKey;

  const BrowseArgs({
    this.initialSearch,
    this.initialCityId,
    this.initialAreaId,
    this.initialCategoryKey,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowseArgs &&
          runtimeType == other.runtimeType &&
          initialSearch == other.initialSearch &&
          initialCityId == other.initialCityId &&
          initialAreaId == other.initialAreaId &&
          initialCategoryKey == other.initialCategoryKey;

  @override
  int get hashCode =>
      Object.hash(initialSearch, initialCityId, initialAreaId, initialCategoryKey);
}

/// ✅ sentinel لازم يكون const عشان ينفع default parameter
class _Unset {
  const _Unset();
}

@immutable
class BrowseState {
  static const _Unset _unset = _Unset();

  final bool initialized;

  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;

  final String? errorMessage;

  /// Filters / query
  final String searchTerm;
  final String? categoryKey;
  final double? minPrice;
  final double? maxPrice;

  /// backend-supported now
  final double minRating;

  /// location context (fixed from args)
  final int? userCityId;
  final int? userAreaId;

  /// sort
  final String sortBy;

  /// Data
  final List<ServiceSummary> services;
  final List<ServiceSummary> visible;

  const BrowseState({
    required this.initialized,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.searchTerm,
    required this.categoryKey,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.userCityId,
    required this.userAreaId,
    required this.sortBy,
    required this.services,
    required this.visible,
  });

  factory BrowseState.initial(BrowseArgs args) {
    final initialSearch = (args.initialSearch ?? '').trim();
    final initialCategoryKey = (args.initialCategoryKey ?? '').trim();

    return BrowseState(
      initialized: false,
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      errorMessage: null,
      searchTerm: initialSearch,

      // ✅ مهم
      categoryKey: initialCategoryKey.isEmpty ? null : initialCategoryKey,

      minPrice: null,
      maxPrice: null,
      minRating: 0.0,
      userCityId: args.initialCityId,
      userAreaId: args.initialAreaId,
      sortBy: 'rating',
      services: const [],
      visible: const [],
    );
  }

  BrowseState copyWith({
    bool? initialized,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,

    String? searchTerm,

    /// ✅ Object? حتى نقدر نمرر null (الكل)
    Object? categoryKey = _unset,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,

    double? minRating,

    Object? userCityId = _unset,
    Object? userAreaId = _unset,

    String? sortBy,
    List<ServiceSummary>? services,
    List<ServiceSummary>? visible,
  }) {
    return BrowseState(
      initialized: initialized ?? this.initialized,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),

      searchTerm: searchTerm ?? this.searchTerm,

      categoryKey: identical(categoryKey, _unset)
          ? this.categoryKey
          : categoryKey as String?,

      minPrice: identical(minPrice, _unset) ? this.minPrice : minPrice as double?,
      maxPrice: identical(maxPrice, _unset) ? this.maxPrice : maxPrice as double?,

      minRating: minRating ?? this.minRating,

      userCityId:
          identical(userCityId, _unset) ? this.userCityId : userCityId as int?,
      userAreaId:
          identical(userAreaId, _unset) ? this.userAreaId : userAreaId as int?,

      sortBy: sortBy ?? this.sortBy,
      services: services ?? this.services,
      visible: visible ?? this.visible,
    );
  }
}
