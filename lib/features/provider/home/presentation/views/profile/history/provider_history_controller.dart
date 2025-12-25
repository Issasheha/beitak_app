import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'provider_history_state.dart';

class ProviderHistoryController extends AsyncNotifier<ProviderHistoryState> {
  @override
  FutureOr<ProviderHistoryState> build() async {
    return _loadPage(page: 1);
  }

  void setTab(HistoryTab tab) {
    final current = state.asData?.value ?? ProviderHistoryState.initial();
    state = AsyncData(current.copyWith(activeTab: tab));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadPage(page: 1));
  }

  Future<ProviderHistoryState> _loadPage({required int page}) async {
    final res = await ApiClient.dio.get(
      ApiConstants.bookingsMy,
      queryParameters: {'page': page, 'limit': 20},
    );

    final root = res.data ?? {};
    final data = root['data'] ?? root;

    final List list = (data['bookings'] as List?) ?? const [];
    final pagination = data['pagination'] ?? const {};

    final items = list.map((e) => _mapBooking(e)).toList();

    // ✅ Latest first
    items.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return ProviderHistoryState(
      activeTab: HistoryTab.completed,
      bookings: items,
      currentPage: pagination['current_page'] is int
          ? pagination['current_page'] as int
          : page,
      hasNext: pagination['has_next'] == true,
      isLoadingMore: false,
    );
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null) return;
    if (!current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;

      final res = await ApiClient.dio.get(
        ApiConstants.bookingsMy,
        queryParameters: {'page': nextPage, 'limit': 20},
      );

      final root = res.data ?? {};
      final data = root['data'] ?? root;

      final List list = (data['bookings'] as List?) ?? const [];
      final pagination = data['pagination'] ?? const {};

      final newItems = list.map((e) => _mapBooking(e)).toList();

      final merged = <BookingHistoryItem>[...current.bookings, ...newItems];
      merged.sort((a, b) => b.dateTime.compareTo(a.dateTime));

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
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  BookingHistoryItem _mapBooking(dynamic raw) {
    final m = (raw is Map) ? raw : <String, dynamic>{};

    final id = _toInt(m['id']);
    final bookingNumber = _s(m['booking_number']);

    final statusRaw = _s(m['status']).trim();
    final status = statusRaw.isEmpty ? '—' : statusRaw;

    // --- service title (try Arabic first, else fallback) ---
    final service = m['service'];
    String serviceName = _s(
      service is Map
          ? (service['name_ar'] ?? service['nameAr'] ?? service['name'] ?? service['title'])
          : (m['service_name'] ?? m['serviceTitle']),
    ).trim();

    // provider.category.name_ar موجود عندك بالـJSON -> نستخدمه كـ fallback
    String? categoryAr;
    final provider = m['provider'];
    if (provider is Map) {
      final cat = provider['category'];
      if (cat is Map) {
        categoryAr = _nullableS(cat['name_ar'] ?? cat['nameAr'])?.trim();
      }
    }

    if (serviceName.isEmpty) {
      serviceName = (categoryAr != null && categoryAr.isNotEmpty)
          ? 'خدمة $categoryAr'
          : 'خدمة';
    } else if (!_hasArabic(serviceName)) {
      serviceName = _fallbackServiceNameAr(
        englishName: serviceName,
        categoryAr: categoryAr,
      );
    }

    // customer
    final user = m['user'] ?? m['customer'] ?? m['client'];
    final customerName = _buildName(user);

    final bookingDate = _s(m['booking_date']);
    final bookingTime = _s(m['booking_time']);

    final totalPrice = _toDouble(m['total_price'] ?? m['totalPrice'] ?? m['price']);

    final cityRaw = _s(m['service_city'] ?? m['city'] ?? '');
    final city = _normalizeCityAr(cityRaw);

    final area = _nullableS(m['service_area'] ?? m['area']);

    final cancellationReasonRaw = _nullableS(
      m['cancellation_reason'] ??
          m['cancel_reason'] ??
          m['cancelled_reason'] ??
          m['reason'],
    );

    final cancellationReason = _cancelReasonArabic(cancellationReasonRaw);

    // ✅ NEW: provider_notes for incomplete
    final providerNotesRaw = _nullableS(m['provider_notes']);
    final providerNotes = (providerNotesRaw != null && providerNotesRaw.trim().isNotEmpty)
        ? providerNotesRaw.trim()
        : null;

    return BookingHistoryItem(
      id: id,
      bookingNumber: bookingNumber,
      status: status,
      serviceTitle: serviceName.isEmpty ? '—' : serviceName,
      customerName: customerName.isEmpty ? '—' : customerName,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      totalPrice: totalPrice,
      city: city.isEmpty ? '—' : city,
      area: (area != null && area.trim().isEmpty) ? null : area,
      cancellationReason: cancellationReason,
      providerNotes: providerNotes,
    );
  }

  // ---------------- helpers ----------------

  String _buildName(dynamic user) {
    if (user is Map) {
      final fn = _s(user['first_name']);
      final ln = _s(user['last_name']);
      final full = '$fn $ln'.trim();
      if (full.isNotEmpty) return full;
      return _s(user['name']);
    }
    return '';
  }

  bool _hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  String _fallbackServiceNameAr({required String englishName, String? categoryAr}) {
    final key = englishName.trim().toLowerCase();

    const dict = <String, String>{
      'deep house cleaning': 'تنظيف منزل عميق',
      'carpet and upholstery cleaning': 'تنظيف سجاد ومفروشات',
      'electrical repair': 'تصليح كهرباء',
      'plumbing repair': 'تصليح سباكة',
      'home cleaning': 'تنظيف منزل',
      'cleaning': 'تنظيف',
    };

    final direct = dict[key];
    if (direct != null) return direct;

    if (categoryAr != null && categoryAr.trim().isNotEmpty) {
      return 'خدمة ${categoryAr.trim()}';
    }
    return 'خدمة';
  }

  String _normalizeCityAr(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '';

    if (_hasArabic(r)) {
      return r.split(RegExp(r'[,،\-]')).first.trim();
    }

    final k = r.toLowerCase().trim();

    const map = <String, String>{
      'amman': 'عمان',
      'zarqa': 'الزرقاء',
      'irbid': 'إربد',
      'aqaba': 'العقبة',
      'salt': 'السلط',
      'madaba': 'مادبا',
      'jerash': 'جرش',
      'mafraq': 'المفرق',
      'karak': 'الكرك',
      'tafileh': 'الطفيلة',
      'maan': 'معان',
      'ajloun': 'عجلون',
    };

    if (k == 'az zarqa' || k == 'al zarqa' || k == 'alzarka') return 'الزرقاء';
    if (k == 'al aqaba' || k == 'el aqaba') return 'العقبة';

    return map[k] ?? r;
  }

  String? _cancelReasonArabic(String? raw) {
    if (raw == null) return null;
    final r = raw.trim();
    if (r.isEmpty) return null;

    if (_hasArabic(r)) return r;

    final k = r.toLowerCase();
    if (k.contains('provider rejected')) return 'تم الإلغاء من قبل المزود';
    if (k.contains('provider')) return 'تم الإلغاء من قبل المزود';
    if (k.contains('user') || k.contains('customer')) return 'تم الإلغاء من قبل العميل';
    if (k.contains('system')) return 'تم الإلغاء تلقائياً';
    return r; // fallback
  }

  String _s(dynamic v) => (v == null) ? '' : v.toString();

  String? _nullableS(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s;
  }

  int _toInt(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
