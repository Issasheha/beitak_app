// lib/features/user/home/presentation/views/browse/viewmodels/browse_services_viewmodel.dart

import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/models/service_summary.dart';
import 'package:dio/dio.dart';

class BrowseServicesViewModel {
  final Dio _dio = ApiClient.dio;

  final List<ServiceSummary> services = [];

  int _page = 1;
  final int _limit = 20;

  bool isLoadingMore = false;
  bool hasMore = true;

  Future<void> loadInitialServices({
    String? searchTerm,
    String? categoryKey, // ✅ بدل categoryId
    double? minPrice,
    double? maxPrice,
    int? userCityId,
    int? userAreaId,
    String? sortBy,
  }) async {
    _page = 1;
    hasMore = true;
    services.clear();

    final result = await _fetchPage(
      page: _page,
      searchTerm: searchTerm,
      categoryKey: categoryKey,
      minPrice: minPrice,
      maxPrice: maxPrice,
      userCityId: userCityId,
      userAreaId: userAreaId,
      sortBy: sortBy,
    );

    services.addAll(result.items);
    hasMore = result.hasMore;
  }

  Future<void> loadMoreServices({
    String? searchTerm,
    String? categoryKey,
    double? minPrice,
    double? maxPrice,
    int? userCityId,
    int? userAreaId,
    String? sortBy,
  }) async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;

    try {
      final nextPage = _page + 1;
      final result = await _fetchPage(
        page: nextPage,
        searchTerm: searchTerm,
        categoryKey: categoryKey,
        minPrice: minPrice,
        maxPrice: maxPrice,
        userCityId: userCityId,
        userAreaId: userAreaId,
        sortBy: sortBy,
      );

      _page = nextPage;
      services.addAll(result.items);
      hasMore = result.hasMore;
    } finally {
      isLoadingMore = false;
    }
  }

  int? _extractProviderCityId(Map<String, dynamic> m) {
    final provider = m['provider'];
    if (provider is Map) {
      final p = provider.cast<String, dynamic>();

      // 1) provider.user.city_id
      final user = p['user'];
      if (user is Map) {
        final u = user.cast<String, dynamic>();
        final v = u['city_id'];
        if (v is num) return v.toInt();
      }

      // 2) fallback: provider.city_id
      final v2 = p['city_id'];
      if (v2 is num) return v2.toInt();
    }

    // 3) fallback عام
    final v3 = m['city_id'];
    if (v3 is num) return v3.toInt();

    return null;
  }

  Future<_PageResult> _fetchPage({
    required int page,
    String? searchTerm,
    String? categoryKey,
    double? minPrice,
    double? maxPrice,
    int? userCityId,
    int? userAreaId,
    String? sortBy,
  }) async {
    final qp = <String, dynamic>{
      'page': page,
      'limit': _limit,

      // search / q
      if (searchTerm != null && searchTerm.trim().isNotEmpty) ...{
        'search': searchTerm.trim(),
        'q': searchTerm.trim(),
      },

      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,

      // city/area (حاول أسماء محتملة)
      if (userCityId != null) ...{
        'city_id': userCityId,
        'user_city_id': userCityId,
        'provider_city_id': userCityId,
      },
      if (userAreaId != null) ...{
        'area_id': userAreaId,
        'user_area_id': userAreaId,
        'provider_area_id': userAreaId,
      },

      if (sortBy != null && sortBy.trim().isNotEmpty) 'sort_by': sortBy.trim(),
    };

    final res = await _dio.get(ApiConstants.services, queryParameters: qp);
    final raw = res.data;

    if (raw is! Map) throw Exception('Invalid services response');

    final map = raw.cast<String, dynamic>();
    if (map['success'] != true) {
      throw Exception((map['message'] ?? 'unknown_error').toString());
    }

    final data = map['data'];
    if (data is! Map) throw Exception('Invalid services data');

    final dataMap = data.cast<String, dynamic>();
    final itemsRaw = dataMap['services'] ?? dataMap['items'] ?? dataMap['data'];
    if (itemsRaw is! List) throw Exception('Invalid services list');

    final rawMaps = itemsRaw
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();

    // ✅ فلترة مدينة محلياً
    Iterable<Map<String, dynamic>> filtered = rawMaps;
    if (userCityId != null) {
      filtered = filtered.where((m) => _extractProviderCityId(m) == userCityId);
    }

    // ✅ فلترة فئة محلياً (أفضل حل مع category_id = null)
    if (categoryKey != null && categoryKey.trim().isNotEmpty) {
      final want = categoryKey.trim().toLowerCase();
      filtered = filtered.where((m) {
        final k = FixedServiceCategories.keyFromServiceJson(m);
        return (k ?? '').toLowerCase() == want;
      });
    }

    final items = filtered.map((m) => ServiceSummary.fromJson(m)).toList();

    // hasMore من pagination (أصح من length)
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
