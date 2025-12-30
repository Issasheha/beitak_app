import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:beitak_app/core/error/exceptions.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';

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
    final rating = booking['rating'];
    if (rating is Map<String, dynamic>) {
      final pr = rating['provider_rating'];
      final msg = rating['provider_response'];
      if ((pr is num && pr.toInt() > 0) ||
          (msg != null && msg.toString().trim().isNotEmpty)) {
        return true;
      }
    }

    final pr2 = booking['provider_rating'];
    final msg2 = booking['provider_response'];
    if ((pr2 is num && pr2.toInt() > 0) ||
        (msg2 != null && msg2.toString().trim().isNotEmpty)) {
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
        ApiConstants.bookingsMy,
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

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final id = int.tryParse('${item['id']}') ?? 0;
          if (id == bookingId) return item;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// ==========================
  /// GET /bookings/:id
  /// ==========================
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
        ApiConstants.bookingDetails(bookingId),
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

      // ✅ fallback: إذا /bookings/:id ما رجّع rating provider->user
      if (!_hasProviderRatingData(booking)) {
        final fromMy =
            await _fetchBookingFromMy(bookingId: bookingId, token: token);
        if (fromMy != null) {
          if (fromMy['rating'] is Map<String, dynamic>) {
            booking['rating'] = fromMy['rating'];
          }
          if (fromMy.containsKey('provider_rating')) {
            booking['provider_rating'] = fromMy['provider_rating'];
          }
          if (fromMy.containsKey('provider_response')) {
            booking['provider_response'] = fromMy['provider_response'];
          }
          if (fromMy.containsKey('amount_paid') &&
              (booking['amount_paid'] == null ||
                  '${booking['amount_paid']}'.trim().isEmpty)) {
            booking['amount_paid'] = fromMy['amount_paid'];
          }
        }
      }

      state = state.copyWith(data: booking);
    } on DioException catch (ex) {
      if (ex.response?.data is Map<String, dynamic>) {
        state = state.copyWith(
          error: (ex.response!.data as Map<String, dynamic>)['message']
                  ?.toString() ??
              'Server error',
        );
      } else {
        state = state.copyWith(error: 'Network error');
      }
    } on ServerException catch (ex) {
      state = state.copyWith(error: ex.message);
    } catch (_) {
      state = state.copyWith(error: 'حدث خطأ غير متوقع');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// ==========================
  /// USER -> PROVIDER rating
  /// POST /ratings/submit
  /// body: { booking_id, rating, review, amount_paid }
  /// ==========================
  Future<Map<String, dynamic>> submitUserRating({
    required int bookingId,
    required int rating,
    required double amountPaid,
    String? review,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw const ServerException(message: 'Access token required');
    }

    final res = await _dio.post(
      '/ratings/submit',
      data: {
        'booking_id': bookingId,
        'rating': rating,
        'review': (review ?? '').trim().isEmpty ? null : review!.trim(),
        'amount_paid': amountPaid,
      },
      options: _opts(token),
    );

    final code = res.statusCode ?? 0;
    final body = _ensureMap(res.data, code);
    _ensureSuccess(body, code);

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const ServerException(message: 'Invalid rating response format');
    }

    // ✅ تحديث فوري للواجهة
    final current = state.data;
    if (current != null) {
      final next = Map<String, dynamic>.from(current);
      next['rating'] = data;
      state = state.copyWith(data: next);
    }

    return data;
  }

  /// ==========================
  /// ✅ CANCEL (UPDATED)
  /// POST /users/bookings/:id/cancel
  /// ==========================
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

    final cat = cancellationCategory?.trim();
    final reason = cancellationReason?.trim();

    // لو ما كتب ولا إشي، بنخلي سبب افتراضي نظيف
    final String safeReason = (reason != null && reason.isNotEmpty)
        ? reason
        : (cat != null && cat.isNotEmpty)
            ? cat
            : 'Cancelled by user';

    try {
      // ✅ 1) الاندبوينت الصحيح (user cancel)
      final ok = await _cancelUserBooking(
        token: token,
        bookingId: bookingId,
        cancellationCategory: cat,
        cancellationReason: safeReason,
      );

      if (ok) {
        _applyLocalCancelled(
          cancellationCategory: cat,
          cancellationReason: safeReason,
        );
        return true;
      }

      // ✅ 2) fallback: جرّب القديم لو السيرفر ببيئة ثانية
      final okOld = await _cancelOldEndpoint(
        token: token,
        bookingId: bookingId,
        cancellationCategory: cat,
        cancellationReason: safeReason,
      );

      if (okOld) {
        _applyLocalCancelled(
          cancellationCategory: cat,
          cancellationReason: safeReason,
        );
        return true;
      }

      // ✅ 3) fallback نهائي: PATCH status (لو السيرفر بدعمه)
      await _updateStatus(
        token: token,
        bookingId: bookingId,
        status: 'cancelled',
        cancellationCategory: cat,
        cancellationReason: safeReason,
      );

      _applyLocalCancelled(
        cancellationCategory: cat,
        cancellationReason: safeReason,
      );
      return true;
    } on DioException catch (ex) {
      if (ex.response?.data is Map<String, dynamic>) {
        state = state.copyWith(
          error: (ex.response!.data as Map<String, dynamic>)['message']
                  ?.toString() ??
              'Server error',
        );
      } else {
        state = state.copyWith(error: 'Network error');
      }
      return false;
    } on ServerException catch (ex) {
      state = state.copyWith(error: ex.message);
      return false;
    } catch (_) {
      state = state.copyWith(error: 'حدث خطأ غير متوقع');
      return false;
    } finally {
      state = state.copyWith(isCancelling: false);
    }
  }

  void _applyLocalCancelled({
    String? cancellationCategory,
    String? cancellationReason,
  }) {
    final current = state.data;
    if (current == null) return;

    final next = Map<String, dynamic>.from(current);
    next['status'] = 'cancelled';
    next['cancelled_by'] = 'customer';

    if (cancellationReason != null && cancellationReason.trim().isNotEmpty) {
      next['cancellation_reason'] = cancellationReason.trim();
    }
    if (cancellationCategory != null && cancellationCategory.trim().isNotEmpty) {
      next['cancellation_category'] = cancellationCategory.trim();
    }

    state = state.copyWith(data: next);
  }

  /// ✅ NEW: POST /users/bookings/:id/cancel
  Future<bool> _cancelUserBooking({
    required String token,
    required int bookingId,
    String? cancellationCategory,
    required String cancellationReason,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.userBookingCancel(bookingId),
        data: {
          if (cancellationCategory != null &&
              cancellationCategory.trim().isNotEmpty)
            'cancellation_category': cancellationCategory.trim(),
          'cancellation_reason': cancellationReason.trim(),
        },
        options: _opts(token),
      );

      final code = res.statusCode ?? 0;
      final body = _ensureMap(res.data, code);
      _ensureSuccess(body, code);
      return true;
    } on DioException catch (ex) {
      // لو 404 معناها الاندبوينت مش موجود ببيئة معينة -> رجّع false عشان fallback
      if (ex.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  /// ✅ Old fallback: POST /bookings/:id/cancel
  Future<bool> _cancelOldEndpoint({
    required String token,
    required int bookingId,
    String? cancellationCategory,
    required String cancellationReason,
  }) async {
    try {
      final res = await _dio.post(
        '/bookings/$bookingId/cancel',
        data: {
          if (cancellationCategory != null &&
              cancellationCategory.trim().isNotEmpty)
            'cancellation_category': cancellationCategory.trim(),
          'cancellation_reason': cancellationReason.trim(),
        },
        options: _opts(token),
      );

      final code = res.statusCode ?? 0;
      final body = _ensureMap(res.data, code);
      _ensureSuccess(body, code);
      return true;
    } on DioException catch (ex) {
      if (ex.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  /// ✅ PATCH fallback (لو السيرفر بدعمه)
  Future<void> _updateStatus({
    required String token,
    required int bookingId,
    required String status,
    String? cancellationCategory,
    String? cancellationReason,
  }) async {
    final candidates = <String>[
      '/bookings/$bookingId/status',
      '/bookings/$bookingId',
    ];

    final data = <String, dynamic>{'status': status};

    if (status == 'cancelled') {
      if (cancellationCategory != null &&
          cancellationCategory.trim().isNotEmpty) {
        data['cancellation_category'] = cancellationCategory.trim();
      }
      if (cancellationReason != null &&
          cancellationReason.trim().isNotEmpty) {
        data['cancellation_reason'] = cancellationReason.trim();
      }
    }

    DioException? lastError;

    for (final path in candidates) {
      try {
        final res = await _dio.patch(
          path,
          data: data,
          options: _opts(token),
        );

        final code = res.statusCode ?? 0;
        final body = _ensureMap(res.data, code);
        _ensureSuccess(body, code);
        return;
      } on DioException catch (ex) {
        lastError = ex;
      }
    }

    if (lastError != null) throw lastError;
    throw const ServerException(message: 'Failed to update booking status');
  }
}
