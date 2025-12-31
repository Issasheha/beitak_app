import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:beitak_app/features/provider/home/data/datasources/provider_dashboard_remote_datasource.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';

enum ProviderBrowseTab { pending, upcoming }

class ProviderBrowseViewModel extends ChangeNotifier {
  final ProviderDashboardRemoteDataSource _remote;

  ProviderBrowseViewModel({
    ProviderDashboardRemoteDataSource? remote,
  }) : _remote = remote ?? ProviderDashboardRemoteDataSource();

  bool isLoading = false;
  String? errorMessage;

  ProviderBrowseTab tab = ProviderBrowseTab.pending;

  List<ProviderBookingModel> _all = const [];
  List<ProviderBookingModel> get all => _all;

  final Set<int> _busyIds = <int>{};
  bool isBusy(int bookingId) => _busyIds.contains(bookingId);

  static const String _pendingProviderAccept = 'pending_provider_accept';

  static const Set<String> _scheduledLikeStatuses = {
    'confirmed',
    'provider_on_way',
    'provider_arrived',
    'in_progress',
  };

  // ✅ طلبات جديدة بانتظار قبولك
  List<ProviderBookingModel> get pendingBookings =>
      _all.where((b) => b.status == _pendingProviderAccept).toList();

  // ✅ الخدمات القادمة = مقبولة/مجدولة + تاريخها بعد اليوم (حتى ما تتداخل مع مهمة اليوم)
  List<ProviderBookingModel> get upcomingBookings {
    final today = _todayDateOnly();
    return _all.where((b) {
      final d = _parseDateOnly(b.bookingDate);
      if (d == null) return false;
      final isFuture = d.isAfter(today);
      return isFuture && _scheduledLikeStatuses.contains(b.status);
    }).toList();
  }

  List<ProviderBookingModel> get visibleBookings =>
      tab == ProviderBrowseTab.pending ? pendingBookings : upcomingBookings;

  int get pendingCount => pendingBookings.length;
  int get upcomingCount => upcomingBookings.length;

  void setTab(ProviderBrowseTab t) {
    if (tab == t) return;
    tab = t;
    notifyListeners();
  }

  String _friendlyErrorFromStatus(int? status) {
    if (status == 401) return 'انتهت الجلسة أو التوكن غير صالح. أعد تسجيل الدخول.';
    if (status == 403) return 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';
    if (status == 404) return 'الطلب غير موجود أو تم حذفه.';
    if (status == 409) return 'لا يمكن تنفيذ العملية بسبب تعارض في حالة الطلب.';
    if (status != null && status >= 500) return 'مشكلة في السيرفر. حاول لاحقاً.';
    return 'تعذر تنفيذ العملية. حاول مرة أخرى.';
  }

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final bookings = await _remote.getMyBookings(
        page: 1,
        limit: 200,
        sortBy: 'booking_date',
        order: 'ASC',
      );

      _all = bookings;
    } on DioException catch (e) {
      errorMessage = _friendlyErrorFromStatus(e.response?.statusCode);
    } catch (_) {
      errorMessage = 'تعذر تحميل الحجوزات. تأكد من تسجيل الدخول والاتصال بالإنترنت.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Pending: قبول عبر provider-action
  Future<void> accept(int bookingId) async {
    await _runAction(
      bookingId,
      () => _remote.providerAction(bookingId: bookingId, action: 'accept'),
    );
  }

  /// ✅ Pending: "إلغاء" (UI) لكنه فعلياً reject عبر provider-action
  /// والباك يرجع status=cancelled => بطاقة السجل بتعرضها "ملغاة"
  Future<void> reject(int bookingId) async {
    await _runAction(
      bookingId,
      () => _remote.providerAction(bookingId: bookingId, action: 'reject'),
    );
  }

  /// ✅ Upcoming: إنهاء
  Future<void> complete(int bookingId) async {
    await _runAction(
      bookingId,
      () => _remote.providerComplete(bookingId),
    );
  }

  /// ✅ Upcoming: إلغاء (provider-cancel القديم + الأسباب)
  Future<void> cancel({
    required int bookingId,
    required String cancellationCategory,
    String? cancellationReason,
  }) async {
    await _runAction(
      bookingId,
      () => _remote.providerCancel(
        bookingId: bookingId,
        cancellationCategory: cancellationCategory,
        cancellationReason: cancellationReason,
      ),
    );
  }

  Future<void> _runAction(int bookingId, Future<void> Function() fn) async {
    if (_busyIds.contains(bookingId)) return;

    errorMessage = null;
    _busyIds.add(bookingId);
    notifyListeners();

    try {
      await fn();
      await refresh();
    } on DioException catch (e) {
      errorMessage = _friendlyErrorFromStatus(e.response?.statusCode);
      notifyListeners();
    } catch (_) {
      errorMessage = 'تعذر تنفيذ العملية. حاول مرة أخرى.';
      notifyListeners();
    } finally {
      _busyIds.remove(bookingId);
      notifyListeners();
    }
  }

  static DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime? _parseDateOnly(String isoDate) {
    final d = DateTime.tryParse(isoDate.trim()); // expected YYYY-MM-DD
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day);
  }
}
