import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/error/error_text.dart';

import 'provider_history_state.dart';

class ProviderHistoryController extends AsyncNotifier<ProviderHistoryState> {
  static final RegExp _arabicRegex = RegExp(r'[\u0600-\u06FF]');

  /// ✅ TTL للكاش (حتى لو refresh ما نعمل ضغط على السيرفر كثير)
  static const Duration _reviewsCacheTtl = Duration(minutes: 2);

  Map<int, _MyReviewLite>? _myReviewsCache;
  DateTime? _myReviewsLastFetch;

  static const Map<String, String> _areasArMap = {
    'abdoun': 'عبدون',
    'abdoun ': 'عبدون',
    'downtown': 'البلدة القديمة',
    'jabal al-hussein': 'جبل الحسين',
    'jabal al hussein': 'جبل الحسين',
    'jabal-al-hussein': 'جبل الحسين',
    'jabal amman': 'جبل عمان',
    'jabal-amman': 'جبل عمان',
    'jubeiha': 'الجبيهة',
    'khalda': 'خلدا',
    'rainbow street': 'شارع الرينبو',
    'rainbow-street': 'شارع الرينبو',
    'shmeisani': 'الشميساني',
    'sweifieh': 'الشفا',
    'tla\'a al-ali': 'تلاع العلي',
    'tlaa al-ali': 'تلاع العلي',
    'tlaa-al-ali': 'تلاع العلي',
    'aqaba port': 'ميناء العقبة',
    'aqaba-port': 'ميناء العقبة',
    'city center': 'وسط المدينة',
    'city-center': 'وسط المدينة',
    'south beach': 'الشاطئ الجنوبي',
    'south-beach': 'الشاطئ الجنوبي',
    'tala bay': 'تالا باي',
    'tala-bay': 'تالا باي',
  };

  @override
  FutureOr<ProviderHistoryState> build() async {
    final link = ref.keepAlive();
    Timer? timer;
    ref.onCancel(() {
      timer?.cancel();
      timer = Timer(const Duration(minutes: 2), link.close);
    });
    ref.onResume(() => timer?.cancel());

    return _loadPage(
      page: 1,
      keepTab: HistoryTab.completed,
      ratedBookingIds: const <int>{},
      submittingRatingIds: const <int>{},
      forceRefreshReviewsCache: true, // أول مرة نجيبها أكيد
    );
  }

  void setTab(HistoryTab tab) {
    final current = state.asData?.value ?? ProviderHistoryState.initial();
    state = AsyncData(current.copyWith(activeTab: tab));
  }

  Future<void> refresh() async {
    final prev = state.asData?.value;
    final currentTab = prev?.activeTab ?? HistoryTab.completed;

    final rated = prev?.ratedBookingIds ?? <int>{};
    final submitting = prev?.submittingRatingIds ?? <int>{};

    state = const AsyncLoading();

    state = AsyncData(await _loadPage(
      page: 1,
      keepTab: currentTab,
      ratedBookingIds: rated,
      submittingRatingIds: submitting,
      // ✅ refresh: لا نعمل fetch إذا الكاش لسه جديد
      forceRefreshReviewsCache: false,
    ));
  }

  // =================== Reviews Cache ===================

  bool _isReviewsCacheValid() {
    if (_myReviewsCache == null) return false;
    if (_myReviewsLastFetch == null) return false;
    return DateTime.now().difference(_myReviewsLastFetch!) <= _reviewsCacheTtl;
  }

  Future<Map<int, _MyReviewLite>> _getMyReviewsMapCached({
    required bool forceRefresh,
  }) async {
    if (!forceRefresh && _isReviewsCacheValid()) {
      return _myReviewsCache!;
    }

    final fresh = await _fetchMyReviewsMap();
    _myReviewsCache = fresh;
    _myReviewsLastFetch = DateTime.now();
    return fresh;
  }

