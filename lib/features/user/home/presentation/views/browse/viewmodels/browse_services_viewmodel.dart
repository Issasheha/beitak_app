// lib/features/user/home/presentation/views/browse/viewmodels/browse_services_viewmodel.dart

import 'package:beitak_app/core/cache/locations_cache.dart';
import 'package:beitak_app/core/helpers/search_normalizer.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/providers/categories_id_map_provider.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/models/service_summary.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrowseServicesViewModel {
  BrowseServicesViewModel(this._ref);

  final Ref _ref;
  final Dio _dio = ApiClient.dio;

  final List<ServiceSummary> services = [];

  int _page = 1;
  final int _limit = 10;

  bool isLoadingMore = false;
  bool hasMore = true;

  Future<void> loadInitialServices({
    int? cityId,
    int? areaId, // حالياً مش مستخدم لأننا مش متأكدين اسم البراميتر عند السيرفر
    String? searchTerm,
    String? categoryKey,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    _page = 1;
    hasMore = true;
    services.clear();

    final result = await _fetchPage(
      page: _page,
      cityId: cityId,
      areaId: areaId,
      searchTerm: searchTerm,
      categoryKey: categoryKey,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      sortBy: sortBy,
    );

    services.addAll(result.items);
    hasMore = result.hasMore;
  }

  Future<void> loadMoreServices({
    int? cityId,
    int? areaId,
    String? searchTerm,
    String? categoryKey,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;

    try {
      final nextPage = _page + 1;

      final result = await _fetchPage(
        page: nextPage,
        cityId: cityId,
        areaId: areaId,
        searchTerm: searchTerm,
        categoryKey: categoryKey,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        sortBy: sortBy,
      );

      _page = nextPage;
      services.addAll(result.items);
      hasMore = result.hasMore;
    } finally {
      isLoadingMore = false;
    }
  }

  Future<int?> _categoryIdFromKey(String? key) async {
    final raw = key?.trim();
    if (raw == null || raw.isEmpty) return null;

    final map = await _ref.read(categoriesIdMapProvider.future);

    final k = raw.toLowerCase();

    // 1) exact
    final exact = map[k];
    if (exact != null) return exact;

    // 2) underscore fallback
    final underscore = k.replaceAll(RegExp(r'\s+'), '_');
    final byUnderscore = map[underscore];
    if (byUnderscore != null) return byUnderscore;

    // 3) space fallback (لو جاي underscore)
    final spaces = k.replaceAll('_', ' ');
    final bySpaces = map[spaces];
    if (bySpaces != null) return bySpaces;

    return null;
  }

  Future<String?> _cityNameFromId(int? cityId) async {
    if (cityId == null) return null;
    try {
      final cities = await LocationsCache.getCities();
      for (final c in cities) {
        if (c.id == cityId) return c.name; // مثال: "Amman"
      }
    } catch (_) {}
    return null;
  }

  Future<_PageResult> _fetchPage({
    required int page,
    int? cityId,
    int? areaId,
    String? searchTerm,
    String? categoryKey,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    final categoryId = await _categoryIdFromKey(categoryKey);

    // ✅ لو minPrice > maxPrice بدّلهم
    double? minP = minPrice;
    double? maxP = maxPrice;
    if (minP != null && maxP != null && minP > maxP) {
      final tmp = minP;
      minP = maxP;
      maxP = tmp;
    }

    final String? qRaw =
        (searchTerm ?? '').trim().isEmpty ? null : searchTerm!.trim();

    // ✅ التطبيع هون فقط (UI يظل عربي)
    final String? q =
        qRaw == null ? null : SearchNormalizer.normalizeForApi(qRaw);

    final double? rating = (minRating == null || minRating <= 0)
        ? null
        : (minRating > 5 ? 5 : minRating);

    // ✅ أهم نقطة: city لازم يكون اسم مدينة مش رقم
    final cityName = await _cityNameFromId(cityId);

    final qp = <String, dynamic>{
      'page': page,
      'limit': _limit,

      // ✅ send city as name (مثل "Amman")
      if (cityName != null && cityName.trim().isNotEmpty)
        'city': cityName.trim(),

      // (اختياري) إذا طلع لاحقاً إن السيرفر بده city_id، بنفع نرجعه،
      // بس حالياً واضح إنه يستخدم city فقط من filters_applied.

      if (q != null) 'query': q,
      if (categoryId != null) 'category': categoryId,

      if (minP != null) 'min_price': minP,
      if (maxP != null) 'max_price': maxP,

      if (rating != null) 'min_rating': rating,

      if (sortBy != null && sortBy.trim().isNotEmpty) 'sort_by': sortBy.trim(),
    };

    final res = await _dio.get(ApiConstants.search, queryParameters: qp);
    final raw = res.data;

    if (raw is! Map) throw Exception('Invalid search response');
    final map = raw.cast<String, dynamic>();

    if (map['success'] != true) {
      throw Exception((map['message'] ?? 'unknown_error').toString());
    }

    final data = map['data'];
    if (data is! Map) throw Exception('Invalid search data');
    final dataMap = data.cast<String, dynamic>();

    final itemsRaw = dataMap['results'];
    if (itemsRaw is! List) throw Exception('Invalid results list');

    final items = itemsRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(ServiceSummary.fromJson)
        .toList();

    bool hasMoreCalc = items.length == _limit;
    final pagination = dataMap['pagination'];
    if (pagination is Map) {
      final p = pagination.cast<String, dynamic>();
      final current = (p['current_page'] as num?)?.toInt() ?? page;
      final total = (p['total_pages'] as num?)?.toInt();
      if (total != null) hasMoreCalc = current < total;
    }

    return _PageResult(items: items, hasMore: hasMoreCalc);
  }
}

class _PageResult {
  final List<ServiceSummary> items;
  final bool hasMore;

  const _PageResult({required this.items, required this.hasMore});
}
