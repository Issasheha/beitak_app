// lib/features/user/home/data/datasources/home_remote_datasource.dart

import 'package:dio/dio.dart';

import '../../../../../core/error/exceptions.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';

/// العقد بين الـ Repository وبين API الـ Home/Services.
abstract class HomeRemoteDataSource {
  /// جلب الفئات (Categories)
  Future<List<CategoryModel>> getCategories();

  /// جلب الخدمات (Services) مع إمكانيات فلترة وباجينيشن.
  Future<List<ServiceModel>> getServices({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? city,
    String? area,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      // ✳️ عدّل المسار هنا حسب الـ backend عندكم إذا لزم
      final response = await _dio.get('/categories');

      final data = _extractDataOrThrow(response);

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList();
      }

      throw const ServerException(message: 'Invalid categories response format');
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
  }

  @override
  Future<List<ServiceModel>> getServices({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? city,
    String? area,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (categoryId != null) 'category_id': categoryId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (minRating != null) 'min_rating': minRating,
        if (city != null && city.isNotEmpty) 'city': city,
        if (area != null && area.isNotEmpty) 'area': area,
      };

      // ✳️ عدّل المسار هنا حسب الـ backend عندكم إذا لزم
      final response = await _dio.get(
        '/services',
        queryParameters: queryParams,
      );

      final data = _extractDataOrThrow(response);

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ServiceModel.fromJson)
            .toList();
      }

      throw const ServerException(message: 'Invalid services response format');
    } on DioException catch (e) {
      throw _mapDioErrorToServerException(e);
    }
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

    // متوقع يكون في key اسمه data
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
