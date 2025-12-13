import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/booking_result.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ServiceDetailsViewModel {
  final Dio _dio = ApiClient.dio;

  Future<ServiceDetails> fetchServiceDetails(int id) async {
    try {
      final res = await _dio.get(ApiConstants.serviceDetails(id));
      final map = _expectSuccessMap(res.data);
      return ServiceDetailsResponse.fromJson(map).service;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// GET /bookings/available-days/:providerId?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
  /// returns: { available_days: ["2025-12-01", ...] }
  Future<List<String>> fetchAvailableDays({
    required int providerId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.availableDays(providerId),
        queryParameters: {'startDate': startDate, 'endDate': endDate},
      );

      final data = res.data;
      if (data is Map) {
        final map = data.cast<String, dynamic>();
        final raw = map['available_days'];
        if (raw is List) {
          return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
        }
      }
      throw Exception('Invalid available_days response');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }


Future<void> sendBookingOtp({required String customerPhone}) async {
  final res = await _dio.post(
    ApiConstants.bookingsSendOtp,
    data: {'customer_phone': customerPhone},
    options: Options(
      // ✅ خلي Dio ما يرمي exception حتى لو 500
      validateStatus: (code) => true,
    ),
  );

  final code = res.statusCode ?? 0;

  // ✅ نجاح طبيعي
  if (code >= 200 && code < 300) return;

  // ✅ workaround: لو الباك اند ببعث OTP ثم بيرجع 500 (bug عندهم بعد الإرسال)
  if (code >= 500) {
    return; // اعتبرها نجاح عشان نفتح خطوة إدخال OTP
  }

  // ✅ أخطاء 4xx غالباً مشكلة ببيانات الطلب
  final data = res.data;
  if (data is Map) {
    final msg = (data['message'] ?? 'فشل إرسال OTP').toString();
    throw Exception(msg);
  }

  throw Exception('فشل إرسال OTP (status=$code)');
}


  Future<BookingResult> createBookingAsUser({
    required int serviceId,
    required int providerId,
    required String bookingDate,
    required String bookingTime,
    required double durationHours,
    required String serviceAddress,
    required String serviceCity,
    required String serviceArea,
    String? packageSelected,
    List<String>? addOnsSelected,
    String? customerNotes,
    double? latitude,
    double? longitude,
  }) async {
    final payload = _clean({
      'service_id': serviceId,
      'provider_id': providerId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'duration_hours': durationHours,
      'package_selected': packageSelected,
      'add_ons_selected': addOnsSelected ?? <String>[],
      'service_address': serviceAddress,
      'service_city': serviceCity,
      'service_area': serviceArea,
      'latitude': latitude,
      'longitude': longitude,
      'customer_notes': customerNotes,
    });

    try {
      final res = await _dio.post(ApiConstants.bookingsCreate, data: payload);
      final map = _expectSuccessMap(res.data);
      return BookingResult.fromJson(map);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<BookingResult> createBookingAsGuest({
    required int serviceId,
    required int providerId,
    required String bookingDate,
    required String bookingTime,
    required double durationHours,
    required String serviceAddress,
    required String serviceCity,
    required String serviceArea,
    required String customerName,
    required String customerPhone,
    required String otp,
    String? packageSelected,
    List<String>? addOnsSelected,
    String? customerNotes,
    String? customerEmail,
    double? latitude,
    double? longitude,
  }) async {
    final payload = _clean({
      'service_id': serviceId,
      'provider_id': providerId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'duration_hours': durationHours,
      'package_selected': packageSelected,
      'add_ons_selected': addOnsSelected ?? <String>[],
      'service_address': serviceAddress,
      'service_city': serviceCity,
      'service_area': serviceArea,
      'latitude': latitude,
      'longitude': longitude,
      'customer_notes': customerNotes,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'otp': otp,
    });

    try {
      final res = await _dio.post(ApiConstants.bookingsCreate, data: payload);
      final map = _expectSuccessMap(res.data);
      return BookingResult.fromJson(map);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  bool isOtpRequiredError(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('otp_required')) return true;
    if (text.contains('otp') && text.contains('required')) return true;

    return false;
  }

  Map<String, dynamic> _expectSuccessMap(dynamic raw) {
    if (raw is Map) {
      final map = raw.cast<String, dynamic>();
      if (map['success'] != true) {
        throw Exception((map['message'] ?? 'unknown_error').toString());
      }
      return map;
    }
    throw Exception('Invalid server response');
  }

  Map<String, dynamic> _clean(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      out[k] = v;
    });
    return out;
  }

  String _extractErrorMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        final map = data.cast<String, dynamic>();
        if (map['message'] != null) return map['message'].toString();

        // أشكال شائعة: errors: {field:[msg]}
        final errors = map['errors'];
        if (errors is Map) {
          final keys = errors.keys.map((k) => k.toString()).toList();
          return 'Missing required field: ${keys.join(', ')}';
        }

        final missing = map['missing_fields'];
        if (missing is List) {
          return 'Missing required field: ${missing.map((e) => e.toString()).join(', ')}';
        }
      }
    } catch (_) {}

    if (kDebugMode) {
      debugPrint('Dio error: status=${e.response?.statusCode} data=${e.response?.data}');
    }
    return 'Request failed (${e.response?.statusCode ?? ''})';
  }
}
