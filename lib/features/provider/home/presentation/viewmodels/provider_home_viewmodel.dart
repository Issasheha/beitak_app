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

  /// Raw bookings list (for future use / UI expand).
  List<ProviderBookingModel> allBookings = [];

  /// NEW Requests (status == pending_provider_accept)
  List<ProviderBookingModel> newRequests = [];

  /// A single task for today (UI shows one only).
  ProviderBookingModel? todayTask;

  /// Upcoming count (booking_date > today + scheduled statuses)
  int upcomingCount = 0;

  /// Total requests count (pending_provider_accept)
  int totalRequestsCount = 0;

  /// Convenience: show one preview request to avoid overflow.
  ProviderBookingModel? newRequestPreview;

  // ---------------- Texts ----------------

  String get headerTitle => 'لوحة التحكم';
  String get headerSubtitle =>
      'أهلًا بك من جديد يا $providerName! إليك لمحة عامة.';

  // ---------------- Policies ----------------

  static const String _pendingProviderAccept = 'pending_provider_accept';

  static const Set<String> _scheduledStatuses = {
    'confirmed',
    'provider_on_way',
    'provider_arrived',
    'in_progress',
  };

  // ---------------- Logging ----------------

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
    if (status == 401) {
      return 'انتهت الجلسة أو التوكن غير صالح. أعد تسجيل الدخول.';
    }
    if (status == 403) return 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';
    if (status == 404) return 'الطلب غير موجود أو تم حذفه.';
    if (status == 409) {
      return 'تعذر تنفيذ العملية بسبب تعارض بالحالة الحالية للطلب.';
    }
    if (status != null && status >= 500) {
      return 'مشكلة في السيرفر. حاول لاحقاً.';
    }
    return 'تعذر تنفيذ العملية. حاول مرة أخرى.';
  }

  // ---------------- Public API ----------------

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Get name (best-effort)
      await _resolveProviderNameIfPossible();

      final results = await Future.wait([
        _remote.getDashboardStats(),
        _remote.getMyBookings(limit: 60, sortBy: 'booking_date', order: 'ASC'),
      ]);

      stats = results[0] as ProviderStatsModel;
      allBookings = results[1] as List<ProviderBookingModel>;

      _computeDashboardFromBookings(allBookings);
    } on DioException catch (e) {
      _logDio('refresh', e);
      errorMessage = _friendlyErrorFromStatus(e.response?.statusCode);
    } catch (e) {
      _log('refresh error: $e');
      errorMessage =
          'تعذر تحميل البيانات. تأكد من تسجيل الدخول والاتصال بالإنترنت.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> accept(int bookingId) async {
    errorMessage = null;
    notifyListeners();

    try {
      await _remote.providerAction(bookingId: bookingId, action: 'accept');
      await refresh();
    } on DioException catch (e) {
      _logDio('accept($bookingId)', e);
      errorMessage = _friendlyErrorFromStatus(e.response?.statusCode);
      notifyListeners();
    } catch (e) {
      _log('accept($bookingId) error: $e');
      errorMessage = 'تعذر تنفيذ العملية. حاول مرة أخرى.';
      notifyListeners();
    }
  }

  Future<void> reject(int bookingId) async {
    errorMessage = null;
    notifyListeners();

    try {
      await _remote.providerAction(bookingId: bookingId, action: 'reject');
      await refresh();
    } on DioException catch (e) {
      _logDio('reject($bookingId)', e);
      errorMessage = _friendlyErrorFromStatus(e.response?.statusCode);
      notifyListeners();
    } catch (e) {
      _log('reject($bookingId) error: $e');
      errorMessage = 'تعذر تنفيذ العملية. حاول مرة أخرى.';
      notifyListeners();
    }
  }

  // ---------------- Internals ----------------

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
    } catch (_) {
      // ignore
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

  void _computeDashboardFromBookings(List<ProviderBookingModel> bookings) {
    // 1) NEW Requests
    newRequests =
        bookings.where((b) => b.status == _pendingProviderAccept).toList();
    newRequests.sort(_byDateThenTime);

    totalRequestsCount = newRequests.length;
    newRequestPreview = newRequests.isEmpty ? null : newRequests.first;

    // 2) Today Task (ONE)
    final today = _todayDateOnly();
    final todays = bookings.where((b) {
      final d = _parseDateOnly(b.bookingDate);
      if (d == null) return false;
      return _isSameDate(d, today) && _scheduledStatuses.contains(b.status);
    }).toList();

    todays.sort(_byDateThenTime);
    todayTask = todays.isEmpty ? null : todays.first;

    // 3) UPCOMING count: booking_date > today + scheduled statuses (exclude pending accept)
    final upcoming = bookings.where((b) {
      if (b.status == _pendingProviderAccept) return false;
      if (!_scheduledStatuses.contains(b.status)) return false;

      final d = _parseDateOnly(b.bookingDate);
      if (d == null) return false;
      return d.isAfter(today);
    }).toList();

    upcomingCount = upcoming.length;
  }

  static int _byDateThenTime(ProviderBookingModel a, ProviderBookingModel b) {
    final ad = _parseDateOnly(a.bookingDate);
    final bd = _parseDateOnly(b.bookingDate);

    if (ad != null && bd != null) {
      final cmp = ad.compareTo(bd);
      if (cmp != 0) return cmp;
    }

    // Compare time string (HH:mm:ss) lexicographically works if padded.
    final at = a.bookingTime;
    final bt = b.bookingTime;
    return at.compareTo(bt);
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
