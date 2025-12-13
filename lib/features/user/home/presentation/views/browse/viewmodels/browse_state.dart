// lib/features/user/home/presentation/views/browse/viewmodels/browse_state.dart

import 'package:flutter/foundation.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/models/service_summary.dart';

@immutable
class BrowseArgs {
  final String? initialSearch;
  final int? initialCityId;
  final int? initialAreaId;

  const BrowseArgs({
    this.initialSearch,
    this.initialCityId,
    this.initialAreaId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowseArgs &&
          runtimeType == other.runtimeType &&
          initialSearch == other.initialSearch &&
          initialCityId == other.initialCityId &&
          initialAreaId == other.initialAreaId;

  @override
  int get hashCode => Object.hash(initialSearch, initialCityId, initialAreaId);
}

@immutable
class BrowseState {
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

  /// kept local (backend might not support it now)
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

    return BrowseState(
      initialized: false,
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      errorMessage: null,
      searchTerm: initialSearch,
      categoryKey: null,
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
    String? categoryKey,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int? userCityId,
    int? userAreaId,
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
      categoryKey: categoryKey ?? this.categoryKey,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      userCityId: userCityId ?? this.userCityId,
      userAreaId: userAreaId ?? this.userAreaId,
      sortBy: sortBy ?? this.sortBy,
      services: services ?? this.services,
      visible: visible ?? this.visible,
    );
  }
}
