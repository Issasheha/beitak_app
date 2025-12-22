import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'package:beitak_app/features/provider/home/data/datasources/provider_dashboard_remote_datasource.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_stats_model.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';

class ProviderHomeViewModel extends ChangeNotifier {
  final ProviderDashboardRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  ProviderHomeViewModel({
    ProviderDashboardRemoteDataSource? remote,
    AuthLocalDataSource? local,
    String? initialName,
  })  : _remote = remote ?? ProviderDashboardRemoteDataSource(),
        _local = local ?? AuthLocalDataSourceImpl(),
        providerName = initialName ?? 'مزود الخدمة';

  bool isLoading = false;
  String? errorMessage;

  String providerName;

  ProviderStatsModel stats = ProviderStatsModel.empty;

  List<ProviderBookingModel> allBookings = [];
  List<ProviderBookingModel> newRequests = [];
  ProviderBookingModel? todayTask;

  int upcomingCount = 0;
  int totalRequestsCount = 0;
  ProviderBookingModel? newRequestPreview;

  String get headerTitle => 'لوحة التحكم';
  String get headerSubtitle => 'أهلًا بك من جديد يا $providerName! إليك لمحة عامة.';

  double get totalEarnings => stats.totalEarnings;
  int get completedCount => stats.completedBookings;

  double? get thisWeekEarnings => null;
  double? get monthChangePct => null;

  static const String _pendingProviderAccept = 'pending_provider_accept';

  static const Set<String> _scheduledStatuses = {
    'confirmed',
    'provider_on_way',
    'provider_arrived',
    'in_progress',
  };

  bool _refreshing = false;

  // =========================
  // ✅ NEW: name helpers
  // =========================

  /// ✅ تحديث الاسم فوراً (ليظهر في الهيدر مباشرة)
  void setProviderName(String name) {
    final cleaned = name.trim();
    final finalName = cleaned.isEmpty ? 'مزود الخدمة' : cleaned;

    if (providerName == finalName) return;
    providerName = finalName;
    notifyListeners();
  }

  /// ✅ سحب الاسم من الكاش (SharedPrefs) وتحديثه
  /// notify=false مفيد أثناء refresh لتجنب نداءات كثيرة
  Future<void> syncProviderNameFromCache({bool notify = true}) async {
    try {
      final session = await _local.getCachedAuthSession();
      if (session == null) return;

      final dynamic user = (session as dynamic).user ?? session;

      final String fn = ((user as dynamic).firstName ??
              (user as dynamic).first_name ??
              (user as dynamic).first ??
              '')
          .toString()
          .trim();

      final String ln = (((user as dynamic).lastName ??
              (user as dynamic).last_name ??
              (user as dynamic).last ??
              '') as dynamic)
          .toString()
          .trim();

      final full = ('$fn $ln').trim();
      if (full.isEmpty) return;

      if (providerName != full) {
        providerName = full;
        if (notify) notifyListeners();
      }
    } catch (_) {}
  }

  void _log(String msg) {
    debugPrint('[ProviderHomeVM] $msg');
  }

  void _logDio(String tag, DioException e) {
    final req = e.requestOptions;
    _log('--- DIO ERROR ($tag) ---');
    _log('METHOD: ${req.method}');
    _log('PATH:   ${req.path}');
    _log('QUERY:  ${req.queryParameters}');
    _log('BODY:   ${req.data}');
    _log('STATUS: ${e.response?.statusCode}');
    _log('RESP:   ${e.response?.data}');
    _log('MSG:    ${e.message}');
    _log('TYPE:   ${e.type}');
    _log('------------------------');
  }

  String _friendlyErrorFromStatus(int? status) {
    if (status == 401) return 'انتهت الجلسة أو التوكن غير صالح. أعد تسجيل الدخول.';
    if (status == 403) return 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';
    if (status == 404) return 'الطلب غير موجود أو تم حذفه.';
    if (status == 409) return 'تعذر تنفيذ العملية بسبب تعارض بالحالة الحالية للطلب.';
    if (status != null && status >= 500) return 'مشكلة في السيرفر. حاول لاحقاً.';
    return 'تعذر تنفيذ العملية. حاول مرة أخرى.';
  }

