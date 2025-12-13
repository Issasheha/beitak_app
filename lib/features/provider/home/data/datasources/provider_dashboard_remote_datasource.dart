import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_stats_model.dart';

class ProviderDashboardRemoteDataSource {
  final Dio _dio;
  final AuthLocalDataSource _local;

  ProviderDashboardRemoteDataSource({
    Dio? dio,
    AuthLocalDataSource? localDataSource,
  })  : _dio = dio ?? ApiClient.dio,
        _local = localDataSource ?? AuthLocalDataSourceImpl();

  Future<Options> _authOptions() async {
    final session = await _local.getCachedAuthSession();
    final token = session?.token;

    if (token == null || token.isEmpty) return Options();

    final normalized = token.startsWith('Bearer ') ? token.substring(7) : token;

    return Options(headers: {
      HttpHeaders.authorizationHeader: 'Bearer $normalized',
    });
  }

  void _logDioError(String tag, DioException e) {
    debugPrint('--- DIO ERROR [$tag] ---');
    debugPrint('METHOD: ${e.requestOptions.method}');
    debugPrint('PATH:   ${e.requestOptions.path}');
    debugPrint('STATUS: ${e.response?.statusCode}');
    debugPrint('QUERY:  ${e.requestOptions.queryParameters}');
    debugPrint('BODY:   ${e.requestOptions.data}');
    debugPrint('RESP:   ${e.response?.data}');
    debugPrint('ERR:    ${e.message}');
    debugPrint('------------------------');
  }

  Future<List<ProviderBookingModel>> getMyBookings({
    int page = 1,
    int limit = 50,
    String sortBy = 'booking_date',
    String order = 'ASC',
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.bookingsMy,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sort_by': sortBy,
          'order': order,
        },
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) return const [];

      final bookings = (data['data']?['bookings'] as List?) ?? const [];
      return bookings
          .whereType<Map>()
          .map((e) => ProviderBookingModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      _logDioError('getMyBookings', e);
      rethrow;
    }
  }

  Future<ProviderStatsModel> getDashboardStats() async {
    try {
      final res = await _dio.get(
        ApiConstants.providerDashboardStats,
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) return ProviderStatsModel.empty;

      final stats = (data['data']?['statistics'] as Map?)?.cast<String, dynamic>();
      if (stats == null) return ProviderStatsModel.empty;

      return ProviderStatsModel.fromJson(stats);
    } on DioException catch (e) {
      _logDioError('getDashboardStats', e);
      rethrow;
    }
  }

  Future<void> providerAction({
    required int bookingId,
    required String action, // accept | reject
  }) async {
    try {
      await _dio.patch(
        ApiConstants.bookingProviderAction(bookingId),
        data: {'action': action},
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      _logDioError('providerAction($action)', e);
      rethrow;
    }
  }

  // ✅ Complete
  Future<void> providerComplete(int bookingId) async {
    try {
      await _dio.patch(
        ApiConstants.bookingProviderComplete(bookingId),
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      _logDioError('providerComplete', e);
      rethrow;
    }
  }

  // ✅ Cancel
  Future<void> providerCancel({
    required int bookingId,
    required String cancellationCategory,
    String? cancellationReason,
  }) async {
    try {
      await _dio.patch(
        ApiConstants.bookingProviderCancel(bookingId),
        data: {
          'cancellation_category': cancellationCategory,
          'cancellation_reason': cancellationReason,
        },
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      _logDioError('providerCancel', e);
      rethrow;
    }
  }
}
