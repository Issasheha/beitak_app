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
  final String? categoryLabel;

  final double? minBudget;
  final double? maxBudget;

  final MarketplaceSort sort;

  /// المدينة (حسب طلب المانجر)
  final int? cityId;

  const MarketplaceFilters({
    required this.categoryLabel,
    required this.minBudget,
    required this.maxBudget,
    required this.sort,
    required this.cityId,
  });

  factory MarketplaceFilters.initial() => const MarketplaceFilters(
        categoryLabel: null,
        minBudget: null,
        maxBudget: null,
        sort: MarketplaceSort.newest,
        cityId: null,
      );

  MarketplaceFilters copyWith({
    String? categoryLabel,
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
      minBudget: clearBudget ? null : (minBudget ?? this.minBudget),
      maxBudget: clearBudget ? null : (maxBudget ?? this.maxBudget),
      sort: sort ?? this.sort,
      cityId: clearCity ? null : (cityId ?? this.cityId),
    );
  }

  /// ✅ لازم تكون getter (مش method بدون parameters)
  String? get cityLabel {
    if (cityId == 1) return 'عمّان';
    if (cityId == 4) return 'العقبة';
    return null;
  }
}