  /// ✅ Refresh يدعم silent polling
  /// - silent=false: يطلع loading طبيعي
  /// - silent=true : بدون ما يغير isLoading (ولا يعمل flicker)
  Future<void> refresh({bool silent = false}) async {
    if (_refreshing) return;
    _refreshing = true;

    final bool hadDataBefore = _hasAnyDashboardData();

    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    String? statsErr;
    String? bookingsErr;

    bool statsOk = false;
    bool bookingsOk = false;

    try {
      // ✅ بدل _resolveProviderNameIfPossible
      await syncProviderNameFromCache(notify: false);

      // --- Stats ---
      try {
        stats = await _remote.getDashboardStats();
        statsOk = true;
      } on DioException catch (e) {
        _logDio('getDashboardStats', e);
        statsErr = _friendlyErrorFromStatus(e.response?.statusCode);
      } catch (e) {
        _log('getDashboardStats error: $e');
        statsErr = 'تعذر تحميل الإحصائيات حالياً.';
      }

      // --- Bookings ---
      try {
        allBookings = await _remote.getMyBookings(
          limit: 60,
          sortBy: 'booking_date',
          order: 'ASC',
        );
        _computeDashboardFromBookings(allBookings);
        bookingsOk = true;
      } on DioException catch (e) {
        _logDio('getMyBookings', e);
        bookingsErr = _friendlyErrorFromStatus(e.response?.statusCode);
      } catch (e) {
        _log('getMyBookings error: $e');
        bookingsErr = 'تعذر تحميل الحجوزات حالياً.';
      }

      // --- Error message policy ---
      if (!silent) {
        if (statsErr != null && bookingsErr != null) {
          errorMessage =
              'تعذر تحميل بيانات لوحة التحكم. تأكد من الاتصال بالإنترنت وحاول مرة أخرى.';
        } else if (statsErr != null) {
          errorMessage = 'تعذر تحميل الإحصائيات حالياً.';
        } else if (bookingsErr != null) {
          errorMessage = 'تعذر تحميل الحجوزات حالياً.';
        } else {
          errorMessage = null;
        }
      } else {
        // ✅ Silent: لا تزعج المستخدم بأخطاء أثناء polling
        final anyOk = statsOk || bookingsOk;
        if (anyOk) errorMessage = null;

        if (!hadDataBefore && !anyOk) {
          // keep as is
        }
      }
    } finally {
      if (!silent) {
        isLoading = false;
      }
      _refreshing = false;
      notifyListeners();
    }
  }

  bool _hasAnyDashboardData() {
    return allBookings.isNotEmpty ||
        totalRequestsCount > 0 ||
        upcomingCount > 0 ||
        completedCount > 0 ||
        totalEarnings > 0;
  }

  // ✅ Accept: local same-day rule + no longer available handling
  Future<void> accept(int bookingId) async {
    errorMessage = null;
    notifyListeners();

    final target = _findBookingById(bookingId);
    if (target != null && _violatesSameDayRule(target)) {
      errorMessage = 'لا يمكنك قبول هذا الطلب لأن لديك حجزاً مجدولاً في نفس اليوم.';
      notifyListeners();
      return;
    }

    try {
      await _remote.providerAction(bookingId: bookingId, action: 'accept');
      await refresh();
    } on DioException catch (e) {
      _logDio('accept($bookingId)', e);

      final status = e.response?.statusCode;

      if (status == 404 || status == 409) {
        errorMessage = 'هذا الطلب لم يعد متاحاً. تم تحديث القائمة.';
        notifyListeners();
        await refresh();
        return;
      }

      errorMessage = _friendlyErrorFromStatus(status);
      notifyListeners();
    } catch (e) {
      _log('accept($bookingId) error: $e');
      errorMessage = 'تعذر تنفيذ العملية. حاول مرة أخرى.';
      notifyListeners();
    }
  }

  // ✅ Reject: no longer available handling
  Future<void> reject(int bookingId) async {
    errorMessage = null;
    notifyListeners();

    try {
      await _remote.providerAction(bookingId: bookingId, action: 'reject');
      await refresh();
    } on DioException catch (e) {
      _logDio('reject($bookingId)', e);

      final status = e.response?.statusCode;

      if (status == 404 || status == 409) {
        errorMessage = 'هذا الطلب لم يعد متاحاً. تم تحديث القائمة.';
        notifyListeners();
        await refresh();
        return;
      }

      errorMessage = _friendlyErrorFromStatus(status);
      notifyListeners();
    } catch (e) {
      _log('reject($bookingId) error: $e');
      errorMessage = 'تعذر تنفيذ العملية. حاول مرة أخرى.';
      notifyListeners();
    }
  }

