import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/booking_result.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message; // ✅ بدون "Exception:"
}

class ServiceDetailsViewModel {
  final Dio _dio = ApiClient.dio;

  Future<ServiceDetails> fetchServiceDetails(int id) async {
    try {
      final res = await _dio.get(
        ApiConstants.serviceDetails(id),
        options: Options(validateStatus: (_) => true),
      );

      final map = _asMap(res.data);
      if (map['success'] != true) {
        throw AppException(_readServerMessage(map));
      }

      return ServiceDetailsResponse.fromJson(map).service;
    } on DioException catch (e) {
      throw AppException(_extractErrorMessage(e));
    } catch (e) {
      throw AppException(_stripExceptionPrefix(e.toString()));
    }
  }

  /// GET /bookings/available-days/:providerId?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
  Future<List<String>> fetchAvailableDays({
    required int providerId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.availableDays(providerId),
        queryParameters: {'startDate': startDate, 'endDate': endDate},
        options: Options(validateStatus: (_) => true),
      );

      final map = _asMap(res.data);

      final root = (map['data'] is Map)
          ? (map['data'] as Map).cast<String, dynamic>()
          : map;

      final raw = root['available_days'] ?? root['available_dates'];
      if (raw is List) {
        return raw
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      if (map['success'] == false) {
        throw AppException(_readServerMessage(map));
      }

      throw AppException('استجابة غير متوقعة من السيرفر (available_days).');
    } on DioException catch (e) {
      throw AppException(_extractErrorMessage(e));
    } catch (e) {
      throw AppException(_stripExceptionPrefix(e.toString()));
    }
  }

  Future<void> sendBookingOtp({required String customerPhone}) async {
    try {
      final res = await _dio.post(
        ApiConstants.bookingsSendOtp,
        data: {'customer_phone': customerPhone},
        options: Options(validateStatus: (_) => true),
      );

      final map = _asMap(res.data);

      final code = res.statusCode ?? 0;
      if (code >= 200 && code < 300) return;

      if (code >= 500) return;

      throw AppException(
        _readServerMessage(map, fallback: 'فشل إرسال رمز التحقق (OTP).'),
      );
    } on DioException catch (e) {
      throw AppException(_extractErrorMessage(e));
    } catch (e) {
      throw AppException(_stripExceptionPrefix(e.toString()));
    }
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
      final res = await _dio.post(
        ApiConstants.bookingsCreate,
        data: payload,
        options: Options(validateStatus: (_) => true),
      );

      final map = _asMap(res.data);
      if (map['success'] != true) {
        throw AppException(_readServerMessage(map));
      }

      return BookingResult.fromJson(map);
    } on DioException catch (e) {
      throw AppException(_extractErrorMessage(e));
    } catch (e) {
      throw AppException(_stripExceptionPrefix(e.toString()));
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
      final res = await _dio.post(
        ApiConstants.bookingsCreate,
        data: payload,
        options: Options(validateStatus: (_) => true),
      );

      final map = _asMap(res.data);
      if (map['success'] != true) {
        throw AppException(_readServerMessage(map));
      }

      return BookingResult.fromJson(map);
    } on DioException catch (e) {
      throw AppException(_extractErrorMessage(e));
    } catch (e) {
      throw AppException(_stripExceptionPrefix(e.toString()));
    }
  }

  bool isOtpRequiredError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('otp_required')) return true;
    if (text.contains('otp') && text.contains('required')) return true;

    if (text.contains('رمز') && text.contains('تحقق')) return true;
    if (text.contains('otp') && text.contains('تحقق')) return true;

    return false;
  }

  // ----------------- Helpers -----------------

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) return raw.cast<String, dynamic>();
    return <String, dynamic>{
      'success': false,
      'message': 'invalid_server_response',
    };
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

  String _readServerMessage(Map<String, dynamic> map, {String? fallback}) {
    final msg = map['message']?.toString();
    if (msg != null && msg.trim().isNotEmpty) {
      return _localizeApiMessage(msg.trim());
    }

    final errors = map['errors'];
    if (errors is Map) {
      final keys = errors.keys.map((k) => k.toString()).toList();
      return 'حقول ناقصة: ${keys.join(', ')}';
    }

    final missing = map['missing_fields'];
    if (missing is List) {
      return 'حقول ناقصة: ${missing.map((e) => e.toString()).join(', ')}';
    }

    return fallback ?? 'تعذر إتمام العملية، حاول مرة أخرى.';
  }

  String _localizeApiMessage(String m) {
    final key = m.trim().toLowerCase();

    switch (key) {
      case 'day_not_available':
        return 'هذا اليوم غير متاح للحجز لأن مزوّد الخدمة لديه حجز في نفس اليوم.';
      case 'time_not_available':
        return 'هذا الوقت غير متاح، اختر وقتاً آخر.';
      case 'provider_not_available':
        return 'مزود الخدمة غير متاح حالياً.';
      case 'otp_required':
      case 'otp_required_for_guest':
        return 'لازم تحقق رقم الهاتف (OTP) لإكمال الحجز.';
      case 'invalid_otp':
        return 'رمز التحقق غير صحيح.';
      case 'service_not_found':
        return 'الخدمة غير موجودة.';
      case 'provider_not_found':
        return 'مزود الخدمة غير موجود.';
      case 'route not found':
        return 'المسار غير موجود على السيرفر.';
      case 'invalid_server_response':
        return 'استجابة غير صالحة من السيرفر.';
      default:
        return m;
    }
  }

  String _extractErrorMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        final map = data.cast<String, dynamic>();
        return _readServerMessage(
          map,
          fallback: 'فشل الطلب (${e.response?.statusCode ?? ''}).',
        );
      }
    } catch (_) {}

    if (kDebugMode) {
      debugPrint(
        'Dio error: type=${e.type} status=${e.response?.statusCode} data=${e.response?.data}',
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'انتهت مهلة الاتصال، حاول مرة أخرى.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالسيرفر، تأكد من الإنترنت.';
    }

    return 'حدث خطأ غير متوقع.';
  }

  String _stripExceptionPrefix(String s) {
    return s.replaceFirst(RegExp(r'^\s*exception:\s*', caseSensitive: false), '').trim();
  }
}