  // ✅ NEW: جلب مراجعاتي وربطها بـ booking_id (pagination)
  Future<Map<int, _MyReviewLite>> _fetchMyReviewsMap() async {
    final out = <int, _MyReviewLite>{};

    int page = 1;
    bool hasNext = true;

    while (hasNext) {
      final res = await ApiClient.dio.get(
        ApiConstants.providerMyReviews,
        queryParameters: {'page': page, 'limit': 50},
      );

      final root = res.data ?? {};
      final success = root['success'] == true;
      if (!success) break;

      final data = root['data'];
      if (data is List) {
        for (final e in data) {
          if (e is Map) {
            final bid = int.tryParse('${e['booking_id']}') ?? 0;
            if (bid <= 0) continue;

            final ratingNum = e['rating'];
            final rating = (ratingNum is num) ? ratingNum.toInt() : int.tryParse('$ratingNum');

            final review = (e['review'] ?? '').toString().trim();

            // نخزن حتى لو review لحاله
            if ((rating != null && rating > 0) || review.isNotEmpty) {
              out[bid] = _MyReviewLite(rating: rating ?? 0, review: review);
            }
          }
        }
      }

      final pag = root['pagination'];
      if (pag is Map) {
        hasNext = pag['has_next'] == true;
      } else {
        hasNext = false;
      }

      page++;
      if (page > 20) break; // safety
    }

    return out;
  }

  // =================== Load bookings ===================

  Future<ProviderHistoryState> _loadPage({
    required int page,
    required HistoryTab keepTab,
    required Set<int> ratedBookingIds,
    required Set<int> submittingRatingIds,
    required bool forceRefreshReviewsCache,
  }) async {
    // 1) bookings
    final res = await ApiClient.dio.get(
      ApiConstants.bookingsMy,
      queryParameters: {'page': page, 'limit': 20},
    );

    final root = res.data ?? {};
    final data = root['data'] ?? root;

    final List list = (data['bookings'] as List?) ?? const [];
    final pagination = data['pagination'] ?? const {};

    var items = list.map((e) => _mapBooking(e)).toList(growable: false);

    // 2) my reviews (cached)
    Map<int, _MyReviewLite> myReviews = {};
    try {
      myReviews = await _getMyReviewsMapCached(forceRefresh: forceRefreshReviewsCache);
    } catch (_) {
      myReviews = {};
    }

    // 3) inject into items
    items = items.map((b) {
      final r = myReviews[b.id];
      if (r == null) return b;
      return b.copyWith(
        userRating: (r.rating > 0) ? r.rating : null,
        userReview: r.review.isEmpty ? null : r.review,
      );
    }).toList(growable: false);

    // rated من الباك (providerRated = true)
    final serverRated = items.where((b) => b.providerRated).map((b) => b.id).toSet();
    final mergedRated = {...ratedBookingIds, ...serverRated};

    final sorted = items.toList(growable: false)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return ProviderHistoryState(
      activeTab: keepTab,
      bookings: sorted,
      completed: sorted.where((b) => b.isCompleted).toList(growable: false),
      cancelled: sorted.where((b) => b.isCancelled).toList(growable: false),
      incomplete: sorted.where((b) => b.isIncomplete).toList(growable: false),
      currentPage: pagination['current_page'] is int ? pagination['current_page'] as int : page,
      hasNext: pagination['has_next'] == true,
      isLoadingMore: false,
      ratedBookingIds: mergedRated,
      submittingRatingIds: submittingRatingIds,
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

      var newItems = list.map((e) => _mapBooking(e)).toList(growable: false)
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // ✅ هنا ما بنعيد fetch — بنستخدم الكاش
      Map<int, _MyReviewLite> myReviews = {};
      try {
        myReviews = await _getMyReviewsMapCached(forceRefresh: false);
      } catch (_) {
        myReviews = {};
      }

      newItems = newItems.map((b) {
        final r = myReviews[b.id];
        if (r == null) return b;
        return b.copyWith(
          userRating: (r.rating > 0) ? r.rating : null,
          userReview: r.review.isEmpty ? null : r.review,
        );
      }).toList(growable: false);

      final merged = _mergeSortedDesc(current.bookings, newItems);

      final serverRated2 = newItems.where((b) => b.providerRated).map((b) => b.id).toSet();
      final mergedRated = {...current.ratedBookingIds, ...serverRated2};

      state = AsyncData(
        current.copyWith(
          bookings: merged,
          currentPage: pagination['current_page'] is int ? pagination['current_page'] as int : nextPage,
          hasNext: pagination['has_next'] == true,
          isLoadingMore: false,
          ratedBookingIds: mergedRated,
        ),
      );
    } catch (_) {
      final current2 = state.asData?.value ?? current;
      state = AsyncData(current2.copyWith(isLoadingMore: false));
    }
  }

