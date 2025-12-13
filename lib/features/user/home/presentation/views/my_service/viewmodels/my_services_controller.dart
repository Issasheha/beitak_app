import 'dart:io';

import 'package:dio/dio.dart';

import 'package:beitak_app/core/error/exceptions.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'my_services_state.dart';

class MyServicesController extends StateNotifier<MyServicesState> {
  final Dio _dio;
  final AuthLocalDataSource _local;

  MyServicesController({
    Dio? dio,
    AuthLocalDataSource? local,
  })  : _dio = dio ?? ApiClient.dio,
        _local = local ?? AuthLocalDataSourceImpl(),
        super(MyServicesState.initial());

  TabBookingState _tabState(MyServicesTab tab) => state.tab(tab);

  Future<String?> _getToken() async {
    final session = await _local.getCachedAuthSession();
    return session?.token;
  }

  Future<void> loadInitial(MyServicesTab tab, {int limit = 20}) async {
    var current = _tabState(tab);

    current = current.copyWith(
      isLoading: true,
      error: null,
      page: 1,
      hasMore: true,
      items: const [],
    );
    state = state.copyWithTab(tab, current);

    try {
      await _fetch(tab: tab, page: 1, limit: limit, append: false);
    } finally {
      final after = _tabState(tab).copyWith(isLoading: false);
      state = state.copyWithTab(tab, after);
    }
  }

  Future<void> loadMore(MyServicesTab tab, {int limit = 20}) async {
    final current = _tabState(tab);
    if (current.isLoadingMore || !current.hasMore) return;

    state = state.copyWithTab(
      tab,
      current.copyWith(isLoadingMore: true, error: null),
    );

    try {
      await _fetch(
        tab: tab,
        page: current.page + 1,
        limit: limit,
        append: true,
      );
    } finally {
      final after = _tabState(tab).copyWith(isLoadingMore: false);
      state = state.copyWithTab(tab, after);
    }
  }

  Future<void> _fetch({
    required MyServicesTab tab,
    required int page,
    required int limit,
    required bool append,
  }) async {
    final token = await _getToken();
    if (token == null) {
      final current = _tabState(tab);
      state = state.copyWithTab(
        tab,
        current.copyWith(
          error: 'يرجى تسجيل الدخول لعرض طلباتك.',
          hasMore: false,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
      return;
    }

    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        'include': 'service,provider,provider.user',
        'sort': '-created_at',
      };

      // نفس المنطق القديم: pending مع فلتر status إن كان الباك يدعمه
      if (tab == MyServicesTab.pending) {
        query['status'] = 'pending_provider_accept';
      }

      final res = await _dio.get(
        '/bookings/my',
        queryParameters: query,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            HttpHeaders.acceptHeader: 'application/json',
          },
        ),
      );

      final code = res.statusCode ?? 0;
      final body = res.data;

      if (body is! Map<String, dynamic>) {
        throw ServerException(
          message: 'Invalid response format',
          statusCode: code,
        );
      }

