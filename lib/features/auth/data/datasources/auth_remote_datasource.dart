// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_session_model.dart';

/// العقد (interface) بين الريبو وبين الـ API.
/// هنا نشتغل على مستوى Models (مش Entities).
abstract class AuthRemoteDataSource {
  /// تسجيل الدخول باستخدام (إيميل أو جوال) + كلمة سر.
  Future<AuthSessionModel> loginWithIdentifier({
    required String identifier,
    required String password,
  });

  /// إرسال كود لإعادة تعيين كلمة المرور (OTP) على رقم الجوال.
  Future<void> sendResetCode({
    required String phone,
  });

  /// التحقق من كود إعادة التعيين (OTP).
  ///
  /// حالياً الباك إند يرجّع token + user، لكن
  /// الـ Domain عندنا معرفها كـ void، فإحنا نتجاهل الداتا هنا.
  Future<void> verifyResetCode({
    required String phone,
    required String code,
  });

  /// تعيين كلمة سر جديدة بعد التحقق.
  ///
  /// ⚠️ ملاحظة مهمة:
  /// الباك إند الحالي ما فيه Endpoint جاهز صريح لـ reset password
  /// باستخدام OTP، لذلك رح نخليها مؤقتاً "غير مفعّلة".
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });
}

/// الـ implementation الفعلي باستخدام Dio.
/// يفضّل إن الـ Dio يكون مهيّأ بـ baseUrl = 'https://your-domain.com/api'
/// عشان نستخدم فقط '/auth/...'
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthSessionModel> loginWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    try {
      // نقرر هل الـ identifier إيميل ولا جوال
      final bool isEmail = identifier.contains('@');

      final body = <String, dynamic>{
        if (isEmail) 'email': identifier.trim() else 'phone': identifier.trim(),
        'password': password,
      };

      final response = await _dio.post(
        '/auth/login',
        data: body,
      );

      final data = _extractDataOrThrow(response);

      // الـ backend يرجّع:
      // { token, user, provider_profile? }
      return AuthSessionModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
  }

  @override
  Future<void> sendResetCode({required String phone}) async {
    try {
      final response = await _dio.post(
        '/auth/send-otp',
        data: {
          'phone': phone.trim(),
          'purpose': 'reset_password',
        },
      );

      _extractDataOrThrow(response); // لو في خطأ رح يرمي Exception
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
        '/auth/verify-otp',
        data: {
          'phone': phone.trim(),
          'otp': code.trim(),
          'purpose': 'reset_password',
        },
      );

      // هنا الباك إند يرجع token + user، لكن
      // حسب الـ Domain إحنا مش محتاجين نستخدم الداتا حالياً.
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
    // ⚠️ مهم:
    // من مراجعة الباك إند، ما فيه Endpoint واضح لتنفيذ
    // reset password عن طريق OTP فقط.
    // تقدر لاحقاً:
    // - إمّا تعدّل الـ backend
    // - أو تغيّر الـ Domain / UseCases عشان تستخدم change-password
    //   بعد تسجيل الدخول.
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
        message: 'Invalid response format',
        statusCode: statusCode,
      );
    }

    final success = body['success'] as bool? ?? (statusCode >= 200 && statusCode < 300);
    if (!success) {
      final message = body['message']?.toString() ?? 'Request failed';
      final errors = body['errors'] is Map<String, dynamic> ? body['errors'] as Map<String, dynamic> : null;

      throw ServerException(
        message: message,
        statusCode: statusCode,
        errors: errors,
      );
    }

    // في responseHelper الباك إند عادة يرجّع data تحت key 'data'
    return body['data'];
  }

  ServerException _mapDioErrorToServerException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        return ServerException(
          message: data['message']?.toString() ?? 'Server error',
          statusCode: statusCode,
          errors: data['errors'] is Map<String, dynamic>
              ? data['errors'] as Map<String, dynamic>
              : null,
        );
      }

      return ServerException(
        message: 'Server error',
        statusCode: statusCode,
      );
    }

    return const ServerException(
      message: 'Network error, please check your connection',
    );
  }
}