  /// ✅ إرسال تقييم مزود الخدمة (provider->user)
    /// ✅ إرسال تقييم مزود الخدمة (provider->user)
  Future<void> submitProviderRating({
    required int bookingId,
    required int providerRating,
    required double amountPaid,
    String? providerResponse,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    // ✅ Validation (حتى لو UI نسي)
    if (providerRating <= 0) {
      throw Exception('يرجى اختيار التقييم قبل الإرسال');
    }
    if (amountPaid <= 0) {
      throw Exception('يرجى إدخال المبلغ المدفوع بشكل صحيح');
    }

    if (current.isRated(bookingId)) {
      throw Exception('تم تقييم هذه الخدمة مسبقاً.');
    }

    if (current.submittingRatingIds.contains(bookingId)) return;

    final submitting = {...current.submittingRatingIds, bookingId};
    state = AsyncData(current.copyWith(submittingRatingIds: submitting));

    try {
      final payload = <String, dynamic>{
        'provider_rating': providerRating,
        'amount_paid': amountPaid,
      };

      final msg = (providerResponse ?? '').trim();
      if (msg.isNotEmpty) payload['provider_response'] = msg;

      await ApiClient.dio.post(
        ApiConstants.providerBookingRating(bookingId),
        data: payload,
      );

      final latest = state.asData?.value ?? current;

      final rated = {...latest.ratedBookingIds, bookingId};
      final submitting2 = {...latest.submittingRatingIds}..remove(bookingId);

      state = AsyncData(latest.copyWith(
        ratedBookingIds: rated,
        submittingRatingIds: submitting2,
      ));
    } on DioException catch (e) {
      final latest = state.asData?.value ?? current;
      final submitting2 = {...latest.submittingRatingIds}..remove(bookingId);
      state = AsyncData(latest.copyWith(submittingRatingIds: submitting2));

      // ✅ خلي الرسالة عربية وواضحة (حسب error_text.dart عندك)
      throw Exception(errorText(e));
    } catch (_) {
      final latest = state.asData?.value ?? current;
      final submitting2 = {...latest.submittingRatingIds}..remove(bookingId);
      state = AsyncData(latest.copyWith(submittingRatingIds: submitting2));
      throw Exception('تعذر إرسال التقييم. حاول مرة أخرى.');
    }
  }


  // ===================== helpers =====================

  List<BookingHistoryItem> _mergeSortedDesc(
    List<BookingHistoryItem> a,
    List<BookingHistoryItem> b,
  ) {
    final out = <BookingHistoryItem>[];
    int i = 0, j = 0;

    while (i < a.length && j < b.length) {
      if (a[i].dateTime.isAfter(b[j].dateTime) ||
          a[i].dateTime.isAtSameMomentAs(b[j].dateTime)) {
        out.add(a[i++]);
      } else {
        out.add(b[j++]);
      }
    }
    if (i < a.length) out.addAll(a.sublist(i));
    if (j < b.length) out.addAll(b.sublist(j));
    return out;
  }

  BookingHistoryItem _mapBooking(dynamic raw) {
    final m = (raw is Map) ? raw : <String, dynamic>{};

    final id = _toInt(m['id']);
    final bookingNumber = _s(m['booking_number']);

    final statusRaw = _s(m['status']).trim();
    final status = statusRaw.isEmpty ? '—' : statusRaw;

    final service = m['service'];
    String serviceName = _s(
      service is Map
          ? (service['name_ar'] ??
              service['nameAr'] ??
              service['name'] ??
              service['title'])
          : (m['service_name'] ?? m['serviceTitle']),
    ).trim();

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

    final user = m['user'] ?? m['customer'] ?? m['client'];
    final customerName = _buildName(user);

    final bookingDate = _s(m['booking_date']);
    final bookingTime = _s(m['booking_time']);

    final dt = _parseDateTime(bookingDate, bookingTime);
    final dateLabel = _formatDateLabel(bookingDate);
    final timeLabel = _formatTimeLabel(bookingTime);

    final totalPrice = _toDouble(m['total_price'] ?? m['totalPrice'] ?? m['price']);

    final cityRaw = _s(m['service_city'] ?? m['city'] ?? '');
    final city = _normalizeCityAr(cityRaw);

    final areaRaw = _nullableS(m['service_area'] ?? m['area']);
    final area = _normalizeAreaAr(areaRaw);

    final cancellationReasonRaw = _nullableS(
      m['cancellation_reason'] ??
          m['cancel_reason'] ??
          m['cancelled_reason'] ??
          m['reason'],
    );
    final cancellationReason = _cancelReasonArabic(cancellationReasonRaw);

    final providerNotesRaw = _nullableS(m['provider_notes']);
    final providerNotes =
        (providerNotesRaw != null && providerNotesRaw.trim().isNotEmpty)
            ? providerNotesRaw.trim()
            : null;

    final providerRated = _extractProviderRated(m);

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
      providerRated: providerRated,

      // inject لاحقاً
      userRating: null,
      userReview: null,

      dateTime: dt,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
    );
  }

