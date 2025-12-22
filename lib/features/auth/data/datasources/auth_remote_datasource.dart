import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> loginWithIdentifier({
    required String identifier,
    required String password,
  });

  Future<AuthSessionModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required int cityId,
    required int areaId,
    required String role,
  });

  Future<void> sendResetCode({
    required String phone,
  });

  Future<void> verifyResetCode({
    required String phone,
    required String code,
  });

  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  // ✅ دعم الأرقام العربية/الفارسية (احتياط + مفيد)
  String _normalizeArabicDigits(String input) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) {
      input = input.replaceAll(ar[i], en[i]);
    }
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < fa.length; i++) {
      input = input.replaceAll(fa[i], en[i]);
    }
    return input;
  }

  String _mapAuthMessage(String msg, {int? statusCode}) {
    final m = msg.toLowerCase().trim();

    if (m.contains('provider_suspended')) {
      return 'حساب مزود الخدمة موقوف. يرجى التواصل مع الدعم.';
    }

    if (m.contains('invalid credentials') ||
        m.contains('invalid credential') ||
        m.contains('unauthorized') ||
        statusCode == 401 ||
        statusCode == 404) {
      return 'بيانات الدخول غير صحيحة. تأكد من البريد/رقم الهاتف وكلمة المرور.';
    }

    return msg;
  }

  // ================== LOGIN ==================

  @override
  Future<AuthSessionModel> loginWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    try {
      final normalizedId = _normalizeArabicDigits(identifier).trim();
      final bool isEmail = normalizedId.contains('@');

      final body = <String, dynamic>{
        if (isEmail) 'email': normalizedId else 'phone': normalizedId,
        'password': password,
      };

      final response = await _dio.post(
        ApiConstants.login,
        data: body,
      );

      _extractDataOrThrow(response);

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw ServerException(
          message: 'تنسيق الاستجابة غير صحيح',
          statusCode: response.statusCode ?? 0,
        );
      }

      return AuthSessionModel.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
  }

  // ================== SIGNUP ==================

  @override
  Future<AuthSessionModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required int cityId,
    required int areaId,
    required String role,
  }) async {
    try {
      final body = <String, dynamic>{
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim().isEmpty ? null : email.trim(),
        'phone': _normalizeArabicDigits(phone).trim().isEmpty
            ? null
            : _normalizeArabicDigits(phone).trim(),
        'password': password,
        'city_id': cityId,
        'area_id': areaId,
        'role': 'customer',
      };

      final response = await _dio.post(
        ApiConstants.signup,
        data: body,
      );

      _extractDataOrThrow(response);

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw ServerException(
          message: 'تنسيق الاستجابة غير صحيح',
          statusCode: response.statusCode ?? 0,
        );
      }

      return AuthSessionModel.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
  }

  // ================== RESET PASSWORD FLOW (OTP) ==================

  @override
  Future<void> sendResetCode({required String phone}) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: {
          'phone': _normalizeArabicDigits(phone).trim(),
          'purpose': 'reset_password',
        },
      );

      _extractDataOrThrow(response);
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
  }

  @override
  Future<void> verifyResetCode({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          'phone': _normalizeArabicDigits(phone).trim(),
          'otp': code.trim(),
          'purpose': 'reset_password',
        },
      );

      _extractDataOrThrow(response);
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    throw const ServerException(
      message:
          'resetPassword is not implemented yet. Please implement the backend endpoint or adjust the flow.',
    );
  }

  // ===================== Helpers =====================

  dynamic _extractDataOrThrow(Response response) {
    final statusCode = response.statusCode ?? 0;
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw ServerException(
        message: 'تنسيق الاستجابة غير صحيح',
        statusCode: statusCode,
      );
    }

    final success =
        body['success'] as bool? ?? (statusCode >= 200 && statusCode < 300);

    if (!success) {
      final message = body['message']?.toString() ?? 'فشل الطلب';
      final errors = body['errors'] is Map<String, dynamic>
          ? body['errors'] as Map<String, dynamic>
          : null;

      throw ServerException(
        message: _mapAuthMessage(message, statusCode: statusCode),
        statusCode: statusCode,
        errors: errors,
      );
    }

    return body['data'];
  }

  ServerException _mapDioErrorToServerException(DioException e) {
    // ✅ في حال فيه Response
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        final msg = data['message']?.toString() ?? 'حدث خطأ في الخادم';
        return ServerException(
          message: _mapAuthMessage(msg, statusCode: statusCode),
          statusCode: statusCode,
          errors: data['errors'] is Map<String, dynamic>
              ? data['errors'] as Map<String, dynamic>
              : null,
        );
      }

      return ServerException(
        message: _mapAuthMessage('حدث خطأ في الخادم', statusCode: statusCode),
        statusCode: statusCode,
      );
    }

    // ✅ بدون response => غالباً Network / Timeout
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ServerException(
        message: 'تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.',
      );
    }

    return const ServerException(
      message: 'تعذر الاتصال، حاول مرة أخرى.',
    );
  }
}
