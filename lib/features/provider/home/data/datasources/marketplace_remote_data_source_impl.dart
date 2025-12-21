import 'package:beitak_app/features/provider/home/domain/entities/marketplace_page_entity.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/marketplace_request_entity.dart';
import '../../presentation/views/marketplace/models/marketplace_filters.dart';
import 'marketplace_remote_data_source.dart';

class MarketplaceApiException implements Exception {
  final String message;
  final String? code;

  /// Optional details from API (useful for better UI messages)
  final dynamic requestCategory;
  final List<dynamic>? yourCategories;

  /// ✅ DATE_CONFLICT details
  final String? conflictingDate; // yyyy-MM-dd
  final int? existingBookingId;
  final String? existingBookingNumber;
  final String? existingBookingStatus;

  /// (اختياري) كود HTTP لو حبيت
  final int? httpStatus;

  const MarketplaceApiException({
    required this.message,
    this.code,
    this.requestCategory,
    this.yourCategories,
    this.conflictingDate,
    this.existingBookingId,
    this.existingBookingNumber,
    this.existingBookingStatus,
    this.httpStatus,
  });

  @override
  String toString() =>
      'MarketplaceApiException(code: $code, message: $message)';
}

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
    if (raw.trim().isEmpty) return '—';
    final parts = raw.split('-');
    if (parts.length != 3) return raw;
    final y = parts[0];
    final m = parts[1];
    final d = parts[2];
    return '$d/$m/$y';
  }

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return <String, dynamic>{};
  }

  MarketplaceApiException _apiExceptionFromMap(
    Map<String, dynamic> data, {
    String fallbackMessage = 'حدث خطأ غير متوقع',
    int? httpStatus,
  }) {
    final msg = _safeStr(data['message']);
    final code = _safeStr(data['code']);

    final requestCategory = data['request_category'];
    final yourCategories = (data['your_categories'] is List)
        ? (data['your_categories'] as List<dynamic>)
        : null;

    // ✅ DATE_CONFLICT extras
    final conflictingDate = _safeStr(data['conflicting_date']);
    final existing = _asMap(data['existing_booking']);
    final existingIdRaw = existing['id'];
    final existingId = (existingIdRaw is num)
        ? existingIdRaw.toInt()
        : int.tryParse('$existingIdRaw');
    final existingNumber = _safeStr(existing['booking_number']);
    final existingStatus = _safeStr(existing['status']);

    return MarketplaceApiException(
      message: msg.isNotEmpty ? msg : fallbackMessage,
      code: code.isNotEmpty ? code : null,
      requestCategory: requestCategory,
      yourCategories: yourCategories,
      conflictingDate: conflictingDate.isEmpty ? null : conflictingDate,
      existingBookingId: existingId,
      existingBookingNumber: existingNumber.isEmpty ? null : existingNumber,
      existingBookingStatus: existingStatus.isEmpty ? null : existingStatus,
      httpStatus: httpStatus,
    );
  }

  MarketplaceApiException _apiExceptionFromDio(DioException e) {
    final data = _asMap(e.response?.data);
    final status = e.response?.statusCode;

    // إذا الباك رجّع JSON واضح (مثل success/message/code) نستعمله
    if (data.isNotEmpty) {
      return _apiExceptionFromMap(
        data,
        fallbackMessage: 'فشل تنفيذ الطلب',
        httpStatus: status,
      );
    }

    // fallback حسب نوع الخطأ
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const MarketplaceApiException(
        message: 'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return const MarketplaceApiException(
        message: 'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
      );
    }

    return MarketplaceApiException(
      message: 'فشل تنفيذ الطلب (${status ?? '—'}).',
      httpStatus: status,
    );
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
      if (filters.categoryId != null) 'category_id': filters.categoryId, // ✅
    };

    try {
      final res = await dio.get('/service-requests', queryParameters: qp);

      final data = _asMap(res.data);
      if (data.isEmpty) {
        throw const MarketplaceApiException(
            message: 'استجابة غير صالحة من الخادم');
      }

      if (data['success'] != true) {
        throw _apiExceptionFromMap(
          data,
          fallbackMessage: 'فشل تحميل الطلبات',
          httpStatus: res.statusCode,
        );
      }

      final list = (data['data'] as List<dynamic>? ?? const []);

      final pagination = (data['pagination'] as Map<String, dynamic>? ?? {});
      final total = (pagination['total'] as num?)?.toInt() ?? 0;
      final currentPage = (pagination['page'] as num?)?.toInt() ?? page;
      final currentLimit = (pagination['limit'] as num?)?.toInt() ?? limit;
      final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;

      final items = list.map((e) {
        final m = Map<String, dynamic>.from(e as Map);

        final user = (m['user'] as Map<String, dynamic>?);
        final first = _safeStr(user?['first_name']);
        final last = _safeStr(user?['last_name']);
        final fallbackName = ('$first $last').trim();

        final name = _safeStr(m['name']);
        final customerName = name.isNotEmpty
            ? name
            : (fallbackName.isNotEmpty ? fallbackName : '—');

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
        final createdAt =
            DateTime.tryParse(_safeStr(m['created_at'])) ?? DateTime.now();

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
          categoryId: (m['category_id'] as num?)?.toInt() ??
              ((m['category'] is Map)
                  ? ((m['category']['id'] as num?)?.toInt())
                  : null),
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
    } on DioException catch (e) {
      throw _apiExceptionFromDio(e);
    }
  }

  @override
  Future<void> acceptRequest(int requestId) async {
    try {
      final res = await dio.put('/service-requests/$requestId/accept');

      final data = _asMap(res.data);
      if (data.isEmpty) {
        throw const MarketplaceApiException(
            message: 'استجابة غير صالحة من الخادم');
      }

      if (data['success'] != true) {
        throw _apiExceptionFromMap(
          data,
          fallbackMessage: 'فشل قبول الطلب',
          httpStatus: res.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _apiExceptionFromDio(e);
    }
  }
}
