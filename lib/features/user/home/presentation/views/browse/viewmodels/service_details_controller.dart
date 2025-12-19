import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/service_details_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../widgets_service_details/location_models.dart';
import 'service_details_state.dart';

class ServiceDetailsController extends StateNotifier<ServiceDetailsState> {
  ServiceDetailsController({
    required this.serviceId,
    required this.lockedCityId,
  }) : super(ServiceDetailsState.initial());

  final int serviceId;
  final int? lockedCityId;

  final ServiceDetailsViewModel _vm = ServiceDetailsViewModel();
  final Dio _dio = ApiClient.dio;

  Future<void> loadAll() async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final s = await _vm.fetchServiceDetails(serviceId);

      final selectedName = state.selectedPackageName;
      final keepSelected = selectedName != null &&
          s.packages.any((p) => p.name.trim() == selectedName.trim());

      state = state.copyWith(
        service: s,
        loading: false,
        selectedPackageName: keepSelected ? selectedName : null,
      );

      await _loadAvailabilityDates(providerId: s.providerId);

      final firstBookable = _firstBookableDate(s, state.availableDates);
      state = state.copyWith(selectedDate: firstBookable);

      await loadProfileAndLocations();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: _humanizeError(e),
      );
    }
  }

  Future<void> refreshAvailabilityDays() async {
    final s = state.service;
    if (s == null) return;
    await _loadAvailabilityDates(providerId: s.providerId);
  }

  Future<void> _loadAvailabilityDates({required int providerId}) async {
    state = state.copyWith(availabilityLoading: true);

    final start = _fmtDate(_todayDateOnly().add(const Duration(days: 1)));
    final end = _fmtDate(_todayDateOnly().add(const Duration(days: 60)));

    try {
      final dates = await _vm.fetchAvailableDays(
        providerId: providerId,
        startDate: start,
        endDate: end,
      );

      if (!mounted) return;

      final cleaned = dates
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      state = state.copyWith(
        availabilityLoading: false,
        availableDates: cleaned,
      );

      // ✅ لو التاريخ المختار صار غير موجود (انحجز/تسكر) انقله لأول يوم متاح
      final s = state.service;
      final sel = state.selectedDate;
      if (s != null && sel != null && cleaned.isNotEmpty) {
        final selStr = _fmtDate(sel);
        if (!cleaned.contains(selStr)) {
          state = state.copyWith(selectedDate: _firstBookableDate(s, cleaned));
        }
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        availabilityLoading: false,
        availableDates: const [],
      );
      if (kDebugMode) debugPrint('availability load failed: $e');
    }
  }

  // ===== locations/profile (كما عندك) =====

  Future<void> loadProfileAndLocations() async {
    state = state.copyWith(locLoading: true);

    try {
      final profileRes = await _getAny([
        ApiConstants.userProfile,
        '/api/users/profile',
        '/api/users/me',
      ]);
      final profileLoc = _parseProfileLoc(profileRes.data);

      final citiesRes = await _getAny([
        ApiConstants.cities,
        '/api/locations/cities',
      ]);
      final cities = _parseCities(citiesRes.data);

      CityOption? selectedCity;
      if (lockedCityId != null) {
        selectedCity = _firstWhereOrNull(cities, (c) => c.id == lockedCityId);
      } else if (profileLoc?.cityId != null) {
        selectedCity =
            _firstWhereOrNull(cities, (c) => c.id == profileLoc!.cityId);
      }

      selectedCity ??= _firstWhereOrNull(
        cities,
        (c) => (c.slug ?? '').toLowerCase().trim() == 'amman',
      );
      selectedCity ??= cities.isNotEmpty ? cities.first : null;

      List<AreaOption> areas = const [];
      AreaOption? selectedArea;

      if (selectedCity != null) {
        final areasRes = await _getAny([
          '${ApiConstants.areasByCity}/${selectedCity.slug}',
        ]);
        areas = _parseAreas(areasRes.data);

        if (profileLoc?.areaId != null && areas.isNotEmpty) {
          selectedArea = _firstWhereOrNull(
            areas,
            (a) => a.id == profileLoc!.areaId,
          );
        }
        selectedArea ??= areas.isNotEmpty ? areas.first : null;
      }

      if (!mounted) return;
      state = state.copyWith(
        profileLoc: profileLoc,
        cities: cities,
        selectedCity: selectedCity,
        areas: areas,
        selectedArea: selectedArea,
        locLoading: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(locLoading: false);
    }
  }

  void setSelectedDate(DateTime dateOnly) {
    state = state.copyWith(
      selectedDate: DateTime(dateOnly.year, dateOnly.month, dateOnly.day),
      clearBookingError: true,
    );
  }

  void setSelectedPackageName(String? name) {
    state = state.copyWith(selectedPackageName: name, clearBookingError: true);
  }

  void setSelectedArea(AreaOption? area) {
    state = state.copyWith(selectedArea: area, clearBookingError: true);
  }

  double calcDisplayedPrice() {
    final s = state.service;
    if (s == null) return 0;

    double price = s.basePrice;
    final pkg = state.selectedPackage;
    if (pkg != null) price = pkg.price;

    final isHourly = (s.priceType.toLowerCase().trim() == 'hourly');
    if (isHourly) {
      final hrs = s.durationHours <= 0 ? 1.0 : s.durationHours;
      price = price * hrs;
    }
    return price;
  }

  Future<void> createBookingAsUser({
    required String bookingDate,
    required String bookingTime,
    required double durationHours,
    required String serviceCity,
    required String serviceArea,
    required String? notes,
  }) async {
    final s = state.service;
    if (s == null) return;

    state = state.copyWith(bookingLoading: true, clearBookingError: true);

    try {
      await _vm.createBookingAsUser(
        serviceId: s.id,
        providerId: s.providerId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        durationHours: durationHours,
        serviceAddress: 'N/A',
        serviceCity: serviceCity,
        serviceArea: serviceArea,
        packageSelected: state.selectedPackageName,
        addOnsSelected: const [],
        customerNotes: notes,
      );

      // ✅ 1) Optimistic: سكّر اليوم فوراً بالـ UI (بدون انتظار الريفريش)
      _optimisticallyCloseDay(bookingDate, s);

      state = state.copyWith(bookingLoading: false);

      // ✅ 2) Refresh فعلي من السيرفر لتأكيد التواريخ
      await _loadAvailabilityDates(providerId: s.providerId);
    } catch (e) {
      state = state.copyWith(
        bookingLoading: false,
        bookingError: _humanizeError(e),
      );
      rethrow;
    }
  }

  Future<void> sendBookingOtp({required String customerPhone}) async {
    await _vm.sendBookingOtp(customerPhone: customerPhone);
  }

  Future<void> createBookingAsGuest({
    required String bookingDate,
    required String bookingTime,
    required double durationHours,
    required String serviceCity,
    required String serviceArea,
    required String customerName,
    required String customerPhone,
    required String otp,
    required String? notes,
  }) async {
    final s = state.service;
    if (s == null) return;

    state = state.copyWith(bookingLoading: true, clearBookingError: true);

    try {
      await _vm.createBookingAsGuest(
        serviceId: s.id,
        providerId: s.providerId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        durationHours: durationHours,
        serviceAddress: 'N/A',
        serviceCity: serviceCity,
        serviceArea: serviceArea,
        customerName: customerName,
        customerPhone: customerPhone,
        otp: otp,
        packageSelected: state.selectedPackageName,
        addOnsSelected: const [],
        customerNotes: notes,
      );

      _optimisticallyCloseDay(bookingDate, s);

      state = state.copyWith(bookingLoading: false);

      await _loadAvailabilityDates(providerId: s.providerId);
    } catch (e) {
      state = state.copyWith(
        bookingLoading: false,
        bookingError: _humanizeError(e),
      );
      rethrow;
    }
  }

  bool isOtpRequiredError(Object e) => _vm.isOtpRequiredError(e);

  // ===== UX Helpers =====

  void _optimisticallyCloseDay(String bookingDate, ServiceDetails s) {
    final date = bookingDate.trim();
    if (date.isEmpty) return;

    // لو القائمة فاضية ما بنخرب شي، الريفريش رح يعبيها
    if (state.availableDates.isNotEmpty) {
      final set = state.availableDates
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
      if (set.remove(date)) {
        final updated = set.toList()..sort();
        state = state.copyWith(availableDates: updated);
      }
    }

    // لو كان المستخدم مختار نفس اليوم: انقله لأول يوم متاح
    final sel = state.selectedDate;
    if (sel != null && _fmtDate(sel) == date) {
      final next = _firstBookableDate(s, state.availableDates);
      state = state.copyWith(selectedDate: next);
    }
  }

  String _humanizeError(Object e) {
    final s = e.toString().trim();
    // ✅ إزالة "Exception:" نهائياً
    return s
        .replaceFirst(RegExp(r'^\s*exception:\s*', caseSensitive: false), '')
        .trim();
  }

  // ===== Helpers =====

  DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _firstBookableDate(ServiceDetails s, List<String> availableDates) {
    final start = _todayDateOnly().add(const Duration(days: 1));
    final end = _todayDateOnly().add(const Duration(days: 60));

    if (availableDates.isNotEmpty) {
      DateTime? best;
      for (final str in availableDates) {
        try {
          final d = DateTime.parse(str);
          final dateOnly = DateTime(d.year, d.month, d.day);
          if (dateOnly.isBefore(start) || dateOnly.isAfter(end)) continue;
          best ??= dateOnly;
          if (dateOnly.isBefore(best!)) best = dateOnly;
        } catch (_) {}
      }
      if (best != null) return best!;
    }

    final allow =
        s.provider.availableDays.map((e) => e.toLowerCase().trim()).toSet();
    DateTime cur = start;
    while (!cur.isAfter(end)) {
      final key = _weekdayKey(cur);
      if (allow.contains(key)) return cur;
      cur = cur.add(const Duration(days: 1));
    }
    return start;
  }

  String _weekdayKey(DateTime d) {
    switch (d.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
      default:
        return 'sunday';
    }
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<Response> _getAny(List<String> paths) async {
    DioException? lastDio;
    for (final p in paths) {
      try {
        return await _dio.get(p);
      } on DioException catch (e) {
        lastDio = e;
        if (kDebugMode)
          debugPrint('GET failed: $p -> ${e.response?.statusCode}');
      }
    }
    throw Exception(
      'تعذر جلب البيانات من السيرفر. حاول مرة أخرى.',
    );
  }

  UserLocationProfile? _parseProfileLoc(dynamic data) {
    try {
      if (data is Map) {
        final m = data.cast<String, dynamic>();
        final root =
            (m['data'] is Map) ? (m['data'] as Map).cast<String, dynamic>() : m;
        final user = (root['user'] is Map)
            ? (root['user'] as Map).cast<String, dynamic>()
            : root;
        final loc = (user['location'] is Map)
            ? (user['location'] as Map).cast<String, dynamic>()
            : (root['location'] is Map)
                ? (root['location'] as Map).cast<String, dynamic>()
                : null;
        if (loc == null) return null;
        return UserLocationProfile.fromJson(loc);
      }
    } catch (_) {}
    return null;
  }

  List<CityOption> _parseCities(dynamic data) {
    final list = _extractList(data, keys: const ['cities', 'data', 'items']);
    return list.map((e) => CityOption.fromJson(e)).toList();
  }

  List<AreaOption> _parseAreas(dynamic data) {
    final list = _extractList(data, keys: const ['areas', 'data', 'items']);
    return list.map((e) => AreaOption.fromJson(e)).toList();
  }

  List<Map<String, dynamic>> _extractList(dynamic data,
      {required List<String> keys}) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    if (data is Map) {
      final m = data.cast<String, dynamic>();
      final root =
          (m['data'] is Map) ? (m['data'] as Map).cast<String, dynamic>() : m;
      for (final k in keys) {
        final v = root[k];
        if (v is List) {
          return v
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();
        }
      }
    }
    return const [];
  }

  T? _firstWhereOrNull<T>(List<T> list, bool Function(T) test) {
    for (final x in list) {
      if (test(x)) return x;
    }
    return null;
  }
}
