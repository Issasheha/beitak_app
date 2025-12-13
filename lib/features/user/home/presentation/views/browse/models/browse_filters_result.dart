// lib/features/user/home/presentation/views/browse/models/browse_filters_result.dart

class BrowseFiltersResult {
  /// بدل categoryId صار categoryKey (cleaning / plumbing / ...)
  final String? categoryKey;

  final double? minPrice;
  final double? maxPrice;
  final double minRating;

  const BrowseFiltersResult({
    required this.categoryKey,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
  });
}