  bool _extractProviderRated(Map m) {
    final ratingObj = m['rating'];
    if (ratingObj is Map) {
      final pr = _toInt(ratingObj['provider_rating'] ?? ratingObj['providerRating']);
      return pr > 0;
    }
    final pr2 = _toInt(m['provider_rating'] ?? m['providerRating']);
    return pr2 > 0;
  }

  DateTime _parseDateTime(String date, String time) {
    try {
      final d = date.split('-').map((e) => int.tryParse(e) ?? 0).toList();
      final t = time.split(':').map((e) => int.tryParse(e) ?? 0).toList();
      return DateTime(
        d.isNotEmpty ? d[0] : 1970,
        d.length > 1 ? d[1] : 1,
        d.length > 2 ? d[2] : 1,
        t.isNotEmpty ? t[0] : 0,
        t.length > 1 ? t[1] : 0,
        t.length > 2 ? t[2] : 0,
      );
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  String _formatDateLabel(String bookingDate) {
    final parts = bookingDate.split('-');
    if (parts.length == 3) {
      final yyyy = parts[0];
      final mm = parts[1];
      final dd = parts[2];
      if (yyyy.isNotEmpty && mm.isNotEmpty && dd.isNotEmpty) {
        return '$dd/$mm/$yyyy';
      }
    }
    return bookingDate;
  }

  String _formatTimeLabel(String bookingTime) {
    final parts = bookingTime.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return bookingTime;
  }

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

  bool _hasArabic(String s) => _arabicRegex.hasMatch(s);

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

  String? _normalizeAreaAr(String? raw) {
    if (raw == null) return null;
    final r0 = raw.trim();
    if (r0.isEmpty) return null;

    if (_hasArabic(r0)) return r0;

    final k0 = r0.toLowerCase().trim();
    final direct = _areasArMap[k0];
    if (direct != null) return direct;

    final k1 = k0.replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ');
    final v1 = _areasArMap[k1];
    if (v1 != null) return v1;

    final k2 = k0.replaceAll('-', ' ').replaceAll(RegExp(r'\s+'), ' ');
    final v2 = _areasArMap[k2];
    if (v2 != null) return v2;

    return r0;
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
    return r;
  }

  String _s(dynamic v) => (v == null) ? '' : v.toString();
  String? _nullableS(dynamic v) => (v == null) ? null : v.toString();

  int _toInt(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class _MyReviewLite {
  final int rating;
  final String review;
  const _MyReviewLite({required this.rating, required this.review});
}