      final success = body['success'] as bool? ?? (code >= 200 && code < 300);
      if (!success) {
        throw ServerException(
          message: body['message']?.toString() ?? 'Request failed',
          statusCode: code,
          errors: body['errors'] is Map<String, dynamic>
              ? body['errors'] as Map<String, dynamic>
              : null,
        );
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid bookings response format',
        );
      }

      final bookingsJson = data['bookings'];
      if (bookingsJson is! List) {
        throw const ServerException(
          message: 'Invalid bookings list format',
        );
      }

      final pagination = data['pagination'];
      final hasNext = (pagination is Map<String, dynamic>)
          ? (pagination['has_next'] as bool? ?? false)
          : false;

      final mapped = bookingsJson
          .whereType<Map<String, dynamic>>()
          .map<BookingListItem>(_mapBookingToItem)
          .toList();

      final visible = _applyTabFilter(tab, mapped);

      final current = _tabState(tab);
      final newItems = <BookingListItem>[
        if (append) ...current.items,
        ...visible,
      ];

      final updated = current.copyWith(
        items: newItems,
        page: page,
        hasMore: hasNext,
        error: null,
      );

      state = state.copyWithTab(tab, updated);
    } on DioException catch (e) {
      final current = _tabState(tab);
      String message;

      if (e.response?.data is Map<String, dynamic>) {
        message =
            (e.response!.data as Map<String, dynamic>)['message']?.toString() ??
                'حدث خطأ أثناء الاتصال بالخادم.';
      } else if (e.error is SocketException) {
        message =
            'تعذر الاتصال بالسيرفر، تحقق من اتصال الإنترنت وحاول مرة أخرى.';
      } else {
        message = 'حدث خطأ غير متوقع، حاول مرة أخرى لاحقاً.';
      }

      final updated = current.copyWith(
        error: message,
        hasMore: false,
      );
      state = state.copyWithTab(tab, updated);
    } on ServerException catch (e) {
      final current = _tabState(tab);
      final updated = current.copyWith(
        error: e.message ?? 'حدث خطأ غير متوقع.',
        hasMore: false,
      );
      state = state.copyWithTab(tab, updated);
    } catch (_) {
      final current = _tabState(tab);
      final updated = current.copyWith(
        error: 'حدث خطأ غير متوقع.',
        hasMore: false,
      );
      state = state.copyWithTab(tab, updated);
    }
  }

  List<BookingListItem> _applyTabFilter(
    MyServicesTab tab,
    List<BookingListItem> items,
  ) {
    return items.where((it) {
      if (tab == MyServicesTab.pending) return it.isPending;
      if (tab == MyServicesTab.upcoming) return it.isUpcoming;

      // الأرشيف = مكتملة + ملغاة + refunded
      if (tab == MyServicesTab.archive) {
        return it.isCompleted || it.isCancelled;
      }

      return true;
    }).toList();
  }

  BookingListItem _mapBookingToItem(Map<String, dynamic> json) {
    final bookingId = (json['id'] is int)
        ? json['id'] as int
        : int.tryParse('${json['id']}') ?? 0;

    final bookingNumber =
        (json['booking_number'] ?? json['id'] ?? '').toString();
    final status = (json['status'] ?? '').toString();

    // service name
    String serviceName = 'خدمة';
    final service = json['service'];
    if (service is Map<String, dynamic>) {
      serviceName = (service['name_localized'] ??
              service['name_ar'] ??
              service['name'] ??
              'خدمة')
          .toString();
    }

    final date = json['booking_date']?.toString() ?? '';
    final time = _formatTime(json['booking_time']?.toString() ?? '');

    final city = json['service_city']?.toString() ?? '';
    final area = json['service_area']?.toString() ?? '';
    final address = json['service_address']?.toString() ?? '';
    final loc =
        [city, area, address].where((e) => e.trim().isNotEmpty).join('، ');

    // price (قد تكون في booking أو service)
    double? price;
    final rawPrice = json['total_price'] ?? json['base_price'];
    if (rawPrice is num) price = rawPrice.toDouble();
    if (price == null && service is Map<String, dynamic>) {
      final sp = service['base_price'];
      if (sp is num) price = sp.toDouble();
    }

    // provider info (قد تكون null/مخفية قبل التأكيد)
    String? providerName;
    String? providerPhone;

    final provider = json['provider'];
    if (provider is Map<String, dynamic>) {
      final user = provider['user'];
      if (user is Map<String, dynamic>) {
        final fn = (user['first_name'] ?? '').toString().trim();
        final ln = (user['last_name'] ?? '').toString().trim();
        final full = ('$fn $ln').trim();
        providerName = full.isEmpty ? null : full;

        final ph = user['phone'];
        if (ph != null) {
          final p = ph.toString().trim();
          providerPhone = p.isEmpty ? null : p;
        }
      }
    }

    return BookingListItem(
      bookingId: bookingId,
      bookingNumber: bookingNumber,
      status: status,
      typeLabel: _statusToType(status),
      serviceName: serviceName,
      date: date,
      time: time,
      location: loc,
      price: price,
      currency: 'JOD',
      providerName: providerName,
      providerPhone: providerPhone,
    );
  }

  String _statusToType(String status) {
    switch (status) {
      case 'pending_provider_accept':
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
      case 'provider_on_way':
      case 'provider_arrived':
      case 'in_progress':
        return 'قادمة';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
      case 'refunded':
        return 'ملغاة';
      default:
        return 'قيد الانتظار';
    }
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    final parts = raw.split(':');
    if (parts.length < 2) return raw;

    int h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];

    final suffix = h >= 12 ? 'م' : 'ص';
    if (h == 0) h = 12;
    if (h > 12) h -= 12;

    return '$h:$m $suffix';
  }
}
