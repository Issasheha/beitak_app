import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:beitak_app/core/error/exceptions.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';

import 'my_services_state.dart';

class MyServicesController extends StateNotifier<MyServicesState> {
  final Dio _dio;
  final AuthLocalDataSource _local;

  final Map<MyServicesTab, Timer> _guards = {};
  final Map<MyServicesTab, CancelToken> _cancelTokens = {};

  // ✅ نحتفظ بآخر total_pages لكل تاب (لو الباك بيدعمها)
  final Map<MyServicesTab, int?> _totalPages = {};

  // ✅ حماية إضافية: إذا loadMore ما أضاف ولا عنصر → وقف hasMore
  final Map<MyServicesTab, int> _noGrowthStreak = {};
  static const int _allowNoGrowthPages = 1; // صفحة وحدة بدون نمو = وقف

  MyServicesController({
    Dio? dio,
    AuthLocalDataSource? local,
  })  : _dio = dio ?? ApiClient.dio,
        _local = local ?? AuthLocalDataSourceImpl(),
        super(MyServicesState.initial());

  TabBookingState _tabState(MyServicesTab tab) => state.tab(tab);

  @override
  void dispose() {
    for (final t in _guards.values) {
      t.cancel();
    }
    _guards.clear();

    for (final ct in _cancelTokens.values) {
      if (!ct.isCancelled) ct.cancel('dispose');
    }
    _cancelTokens.clear();

    _totalPages.clear();
    _noGrowthStreak.clear();

    super.dispose();
  }

  Future<String?> _getToken() async {
    final session = await _local.getCachedAuthSession();
    return session?.token;
  }

  void _cancelInFlight(MyServicesTab tab) {
    final ct = _cancelTokens[tab];
    if (ct != null && !ct.isCancelled) {
      ct.cancel('cancel_in_flight');
    }
    _cancelTokens.remove(tab);
  }

  CancelToken _newCancelToken(MyServicesTab tab) {
    _cancelInFlight(tab);
    final ct = CancelToken();
    _cancelTokens[tab] = ct;
    return ct;
  }

  void _startGuard(MyServicesTab tab, {required bool isInitial}) {
    _guards[tab]?.cancel();

    _guards[tab] = Timer(const Duration(seconds: 12), () {
      final st = _tabState(tab);

      final stuck =
          isInitial ? (st.isLoading && st.items.isEmpty) : (st.isLoadingMore);

      if (!stuck) return;

      _cancelInFlight(tab);

      state = state.copyWithTab(
        tab,
        st.copyWith(
          isLoading: false,
          isLoadingMore: false,
          hasMore: false,
          error: null,
        ),
      );
    });
  }

  void _stopGuard(MyServicesTab tab) {
    _guards[tab]?.cancel();
    _guards.remove(tab);
  }

  Future<void> loadInitial(MyServicesTab tab, {int limit = 20}) async {
    final check = _tabState(tab);
    if (check.isLoading) return;

    _totalPages.remove(tab);
    _noGrowthStreak[tab] = 0;

    final current = check.copyWith(
      isLoading: true,
      isLoadingMore: false,
      error: null,
      page: 1,
      hasMore: true,
      items: const [],
    );
    state = state.copyWithTab(tab, current);

    _startGuard(tab, isInitial: true);
    final cancelToken = _newCancelToken(tab);

    try {
      await _fetch(
        tab: tab,
        page: 1,
        limit: limit,
        append: false,
        cancelToken: cancelToken,
      );
    } finally {
      _stopGuard(tab);
      _cancelTokens.remove(tab);

      final after = _tabState(tab).copyWith(
        isLoading: false,
        isLoadingMore: false,
      );
      state = state.copyWithTab(tab, after);
    }
  }

  Future<void> loadMore(MyServicesTab tab, {int limit = 20}) async {
    final current = _tabState(tab);

    // ✅ إذا عارفين total_pages وخلصنا: لا تطلب
    final tp = _totalPages[tab];
    if (tp != null && current.page >= tp) {
      state = state.copyWithTab(
        tab,
        current.copyWith(
          hasMore: false,
          isLoadingMore: false,
        ),
      );
      return;
    }

    if (current.isLoadingMore || current.isLoading || !current.hasMore) return;

    state = state.copyWithTab(
      tab,
      current.copyWith(isLoadingMore: true, error: null),
    );

    _startGuard(tab, isInitial: false);
    final cancelToken = _newCancelToken(tab);

    try {
      await _fetch(
        tab: tab,
        page: current.page + 1,
        limit: limit,
        append: true,
        cancelToken: cancelToken,
      );
    } finally {
      _stopGuard(tab);
      _cancelTokens.remove(tab);

      final after = _tabState(tab).copyWith(isLoadingMore: false);
      state = state.copyWithTab(tab, after);
    }
  }

