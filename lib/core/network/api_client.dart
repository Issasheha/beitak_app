// lib/core/network/api_client.dart
// P1: Added retry strategy with exponential backoff for idempotent requests
// P1: Enhanced error handling and sanitized logging
// P2: Added compute() support for large JSON payloads

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../constants/network_constants.dart';
import 'api_constants.dart';
import 'token_provider.dart';

class ApiClient {
  ApiClient._();

  // ✅ CookieJar (in-memory) لحفظ/إرسال cookies تلقائيًا (مهم للـ refresh-token إذا كان cookie-based)
  static final CookieJar _cookieJar = CookieJar();

  // ✅ Dio واحد أساسي
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.apiBase,
      connectTimeout: const Duration(seconds: NetworkConstants.connectTimeoutSeconds),
      receiveTimeout: const Duration(seconds: NetworkConstants.receiveTimeoutSeconds),
      headers: {
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(CookieManager(_cookieJar))
    // ✅ P2: Certificate Pinning (Verify server identity)
    // Note: This requires HTTPS. Enable this block once API endpoint uses HTTPS.
    // ..httpClientAdapter = IOHttpClientAdapter(
    //   createHttpClient: () {
    //     final client = HttpClient();
    //     client.badCertificateCallback = (cert, host, port) {
    //       // ⚠️ SECURITY: Replace with actual SHA-256 hash or public key verification
    //       // For development (self-signed): return true;
    //       // For production: Verify cert.sha256 matches your known hash
    //       return false; 
    //     };
    //     return client;
    //   },
    // )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ إذا هذا request خاص بالـ refresh لا نضيف Authorization
          final skipAuth = options.extra['skipAuth'] == true;

          if (!skipAuth) {
            final token = await TokenProvider.getToken();

            // ✅ Authorization فقط (لا x-access-token)
            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.trim()}';
            } else {
              options.headers.remove('Authorization');
            }
          } else {
            options.headers.remove('Authorization');
          }

          _logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logError(e);

          final req = e.requestOptions;
          final status = e.response?.statusCode;

          // ✅ P1: Check if request is retryable (idempotent methods only)
          final isRetryable = _isRetryableRequest(req);
          final retryCount = (req.extra['retryCount'] as int?) ?? 0;
          final alreadyRetried = req.extra['retried'] == true;
          final isRefreshCall = _isRefreshRequest(req);

          // ✅ P1: Retry for transient errors (timeout, connection, specific status codes)
          if (isRetryable && 
              !isRefreshCall && 
              retryCount < NetworkConstants.maxRetryAttempts &&
              _isTransientError(e)) {
            
            if (kDebugMode) {
              debugPrint('│ Retrying request (attempt ${retryCount + 1}/${NetworkConstants.maxRetryAttempts})...');
            }

            try {
              final response = await _retryWithBackoff(req, retryCount + 1);
              return handler.resolve(response);
            } catch (retryError) {
              // If retry fails, continue with original error handling
              if (kDebugMode) {
                debugPrint('│ Retry failed: $retryError');
              }
            }
          }

          // ✅ فقط 401 => جرّب refresh + retry
          if (status == 401 && !isRefreshCall && !alreadyRetried) {
            try {
              final newToken = await _refreshToken();

              // ✅ خزّن التوكن الجديد داخل auth_session
              await TokenProvider.saveToken(newToken);

              // ✅ اعمل retry لنفس الطلب مرة واحدة
              final retryResponse = await _retry(req, newToken);

              return handler.resolve(retryResponse);
            } catch (_) {
              // ✅ فشل refresh => session انتهت (أو cookie ناقصة/expired)
              await TokenProvider.clearToken();
              return handler.next(e);
            }
          }

          handler.next(e);
        },
      ),
    );

  // ========================
  // P1: Retry Logic
  // ========================

  /// Check if the request method is idempotent and safe to retry
  static bool _isRetryableRequest(RequestOptions options) {
    final method = options.method.toUpperCase();
    
    // Check if method is in the retryable set
    if (!NetworkConstants.retryableMethods.contains(method)) {
      return false;
    }
    
    // Check if explicitly marked as non-retryable
    if (options.extra['noRetry'] == true) {
      return false;
    }
    
    return true;
  }

  /// Check if the error is transient and worth retrying
  static bool _isTransientError(DioException e) {
    // Connection and timeout errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }

    // Specific HTTP status codes that are retryable
    final status = e.response?.statusCode;
    if (status != null && NetworkConstants.retryableStatusCodes.contains(status)) {
      return true;
    }

    return false;
  }

  /// Retry with exponential backoff
  static Future<Response<dynamic>> _retryWithBackoff(
    RequestOptions original,
    int attempt,
  ) async {
    // Calculate delay: 500ms, 1000ms, 2000ms
    final delayMs = NetworkConstants.baseRetryDelayMs * (1 << (attempt - 1));
    await Future.delayed(Duration(milliseconds: delayMs));

    if (kDebugMode) {
      debugPrint('│ Waited ${delayMs}ms before retry attempt $attempt');
    }

    final headers = Map<String, dynamic>.from(original.headers);
    
    // Refresh token if needed before retry
    final token = await TokenProvider.getToken();
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    final opts = Options(
      method: original.method,
      headers: headers,
      responseType: original.responseType,
      contentType: original.contentType,
      followRedirects: original.followRedirects,
      validateStatus: original.validateStatus,
      receiveDataWhenStatusError: original.receiveDataWhenStatusError,
      extra: Map<String, dynamic>.from(original.extra)
        ..['retryCount'] = attempt,
    );

    return dio.request<dynamic>(
      original.path,
      data: original.data,
      queryParameters: original.queryParameters,
      options: opts,
      cancelToken: original.cancelToken,
      onReceiveProgress: original.onReceiveProgress,
      onSendProgress: original.onSendProgress,
    );
  }

  // ========================
  // Refresh guard
  // ========================

  /// ✅ P1: Single-flight refresh using Completer (replaces fragile polling)
  static Completer<String>? _refreshCompleter;

  static bool _isRefreshRequest(RequestOptions o) {
    final p = o.path.toLowerCase();
    return p.contains('/auth/refresh-token');
  }

  /// ✅ P1: Thread-safe single-flight token refresh
  /// If a refresh is already in progress, all callers wait for the same result.
  static Future<String> _refreshToken() async {
    // If refresh already in progress, wait for it
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    // Start new refresh
    _refreshCompleter = Completer<String>();

    try {
      // ✅ مهم: skipAuth حتى ما يدخل في 401 loop
      final res = await dio.post(
        '/auth/refresh-token',
        options: Options(extra: {'skipAuth': true, 'noRetry': true}),
      );

      final data = res.data;
      String token = '';
      DateTime? expiresAt;

      if (data is Map && data['data'] is Map) {
        final dataMap = data['data'] as Map;
        token = dataMap['token']?.toString().trim() ?? '';
        
        // ✅ P0: Also extract expiry for client-side validation
        final expiresAtStr = dataMap['expires_at']?.toString();
        if (expiresAtStr != null) {
          expiresAt = DateTime.tryParse(expiresAtStr);
        }
      }

      if (token.isEmpty) {
        throw Exception('Refresh-token response missing token');
      }

      // ✅ P0: Save with expiry for client-side expiry validation
      await TokenProvider.saveToken(token, expiresAt: expiresAt);

      _refreshCompleter!.complete(token);
      return token;
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  static Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    String newToken,
  ) async {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $newToken';

    final opts = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      extra: Map<String, dynamic>.from(requestOptions.extra)
        ..['retried'] = true, // ✅ منع retry loop
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  // ========================
  // P2: Compute for large JSON
  // ========================

  /// Parse JSON using compute() for large payloads
  /// Use this for heavy endpoints that return large responses
  static Future<dynamic> parseJsonInBackground(String jsonString) async {
    if (jsonString.length < NetworkConstants.computeThresholdBytes) {
      // Small payload, parse synchronously
      return jsonDecode(jsonString);
    }

    // Large payload, use compute isolate
    return compute(_parseJson, jsonString);
  }

  static dynamic _parseJson(String jsonString) {
    return jsonDecode(jsonString);
  }

  // ========================
  // Logs (Guarded for Release)
  // ========================

  static void _logRequest(RequestOptions o) {
    // ✅ P0: Disable logs in release mode to prevent token leakage
    if (!kDebugMode) return;

    final auth = (o.headers['Authorization'] ?? '').toString();
    final maskedAuth = _maskBearer(auth);

    final headers = Map<String, dynamic>.from(o.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = maskedAuth;
    }

    final dataPreview = _sanitizeAndPreviewBody(o.data);

    // ignore: avoid_print
    print('┌────────────────────────── REQUEST ──────────────────────────');
    // ignore: avoid_print
    print('│ ${o.method}  ${o.baseUrl}${o.path}');
    if (o.queryParameters.isNotEmpty) {
      // ignore: avoid_print
      print('│ Query: ${jsonEncode(o.queryParameters)}');
    }
    // ignore: avoid_print
    print('│ Headers: ${jsonEncode(headers)}');
    if (dataPreview != null) {
      // ignore: avoid_print
      print('│ Body: $dataPreview');
    }
    // ignore: avoid_print
    print('└──────────────────────────────────────────────────────────────');
  }

  static void _logResponse(Response r) {
    // ✅ P0: Disable logs in release
    if (!kDebugMode) return;
    final dataPreview = _previewResponse(r.data);

    // ignore: avoid_print
    print('┌────────────────────────── RESPONSE ─────────────────────────');
    // ignore: avoid_print
    print('│ ${r.statusCode}  ${r.requestOptions.method}  ${r.requestOptions.uri}');
    if (dataPreview != null) {
      // ignore: avoid_print
      print('│ Body: $dataPreview');
    }
    // ignore: avoid_print
    print('└──────────────────────────────────────────────────────────────');
  }

  static void _logError(DioException e) {
    // ✅ P0: Disable logs in release
    if (!kDebugMode) return;
    final ro = e.requestOptions;

    final auth = (ro.headers['Authorization'] ?? '').toString();
    final maskedAuth = _maskBearer(auth);

    final headers = Map<String, dynamic>.from(ro.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = maskedAuth;
    }

    final reqBody = _sanitizeAndPreviewBody(ro.data);
    final respBody = _previewResponse(e.response?.data);

    // ignore: avoid_print
    print('┌────────────────────────── DIO ERROR ─────────────────────────');
    // ignore: avoid_print
    print('│ Type: ${e.type}');
    // ignore: avoid_print
    print('│ Message: ${e.message}');
    // ignore: avoid_print
    print('│ ${ro.method}  ${ro.uri}');
    if (ro.queryParameters.isNotEmpty) {
      // ignore: avoid_print
      print('│ Query: ${jsonEncode(ro.queryParameters)}');
    }
    // ignore: avoid_print
    print('│ Headers: ${jsonEncode(headers)}');
    if (reqBody != null) {
      // ignore: avoid_print
      print('│ Body: $reqBody');
    }
    // ignore: avoid_print
    print('│ Status: ${e.response?.statusCode}');
    if (respBody != null) {
      // ignore: avoid_print
      print('│ Response: $respBody');
    }
    // ignore: avoid_print
    print('└──────────────────────────────────────────────────────────────');
  }

  static String _maskBearer(String v) {
    final s = v.trim();
    if (s.isEmpty) return '';
    if (!s.toLowerCase().startsWith('bearer ')) return '***';
    final token = s.substring(7).trim();
    if (token.length <= 12) return 'Bearer ***';
    final start = token.substring(0, 6);
    final end = token.substring(token.length - 6);
    return 'Bearer $start...$end';
  }

  /// ✅ P1: Sanitize sensitive data before logging
  static String? _sanitizeAndPreviewBody(dynamic data) {
    if (data == null) return null;

    if (data is FormData) {
      // Sanitize form data fields
      final fields = data.fields.map((e) {
        final key = e.key.toLowerCase();
        if (_isSensitiveKey(key)) {
          return '${e.key}=***';
        }
        return '${e.key}=${e.value}';
      }).toList();
      final files = data.files.map((e) => e.key).toList();
      return 'FormData(fields=${fields.take(20).toList()}, files=$files)';
    }

    if (data is Map) {
      final sanitized = _sanitizeMap(Map<String, dynamic>.from(data));
      try {
        return jsonEncode(sanitized);
      } catch (_) {
        return sanitized.toString();
      }
    }

    if (data is List) {
      try {
        return jsonEncode(data);
      } catch (_) {
        return data.toString();
      }
    }

    return data.toString();
  }

  /// Sanitize a map by masking sensitive values
  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      if (_isSensitiveKey(entry.key.toLowerCase())) {
        result[entry.key] = '***';
      } else if (entry.value is Map) {
        result[entry.key] = _sanitizeMap(Map<String, dynamic>.from(entry.value));
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Check if a key name indicates sensitive data
  static bool _isSensitiveKey(String key) {
    const sensitiveKeys = {
      'password',
      'current_password',
      'new_password',
      'confirm_password',
      'old_password',
      'token',
      'access_token',
      'refresh_token',
      'secret',
      'api_key',
      'apikey',
      'authorization',
    };
    return sensitiveKeys.contains(key);
  }

  static String? _previewResponse(dynamic data) {
    if (data == null) return null;

    String s;
    try {
      s = (data is String) ? data : jsonEncode(data);
    } catch (_) {
      s = data.toString();
    }

    if (s.length > 1200) {
      return '${s.substring(0, 1200)}...<trimmed>';
    }
    return s;
  }
}
