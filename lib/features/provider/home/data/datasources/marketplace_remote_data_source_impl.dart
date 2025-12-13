import 'package:beitak_app/features/provider/home/domain/entities/marketplace_page_entity.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/marketplace_request_entity.dart';
import '../../presentation/views/marketplace/models/marketplace_filters.dart';
import 'marketplace_remote_data_source.dart';

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final Dio dio;

  MarketplaceRemoteDataSourceImpl({required this.dio});

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String _safeStr(dynamic v) => (v ?? '').toString().trim();

  String _formatDate(String raw) {
    // raw: 2025-12-09
    if (raw.trim().isEmpty) return '—';
    final parts = raw.split('-');
    if (parts.length != 3) return raw;
    final y = parts[0];
    final m = parts[1];
    final d = parts[2];
    return '$d/$m/$y';
  }

  @override
  Future<MarketplacePagedResult> getMarketplaceRequests({
    required int page,
    required int limit,
    required MarketplaceFilters filters,
  }) async {
    final qp = <String, dynamic>{
      'page': page,
      'limit': limit,
      'date_sort': filters.sort.apiValue,
      if (filters.cityId != null) 'city_id': filters.cityId,
    };

    // ✅ مهم: إذا baseUrl عندك فيه /api، استخدم المسار بدون /api لتجنب /api/api
    final res = await dio.get('/service-requests', queryParameters: qp);

    final data = res.data as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>? ?? const []);

    final pagination = (data['pagination'] as Map<String, dynamic>? ?? {});
    final total = (pagination['total'] as num?)?.toInt() ?? 0;
    final currentPage = (pagination['page'] as num?)?.toInt() ?? page;
    final currentLimit = (pagination['limit'] as num?)?.toInt() ?? limit;
    final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;

    final items = list.map((e) {
      final m = e as Map<String, dynamic>;

      final user = (m['user'] as Map<String, dynamic>?);
      final first = _safeStr(user?['first_name']);
      final last = _safeStr(user?['last_name']);
      final fallbackName = ('$first $last').trim();

      final name = _safeStr(m['name']);
      final customerName = name.isNotEmpty ? name : (fallbackName.isNotEmpty ? fallbackName : '—');

      final cityObj = (m['city'] as Map<String, dynamic>?);
      final areaObj = (m['area'] as Map<String, dynamic>?);
      final categoryObj = (m['category'] as Map<String, dynamic>?);

      final cityNameAr = _safeStr(cityObj?['name_ar']);
      final areaNameAr = _safeStr(areaObj?['name_ar']);
      final categoryNameAr = _safeStr(categoryObj?['name_ar']);

      final desc = _safeStr(m['description']);
      final description = desc.isNotEmpty ? desc : 'بدون تفاصيل';

      final date = _formatDate(_safeStr(m['service_date']));
      final time = _safeStr(m['service_time']);
      final timeLabel = time.isNotEmpty ? time : '—';

      final budget = _toDouble(m['budget']);
      final createdAt = DateTime.tryParse(_safeStr(m['created_at'])) ?? DateTime.now();

      return MarketplaceRequestEntity(
        id: (m['id'] as num).toInt(),
        cityId: (m['city_id'] as num?)?.toInt(),
        areaId: (m['area_id'] as num?)?.toInt(),
        customerName: customerName,
        phone: _safeStr(m['phone']).isEmpty ? null : _safeStr(m['phone']),
        cityName: cityNameAr.isEmpty ? null : cityNameAr,
        areaName: areaNameAr.isEmpty ? null : areaNameAr,
        title: 'طلب خدمة',
        description: description,
        categoryLabel: categoryNameAr.isEmpty ? null : categoryNameAr,
        dateLabel: date,
        timeLabel: timeLabel,
        budgetMin: budget,
        budgetMax: budget,
        createdAt: createdAt,
      );
    }).toList();

    return MarketplacePagedResult(
      items: items,
      page: currentPage,
      limit: currentLimit,
      total: total,
      totalPages: totalPages,
    );
  }

  @override
  Future<void> acceptRequest(int requestId) async {
    // ✅ PUT /service-requests/:id/accept
    await dio.put('/service-requests/$requestId/accept');
  }
}
