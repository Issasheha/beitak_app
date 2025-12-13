import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_session_model.dart';

/// العقد (interface) بين الريبو وبين الـ API.
/// هنا نشتغل على مستوى Models (مش Entities).
abstract class AuthRemoteDataSource {
  /// تسجيل الدخول باستخدام (إيميل أو جوال) + كلمة سر.
  Future<AuthSessionModel> loginWithIdentifier({
    required String identifier,
    required String password,
  });

  /// إنشاء حساب جديد (تسجيل مستخدم جديد).
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

  /// إرسال كود لإعادة تعيين كلمة المرور (OTP) على رقم الجوال.
  Future<void> sendResetCode({
    required String phone,
  });

  /// التحقق من كود إعادة التعيين (OTP).
  Future<void> verifyResetCode({
    required String phone,
    required String code,
  });

  /// تعيين كلمة سر جديدة بعد التحقق.
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });
}

/// الـ implementation الفعلي باستخدام Dio.
///
/// مهم:
/// - الـ Dio اللي ييجي هنا يفضّل يكون من `ApiClient.dio`
///   اللي baseUrl تبعه = `ApiConstants.apiBase`
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  // ================== LOGIN ==================

  @override
  Future<AuthSessionModel> loginWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    try {
      final bool isEmail = identifier.contains('@');

      final body = <String, dynamic>{
        if (isEmail) 'email': identifier.trim() else 'phone': identifier.trim(),
        'password': password,
      };

      final response = await _dio.post(
        ApiConstants.login,
        data: body,
      );

      // ✅ نحافظ على نفس منطق success/errors الحالي
      _extractDataOrThrow(response);

      // ✅ التعديل المهم: مرّر الـ BODY كامل للموديل
      // لأن بعض الباك يرجّع token/access_token داخل body أو داخل data أو nested
      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw ServerException(
          message: 'Invalid response format',
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
        'phone': phone.trim().isEmpty ? null : phone.trim(),
        'password': password,
        'city_id': cityId,
        'area_id': areaId,

        // ✅ مهم جداً: نعلّم الباك إند أن هذا الحساب هو "مستخدم عادي"
        'role': 'customer',
      };

      final response = await _dio.post(
        ApiConstants.signup,
        data: body,
      );

      // ✅ نحافظ على نفس منطق success/errors الحالي
      _extractDataOrThrow(response);

      // ✅ التعديل المهم: مرّر الـ BODY كامل للموديل
      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw ServerException(
          message: 'Invalid response format',
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
          'phone': phone.trim(),
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
          'phone': phone.trim(),
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
        message: 'Invalid response format',
        statusCode: statusCode,
      );
    }

    final success =
        body['success'] as bool? ?? (statusCode >= 200 && statusCode < 300);

    if (!success) {
      final message = body['message']?.toString() ?? 'Request failed';
      final errors = body['errors'] is Map<String, dynamic>
          ? body['errors'] as Map<String, dynamic>
          : null;

      throw ServerException(
        message: message,
        statusCode: statusCode,
        errors: errors,
      );
    }

    // الباك إند عادة يرجّع الداتا تحت key 'data'
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
