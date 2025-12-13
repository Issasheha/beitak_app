import 'dart:async';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_history_state.dart';

class ProviderHistoryController
    extends AsyncNotifier<ProviderHistoryState> {
  @override
  FutureOr<ProviderHistoryState> build() async {
    return _loadPage(page: 1);
  }

  /// تغيير التاب النشط
  void setTab(HistoryTab tab) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(activeTab: tab));
  }

  /// تحميل الصفحة الأولى (أو صفحة معينة) من السجل
  Future<ProviderHistoryState> _loadPage({required int page}) async {
    final res = await ApiClient.dio.get(
      ApiConstants.bookingsMy,
      queryParameters: {
        'page': page,
        'limit': 20,
      },
    );

    final root = res.data ?? {};
    final data = root['data'] ?? {};
    final List list = (data['bookings'] as List?) ?? [];
    final pagination = data['pagination'] ?? {};

    List<BookingHistoryItem> items = list.map((raw) {
      final customer = raw['customer'] ?? {};
      final service = raw['service'] ?? {};

      String _s(dynamic v) => (v ?? '').toString();
      double _d(dynamic v) {
        if (v is num) return v.toDouble();
        return double.tryParse(v?.toString() ?? '0') ?? 0.0;
      }

      final bookingDate = _s(raw['booking_date']); // 2025-12-10
      final bookingTime = _s(raw['booking_time']); // 04:00:00

      final dateLabel = bookingDate; // ممكن نعمل فورمات أجمل لاحقاً
      final timeLabel = bookingTime; // أو: "04:00"

      final status = _s(raw['status']).toLowerCase();

      final city = _s(raw['service_city']);
      final area = raw['service_area']?.toString();

      final firstName = _s(customer['first_name']);
      final lastName = _s(customer['last_name']);
      final customerName = (firstName.isEmpty && lastName.isEmpty)
          ? 'عميل'
          : '$firstName $lastName';

      final serviceName =
          _s(service['name_ar'].toString().isNotEmpty
              ? service['name_ar']
              : service['name']);

      return BookingHistoryItem(
        id: raw['id'] as int,
        status: status,
        serviceTitle: serviceName.isEmpty ? 'خدمة بدون اسم' : serviceName,
        customerName: customerName,
        city: city,
        area: area,
        dateLabel: dateLabel,
        timeLabel: timeLabel,
        totalPrice: _d(raw['total_price']),
        cancellationReason:
            raw['cancellation_reason']?.toString().trim().isEmpty ?? true
                ? null
                : raw['cancellation_reason'].toString(),
      );
    }).toList();

    return ProviderHistoryState(
      bookings: items,
      activeTab: HistoryTab.completed,
      currentPage: pagination['current_page'] is int
          ? pagination['current_page'] as int
          : page,
      hasNext: pagination['has_next'] == true,
      isLoadingMore: false,
    );
  }

  /// إعادة تحميل من البداية
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final newState = await _loadPage(page: 1);
      state = AsyncData(newState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// (اختياري) تحميل المزيد – لو حاب تستخدمه لاحقاً
  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasNext || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;
      final res = await ApiClient.dio.get(
        ApiConstants.bookingsMy,
        queryParameters: {
          'page': nextPage,
          'limit': 20,
        },
      );

      final root = res.data ?? {};
      final data = root['data'] ?? {};
      final List list = (data['bookings'] as List?) ?? [];
      final pagination = data['pagination'] ?? {};

      List<BookingHistoryItem> moreItems = list.map((raw) {
        final customer = raw['customer'] ?? {};
        final service = raw['service'] ?? {};

        String _s(dynamic v) => (v ?? '').toString();
        double _d(dynamic v) {
          if (v is num) return v.toDouble();
          return double.tryParse(v?.toString() ?? '0') ?? 0.0;
        }

        final bookingDate = _s(raw['booking_date']);
        final bookingTime = _s(raw['booking_time']);

        final status = _s(raw['status']).toLowerCase();

        final city = _s(raw['service_city']);
        final area = raw['service_area']?.toString();

        final firstName = _s(customer['first_name']);
        final lastName = _s(customer['last_name']);
        final customerName = (firstName.isEmpty && lastName.isEmpty)
            ? 'عميل'
            : '$firstName $lastName';

        final serviceName =
            _s(service['name_ar'].toString().isNotEmpty
                ? service['name_ar']
                : service['name']);

        return BookingHistoryItem(
          id: raw['id'] as int,
          status: status,
          serviceTitle: serviceName.isEmpty ? 'خدمة بدون اسم' : serviceName,
          customerName: customerName,
          city: city,
          area: area,
          dateLabel: bookingDate,
          timeLabel: bookingTime,
          totalPrice: _d(raw['total_price']),
          cancellationReason:
              raw['cancellation_reason']?.toString().trim().isEmpty ?? true
                  ? null
                  : raw['cancellation_reason'].toString(),
        );
      }).toList();

      final merged = [...current.bookings, ...moreItems];

      state = AsyncData(
        current.copyWith(
          bookings: merged,
          currentPage: pagination['current_page'] is int
              ? pagination['current_page'] as int
              : nextPage,
          hasNext: pagination['has_next'] == true,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      state = AsyncData(
        current.copyWith(isLoadingMore: false),
      );
    }
  }
}