  Future<void> _fetch({
    required MyServicesTab tab,
    required int page,
    required int limit,
    required bool append,
    required CancelToken cancelToken,
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

      if (tab == MyServicesTab.pending) {
        query['status'] = 'pending_provider_accept';
      }

      final res = await _dio
          .get(
            '/bookings/my',
            queryParameters: query,
            options: Options(
              headers: {
                HttpHeaders.authorizationHeader: 'Bearer $token',
                HttpHeaders.acceptHeader: 'application/json',
                HttpHeaders.acceptLanguageHeader: 'ar',
              },
            ),
            cancelToken: cancelToken,
          )
          .timeout(const Duration(seconds: 20));

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
        throw const ServerException(message: 'Invalid bookings response format');
      }

      final bookingsJson = data['bookings'];
      if (bookingsJson is! List) {
        throw const ServerException(message: 'Invalid bookings list format');
      }

      // ✅ pagination أقوى من has_next
      int? totalPages;
      int? currentPageFromApi;
      bool hasNextFromApi = false;

      final pagination = data['pagination'];
      if (pagination is Map<String, dynamic>) {
        totalPages = (pagination['total_pages'] is int)
            ? pagination['total_pages'] as int
            : int.tryParse('${pagination['total_pages']}');

        currentPageFromApi = (pagination['current_page'] is int)
            ? pagination['current_page'] as int
            : int.tryParse('${pagination['current_page']}');

        hasNextFromApi = pagination['has_next'] as bool? ?? false;
      }

      if (totalPages != null) _totalPages[tab] = totalPages;

      // ✅ ماب + فلترة
      final mapped = bookingsJson
          .whereType<Map<String, dynamic>>()
          .map<BookingListItem>(_mapBookingToItem)
          .toList();

      final visible = _applyTabFilter(tab, mapped);

      final current = _tabState(tab);
      final beforeCount = current.items.length;

      final newItems = <BookingListItem>[
        if (append) ...current.items,
        ...visible,
      ];

      final afterCount = newItems.length;
      final grew = afterCount > beforeCount;

      // ✅ لو loadMore وما زاد ولا عنصر: لا نسمح باللوب
      if (append && !grew) {
        final prev = _noGrowthStreak[tab] ?? 0;
        final next = prev + 1;
        _noGrowthStreak[tab] = next;

        if (next >= _allowNoGrowthPages) {
          state = state.copyWithTab(
            tab,
            current.copyWith(
              page: page,
              items: newItems,
              hasMore: false,
              error: null,
              isLoading: false,
              isLoadingMore: false,
            ),
          );
          return;
        }
      } else {
        _noGrowthStreak[tab] = 0;
      }

      // ✅ حساب hasMore بشكل موثوق
      bool hasMore;
      if (totalPages != null) {
        final cp = currentPageFromApi ?? page;
        hasMore = cp < totalPages;
      } else {
        // fallback
        hasMore = hasNextFromApi && visible.isNotEmpty;
      }

      // إذا أول صفحة وطلع فاضي: خلص
      if (page == 1 && newItems.isEmpty) hasMore = false;

      state = state.copyWithTab(
        tab,
        current.copyWith(
          items: newItems,
          page: page,
          hasMore: hasMore,
          error: null,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
    } on TimeoutException {
      final current = _tabState(tab);
      state = state.copyWithTab(
        tab,
        current.copyWith(
          error: null,
          hasMore: false,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        final current = _tabState(tab);
        state = state.copyWithTab(
          tab,
          current.copyWith(
            error: null,
            hasMore: false,
            isLoading: false,
            isLoadingMore: false,
          ),
        );
        return;
      }

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

      state = state.copyWithTab(
        tab,
        current.copyWith(
          error: message,
          hasMore: false,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
    } on ServerException catch (e) {
      final current = _tabState(tab);
      state = state.copyWithTab(
        tab,
        current.copyWith(
          error: e.message ?? 'حدث خطأ غير متوقع.',
          hasMore: false,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      final current = _tabState(tab);
      state = state.copyWithTab(
        tab,
        current.copyWith(
          error: 'حدث خطأ غير متوقع.',
          hasMore: false,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
    }
  }

  List<BookingListItem> _applyTabFilter(
    MyServicesTab tab,
    List<BookingListItem> items,
  ) {
    return items.where((it) {
      if (tab == MyServicesTab.pending) return it.isPending;
      if (tab == MyServicesTab.upcoming) return it.isUpcoming;

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

    // ✅ اسم الخدمة: جرّب عربي من الباك، وإذا طلع إنجليزي → fallback عربي
    String serviceName = 'خدمة';
    String serviceNameRaw = '';

    final service = json['service'];
    if (service is Map<String, dynamic>) {
      serviceNameRaw = (service['name_ar'] ??
              service['nameAr'] ??
              service['name_localized'] ??
              service['name'] ??
              '')
          .toString()
          .trim();
    }

    // category العربي موجود في provider.category.name_ar (زي الريسبونس عندك)
    String? categoryAr;
    final provider = json['provider'];
    if (provider is Map<String, dynamic>) {
      final cat = provider['category'];
      if (cat is Map<String, dynamic>) {
        final v = (cat['name_ar'] ?? cat['nameAr'] ?? '').toString().trim();
        if (v.isNotEmpty) categoryAr = v;
      }
    }

    if (serviceNameRaw.isEmpty) {
      serviceName = categoryAr == null ? 'خدمة' : 'خدمة $categoryAr';
    } else if (_hasArabic(serviceNameRaw)) {
      serviceName = serviceNameRaw;
    } else {
      // ✅ إنجليزي → ترجمة محلية
      serviceName = _fallbackServiceNameAr(
        englishName: serviceNameRaw,
        categoryAr: categoryAr,
      );
    }

    final date = json['booking_date']?.toString() ?? '';
    final time = _formatTime(json['booking_time']?.toString() ?? '');

    final loc = _extractCityAr(json);

    double? price;
    final rawPrice = json['total_price'] ?? json['base_price'];
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice);
    }

    String? providerName;
    String? providerPhone;

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

  // -------------------------
  // ✅ NEW: Arabic fallback for English service names
  // -------------------------

  bool _hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  String _fallbackServiceNameAr({
    required String englishName,
    String? categoryAr,
  }) {
    final key = englishName.trim().toLowerCase();

    // 1) قاموس سريع للأسماء الشائعة
    const dict = <String, String>{
      'plumbing repair': 'تصليح السباكة',
      'plumbing': 'سباكة',
      'cleaning': 'تنظيف',
      'home cleaning': 'تنظيف منزل',
      'deep cleaning': 'تنظيف عميق',
      'electrical repair': 'تصليح كهرباء',
      'appliance repair': 'تصليح أجهزة',
      'ac repair': 'تصليح تكييف',
    };

    final direct = dict[key];
    if (direct != null) return direct;

    // 2) قواعد بسيطة
    if (key.contains('repair') && categoryAr != null && categoryAr.isNotEmpty) {
      // مثال: Repair + categoryAr => تصليح السباكة
      return 'تصليح $categoryAr';
    }

    if (key.contains('clean') && categoryAr != null && categoryAr.isNotEmpty) {
      return 'تنظيف $categoryAr';
    }

    // 3) آخر fallback: اسم عربي عام من التصنيف
    if (categoryAr != null && categoryAr.isNotEmpty) {
      return 'خدمة $categoryAr';
    }

    return 'خدمة';
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

  String _extractCityAr(Map<String, dynamic> json) {
    final v = json['service_city'];

    String raw = '';
    if (v is Map) {
      raw = (v['name_ar'] ??
              v['nameAr'] ??
              v['label_ar'] ??
              v['labelAr'] ??
              v['name'] ??
              v['label'] ??
              '')
          .toString();
    } else {
      raw = (v ?? '').toString();
    }

    raw = raw.trim();
    if (raw.isEmpty) return '';

    raw = raw.split(RegExp(r'[,،\-]')).first.trim();
    return _normalizeCityAr(raw);
  }

  String _normalizeCityAr(String raw) {
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(raw);
    if (hasArabic) return raw;

    final k = raw.toLowerCase().trim();

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

    return map[k] ?? raw;
  }
}