  Future<void> complete(int bookingId) async {
    errorMessage = null;
    notifyListeners();

    try {
      await _remote.providerComplete(bookingId);
      await refresh();
    } on DioException catch (e) {
      _logDio('complete($bookingId)', e);
      errorMessage = _friendlyErrorFromStatus(e.response?.statusCode);
      notifyListeners();
    } catch (e) {
      _log('complete($bookingId) error: $e');
      errorMessage = 'تعذر تنفيذ العملية. حاول مرة أخرى.';
      notifyListeners();
    }
  }

  Future<void> cancel({
    required int bookingId,
    required String cancellationCategory,
    String? cancellationReason,
  }) async {
    errorMessage = null;
    notifyListeners();

    try {
      await _remote.providerCancel(
        bookingId: bookingId,
        cancellationCategory: cancellationCategory,
        cancellationReason: cancellationReason,
      );
      await refresh();
    } on DioException catch (e) {
      _logDio('cancel($bookingId)', e);
      errorMessage = _friendlyErrorFromStatus(e.response?.statusCode);
      notifyListeners();
    } catch (e) {
      _log('cancel($bookingId) error: $e');
      errorMessage = 'تعذر تنفيذ العملية. حاول مرة أخرى.';
      notifyListeners();
    }
  }

  // (قديم) صار مش مستخدم — تقدر تحذفه لاحقاً
  Future<void> _resolveProviderNameIfPossible() async {
    try {
      final session = await _local.getCachedAuthSession();
      if (session == null) return;

      final dynamic user = (session as dynamic).user ?? session;

      final String fn = ((user as dynamic).firstName ??
              (user as dynamic).first_name ??
              (user as dynamic).first ??
              '')
          .toString()
          .trim();

      final String ln = (((user as dynamic).lastName ??
              (user as dynamic).last_name ??
              (user as dynamic).last ??
              '') as dynamic)
          .toString()
          .trim();

      final full = ('$fn $ln').trim();
      if (full.isNotEmpty) providerName = full;
    } catch (_) {}
  }

  void _computeDashboardFromBookings(List<ProviderBookingModel> bookings) {
    newRequests =
        bookings.where((b) => b.status == _pendingProviderAccept).toList();
    newRequests.sort(_byDateThenTime);

    totalRequestsCount = newRequests.length;
    newRequestPreview = newRequests.isEmpty ? null : newRequests.first;

    final today = _todayDateOnly();
    final todays = bookings.where((b) {
      final d = _parseDateOnly(b.bookingDate);
      if (d == null) return false;
      return _isSameDate(d, today) && _scheduledStatuses.contains(b.status);
    }).toList();

    todays.sort(_byDateThenTime);
    todayTask = todays.isEmpty ? null : todays.first;

    final upcoming = bookings.where((b) {
      if (b.status == _pendingProviderAccept) return false;
      if (!_scheduledStatuses.contains(b.status)) return false;

      final d = _parseDateOnly(b.bookingDate);
      if (d == null) return false;
      return d.isAfter(today);
    }).toList();

    upcomingCount = upcoming.length;
  }

  ProviderBookingModel? _findBookingById(int bookingId) {
    try {
      return allBookings.firstWhere((b) => b.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  bool _violatesSameDayRule(ProviderBookingModel pending) {
    if (pending.status != _pendingProviderAccept) return false;

    final targetDate = _parseDateOnly(pending.bookingDate);
    if (targetDate == null) return false;

    for (final b in allBookings) {
      if (b.id == pending.id) continue;
      if (!_scheduledStatuses.contains(b.status)) continue;

      final d = _parseDateOnly(b.bookingDate);
      if (d == null) continue;

      if (_isSameDate(d, targetDate)) return true;
    }
    return false;
  }

  static int _byDateThenTime(ProviderBookingModel a, ProviderBookingModel b) {
    final ad = _parseDateOnly(a.bookingDate);
    final bd = _parseDateOnly(b.bookingDate);

    if (ad != null && bd != null) {
      final cmp = ad.compareTo(bd);
      if (cmp != 0) return cmp;
    }

    return a.bookingTime.compareTo(b.bookingTime);
  }

  static DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime? _parseDateOnly(String ymd) {
    final s = ymd.trim();
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s);
    if (dt == null) return null;
    return DateTime(dt.year, dt.month, dt.day);
  }

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
