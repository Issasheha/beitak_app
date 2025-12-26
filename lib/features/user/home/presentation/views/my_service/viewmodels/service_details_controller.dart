import 'dart:io';

import 'package:dio/dio.dart';

import 'package:beitak_app/core/error/exceptions.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'service_details_state.dart';

class ServiceDetailsController extends StateNotifier<ServiceDetailsState> {
  final Dio _dio;
  final AuthLocalDataSource _local;

  ServiceDetailsController({
    Dio? dio,
    AuthLocalDataSource? local,
  })  : _dio = dio ?? ApiClient.dio,
        _local = local ?? AuthLocalDataSourceImpl(),
        super(const ServiceDetailsState());

  Future<String?> _getToken() async {
    final session = await _local.getCachedAuthSession();
    return session?.token;
  }

  Options _opts(String token) => Options(headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      });

  Map<String, dynamic> _ensureMap(dynamic body, int code) {
    if (body is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Invalid response format',
        statusCode: code,
      );
    }
    return body;
  }

  void _ensureSuccess(Map<String, dynamic> body, int code) {
    final success = body['success'] as bool? ?? (code >= 200 && code < 300);
    if (!success) {
      throw ServerException(
        message: body['message']?.toString() ?? 'Request failed',
        statusCode: code,
        errors: body['errors'] is Map<String, dynamic>
            ? body['errors'] as Map<String, dynamic>
            : null,
      );
    }
  }

  bool _hasProviderRatingData(Map<String, dynamic> booking) {
    // rating.provider_rating OR booking.provider_rating
    final rating = booking['rating'];
    if (rating is Map<String, dynamic>) {
      final pr = rating['provider_rating'];
      final msg = rating['provider_response'];
      if ((pr is num && pr.toInt() > 0) || (msg != null && msg.toString().trim().isNotEmpty)) {
        return true;
      }
    }
    final pr2 = booking['provider_rating'];
    final msg2 = booking['provider_response'];
    if ((pr2 is num && pr2.toInt() > 0) || (msg2 != null && msg2.toString().trim().isNotEmpty)) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> _fetchBookingFromMy({
    required int bookingId,
    required String token,
  }) async {
    try {
      final res = await _dio.get(
        '/bookings/my',
        queryParameters: const {
          'page': 1,
          'limit': 20,
          'status': 'completed',
          'sort_by': 'created_at',
          'order': 'DESC',
        },
        options: _opts(token),
      );

      final code = res.statusCode ?? 0;
      final body = _ensureMap(res.data, code);
      _ensureSuccess(body, code);

      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;

      final list = data['bookings'];
      if (list is! List) return null;

      for (final e in list) {
        if (e is Map<String, dynamic>) {
          final id = int.tryParse('${e['id']}') ?? 0;
          if (id == bookingId) return e;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// تحميل تفاصيل حجز معيّن من /bookings/:id
  Future<void> loadBookingDetails({required int bookingId}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      data: null,
    );

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Access token required',
      );
      return;
    }

    try {
      final res = await _dio.get(
        '/bookings/$bookingId',
        options: _opts(token),
      );

      final code = res.statusCode ?? 0;
      final body = _ensureMap(res.data, code);
      _ensureSuccess(body, code);

      final data = body['data'];
      Map<String, dynamic>? booking;
      if (data is Map<String, dynamic>) {
        if (data['booking'] is Map<String, dynamic>) {
          booking = data['booking'] as Map<String, dynamic>;
        } else {
          booking = data;
        }
      }

      if (booking == null) {
        throw const ServerException(
          message: 'Invalid booking details format',
        );
      }

      // ✅ fallback: إذا /bookings/:id ما رجّع rating
      if (!_hasProviderRatingData(booking)) {
        final fromMy = await _fetchBookingFromMy(bookingId: bookingId, token: token);
        if (fromMy != null) {
          // خذ rating إذا موجود
          if (fromMy['rating'] is Map<String, dynamic>) {
            booking['rating'] = fromMy['rating'];
          }
          // أو خذ provider_rating مباشرة إذا موجودة
          if (fromMy.containsKey('provider_rating')) {
            booking['provider_rating'] = fromMy['provider_rating'];
          }
          if (fromMy.containsKey('provider_response')) {
            booking['provider_response'] = fromMy['provider_response'];
          }
          if (fromMy.containsKey('amount_paid') && (booking['amount_paid'] == null || '${booking['amount_paid']}'.trim().isEmpty)) {
            booking['amount_paid'] = fromMy['amount_paid'];
          }
        }
      }

      state = state.copyWith(data: booking);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        state = state.copyWith(
          error: (e.response!.data as Map<String, dynamic>)['message']?.toString() ?? 'Server error',
        );
      } else {
        state = state.copyWith(error: 'Network error');
      }
    } on ServerException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: 'حدث خطأ غير متوقع');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ======== باقي كود الإلغاء كما هو ========

  Future<bool> cancelBooking({
    required int bookingId,
    required String currentStatus,
    String? cancellationCategory,
    String? cancellationReason,
  }) async {
    state = state.copyWith(
      isCancelling: true,
      error: null,
    );

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        isCancelling: false,
        error: 'Access token required',
      );
      return false;
    }

    try {
      if (currentStatus == 'pending_provider_accept' || currentStatus == 'pending') {
        await _updateStatus(
          token: token,
          bookingId: bookingId,
          status: 'cancelled',
        );
        return true;
      }

      if (currentStatus == 'confirmed') {
        final ok = await _cancelWithReason(
          token: token,
          bookingId: bookingId,
          cancellationCategory: cancellationCategory,
          cancellationReason: cancellationReason,
        );
        if (ok) return true;

        await _updateStatus(
          token: token,
          bookingId: bookingId,
          status: 'cancelled',
        );
        return true;
      }

      await _updateStatus(
        token: token,
        bookingId: bookingId,
        status: 'cancelled',
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        state = state.copyWith(
          error: (e.response!.data as Map<String, dynamic>)['message']?.toString() ?? 'Server error',
        );
      } else {
        state = state.copyWith(error: 'Network error');
      }
      return false;
    } on ServerException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(error: 'حدث خطأ غير متوقع');
      return false;
    } finally {
      state = state.copyWith(isCancelling: false);
    }
  }

  Future<bool> _cancelWithReason({
    required String token,
    required int bookingId,
    String? cancellationCategory,
    String? cancellationReason,
  }) async {
    try {
      final res = await _dio.post(
        '/bookings/$bookingId/cancel',
        data: {
          'cancellation_category': cancellationCategory ?? 'Other',
          'cancellation_reason': cancellationReason ?? 'No reason provided',
        },
        options: _opts(token),
      );

      final code = res.statusCode ?? 0;
      final body = _ensureMap(res.data, code);
      _ensureSuccess(body, code);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  Future<void> _updateStatus({
    required String token,
    required int bookingId,
    required String status,
  }) async {
    final candidates = <String>[
      '/bookings/$bookingId/status',
      '/bookings/$bookingId',
    ];

    DioException? last;
    for (final path in candidates) {
      try {
        final res = await _dio.patch(
          path,
          data: {'status': status},
          options: _opts(token),
        );

        final code = res.statusCode ?? 0;
        final body = _ensureMap(res.data, code);
        _ensureSuccess(body, code);
        return;
      } on DioException catch (e) {
        last = e;
      }
    }

    if (last != null) throw last;
    throw const ServerException(message: 'Failed to update booking status');
  }
}
