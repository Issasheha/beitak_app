import 'package:beitak_app/core/constants/fixed_service_categories.dart';

enum MarketplaceSort {
  newest,
  oldest;

  String get label {
    switch (this) {
      case MarketplaceSort.newest:
        return 'الأحدث أولاً';
      case MarketplaceSort.oldest:
        return 'الأقدم أولاً';
    }
  }

  String get apiValue {
    switch (this) {
      case MarketplaceSort.newest:
        return 'newest';
      case MarketplaceSort.oldest:
        return 'oldest';
    }
  }
}

class MarketplaceFilters {
  final String? categoryLabel; // للـ UI (عربي)
  final int? categoryId; // ✅ للـ API

  final double? minBudget;
  final double? maxBudget;

  final MarketplaceSort sort;

  /// المدينة
  final int? cityId;

  const MarketplaceFilters({
    required this.categoryLabel,
    required this.categoryId,
    required this.minBudget,
    required this.maxBudget,
    required this.sort,
    required this.cityId,
  });

  factory MarketplaceFilters.initial() => const MarketplaceFilters(
        categoryLabel: null,
        categoryId: null,
        minBudget: null,
        maxBudget: null,
        sort: MarketplaceSort.newest,
        cityId: null,
      );

  MarketplaceFilters copyWith({
    String? categoryLabel,
    int? categoryId,
    double? minBudget,
    double? maxBudget,
    MarketplaceSort? sort,
    int? cityId,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearBudget = false,
  }) {
    return MarketplaceFilters(
      categoryLabel: clearCategory ? null : (categoryLabel ?? this.categoryLabel),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      minBudget: clearBudget ? null : (minBudget ?? this.minBudget),
      maxBudget: clearBudget ? null : (maxBudget ?? this.maxBudget),
      sort: sort ?? this.sort,
      cityId: clearCity ? null : (cityId ?? this.cityId),
    );
  }

  /// (اختياري) لو احتجته للديباغ أو للعرض
  String? get categoryKey {
    final s = (categoryLabel ?? '').trim();
    if (s.isEmpty) return null;
    return FixedServiceCategories.keyFromAnyString(s);
  }

  String? get cityLabel {
    if (cityId == 1) return 'عمّان';
    if (cityId == 4) return 'العقبة';
    return null;
  }
}
