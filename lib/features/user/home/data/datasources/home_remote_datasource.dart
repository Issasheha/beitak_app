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
      // /api (من ApiClient) + /categories = /api/categories
      final response = await _dio.get('/categories');

      final data = _extractDataOrThrow(response);

      List<dynamic>? rawList;

      // أحياناً ممكن تكون data نفسها List
      if (data is List) {
        rawList = data;
      }
      // وفي حالة الباك إند الحالي: data = { categories: [...] }
      else if (data is Map<String, dynamic>) {
        final nested = data['categories'];
        if (nested is List) {
          rawList = nested;
        }
      }

      if (rawList == null) {
        throw const ServerException(
          message: 'Invalid categories response format',
        );
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
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
        // city/area: إن كانت أرقام نرسلها كـ user_city_id / user_area_id (الـ backend يعتمدها).
        if (city != null && city.trim().isNotEmpty) ...() {
          final v = city.trim();
          final asInt = int.tryParse(v);
          if (asInt != null) return {'user_city_id': asInt};
          return {'city': v}; // fallback لو كان الباك اند يقبل الاسم/slug
        }(),
        if (area != null && area.trim().isNotEmpty) ...() {
          final v = area.trim();
          final asInt = int.tryParse(v);
          if (asInt != null) return {'user_area_id': asInt};
          return {'area': v};
        }(),
      };

      // /api (من ApiClient) + /services = /api/services
      final response = await _dio.get(
        '/services',
        queryParameters: queryParams,
      );

      final data = _extractDataOrThrow(response);

      List<dynamic>? rawList;

      // لو الـ backend رجع data مباشرة كـ List
      if (data is List) {
        rawList = data;
      }
      // في تطبيقك الحالي: data = { services: [...], pagination: {...} }
      else if (data is Map<String, dynamic>) {
        final nested = data['services'];
        if (nested is List) {
          rawList = nested;
        }
      }

      if (rawList == null) {
        throw const ServerException(
          message: 'Invalid services response format',
        );
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(ServiceModel.fromJson)
          .toList();
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
