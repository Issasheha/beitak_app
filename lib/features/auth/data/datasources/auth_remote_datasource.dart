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

  Future<void> sendResetCode({required String phone});

  Future<void> verifyResetCode({required String phone, required String code});

  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

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

      final response = await _dio.post(ApiConstants.login, data: body);

      _extractDataOrThrow(response);

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw ServerException(
          message: 'صيغة الاستجابة غير صحيحة',
          statusCode: response.statusCode ?? 0,
        );
      }

      return AuthSessionModel.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
  }

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
        'role': 'customer',
      };

      final response = await _dio.post(ApiConstants.signup, data: body);

      _extractDataOrThrow(response);

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw ServerException(
          message: 'صيغة الاستجابة غير صحيحة',
          statusCode: response.statusCode ?? 0,
        );
      }

      return AuthSessionModel.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
  }

  @override
  Future<void> sendResetCode({required String phone}) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: {'phone': phone.trim(), 'purpose': 'reset_password'},
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
        data: {'phone': phone.trim(), 'otp': code.trim(), 'purpose': 'reset_password'},
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
      message: 'resetPassword is not implemented yet.',
    );
  }

  dynamic _extractDataOrThrow(Response response) {
    final statusCode = response.statusCode ?? 0;
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw ServerException(
        message: 'صيغة الاستجابة غير صحيحة',
        statusCode: statusCode,
      );
    }

    final success = body['success'] as bool? ?? (statusCode >= 200 && statusCode < 300);

    if (!success) {
      final message = body['message']?.toString() ?? 'فشل الطلب';
      final errors = body['errors'] is Map<String, dynamic> ? body['errors'] as Map<String, dynamic> : null;

      throw ServerException(
        message: message,
        statusCode: statusCode,
        errors: errors,
      );
    }

    return body['data'];
  }

  ServerException _mapDioErrorToServerException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        return ServerException(
          message: data['message']?.toString() ?? 'خطأ من الخادم',
          statusCode: statusCode,
          errors: data['errors'] is Map<String, dynamic> ? data['errors'] as Map<String, dynamic> : null,
        );
      }

      return ServerException(
        message: 'خطأ من الخادم',
        statusCode: statusCode,
      );
    }

    // ✅ عربي بدل الإنجليزي
    return const ServerException(
      message: 'تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.',
    );
  }
}
