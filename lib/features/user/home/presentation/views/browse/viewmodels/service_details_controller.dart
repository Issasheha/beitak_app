import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';

import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/service_details_viewmodel.dart';
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

      // safety: لو كان مختار باقة وانحذفت لاحقًا
      final selectedName = state.selectedPackageName;
      final keepSelected = selectedName != null &&
          s.packages.any((p) => p.name.trim() == selectedName.trim());

      state = state.copyWith(
        service: s,
        loading: false,
        selectedPackageName: keepSelected ? selectedName : null,
        selectedDate: _todayDateOnly().add(const Duration(days: 1)),
      );

      await loadProfileAndLocations();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadProfileAndLocations() async {
    state = state.copyWith(locLoading: true);

    try {
      // 1) profile location
      final profileRes = await _getAny([ApiConstants.userProfile, '/api/users/profile', '/api/users/me']);
      final profileLoc = _parseProfileLoc(profileRes.data);

      // 2) cities
      final citiesRes = await _getAny([ApiConstants.cities, '/api/locations/cities']);
      final cities = _parseCities(citiesRes.data);

      // 3) choose city (locked > profile > fallback)
      CityOption? selectedCity;
      if (lockedCityId != null) {
        selectedCity = _firstWhereOrNull(cities, (c) => c.id == lockedCityId);
      } else if (profileLoc?.cityId != null) {
        selectedCity = _firstWhereOrNull(cities, (c) => c.id == profileLoc!.cityId);
      }

      selectedCity ??= _firstWhereOrNull(
        cities,
        (c) => (c.slug ?? '').toLowerCase().trim() == 'amman',
      );
      selectedCity ??= cities.isNotEmpty ? cities.first : null;

      // 4) areas
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
    state = state.copyWith(selectedDate: DateTime(dateOnly.year, dateOnly.month, dateOnly.day));
  }

  void setSelectedPackageName(String? name) {
    state = state.copyWith(selectedPackageName: name);
  }

  void setSelectedArea(AreaOption? area) {
    state = state.copyWith(selectedArea: area);
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

  // ===== Booking wrappers (بدون UI) =====

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

      state = state.copyWith(bookingLoading: false);
    } catch (e) {
      state = state.copyWith(bookingLoading: false, bookingError: e.toString());
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
  }

  bool isOtpRequiredError(Object e) => _vm.isOtpRequiredError(e);

  // ===== Helpers =====

  DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<Response> _getAny(List<String> paths) async {
    DioException? lastDio;
    for (final p in paths) {
      try {
        return await _dio.get(p);
      } on DioException catch (e) {
        lastDio = e;
        if (kDebugMode) debugPrint('GET failed: $p -> ${e.response?.statusCode}');
      }
    }
    throw Exception(lastDio?.message ?? 'Request failed');
  }

  UserLocationProfile? _parseProfileLoc(dynamic data) {
    try {
      if (data is Map) {
        final m = data.cast<String, dynamic>();
        final root = (m['data'] is Map) ? (m['data'] as Map).cast<String, dynamic>() : m;
        final user = (root['user'] is Map) ? (root['user'] as Map).cast<String, dynamic>() : root;
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

  List<Map<String, dynamic>> _extractList(
    dynamic data, {
    required List<String> keys,
  }) {
    if (data is List) {
      return data.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }

    if (data is Map) {
      final m = data.cast<String, dynamic>();

      // success wrapper
      final root = (m['data'] is Map) ? (m['data'] as Map).cast<String, dynamic>() : m;

      for (final k in keys) {
        final v = root[k];
        if (v is List) {
          return v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
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
