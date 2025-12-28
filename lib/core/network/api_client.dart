// lib/core/network/api_client.dart

import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'api_constants.dart';
import 'token_provider.dart';

class ApiClient {
  ApiClient._();

  // ✅ CookieJar (in-memory) لحفظ/إرسال cookies تلقائيًا (مهم للـ refresh-token إذا كان cookie-based)
  static final CookieJar _cookieJar = CookieJar();

  // ✅ Dio واحد أساسي
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.apiBase, // http://.../api
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  )
    // ✅ IMPORTANT: هذا لازم يكون قبل InterceptorsWrapper عشان الـ cookies تنحفظ وتتنرسل تلقائيًا
    ..interceptors.add(CookieManager(_cookieJar))
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

          // ✅ (اختياري للتأكد): اطبع Set-Cookie لو موجود
          // final setCookie = response.headers.map['set-cookie'];
          // if (setCookie != null && setCookie.isNotEmpty) {
          //   // ignore: avoid_print
          //   print('│ Set-Cookie: ${setCookie.join(' | ')}');
          // }

          handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logError(e);

          // ✅ فقط 401 => جرّب refresh + retry
          final status = e.response?.statusCode;
          final req = e.requestOptions;

          // لا تعمل refresh لو هذا الطلب نفسه هو refresh أو إذا في flag منع
          final isRefreshCall = _isRefreshRequest(req);
          final alreadyRetried = req.extra['retried'] == true;

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

  // ----------------- Refresh guard -----------------

  static bool _isRefreshing = false;
  static final List<void Function(String)> _refreshQueue = [];

  static bool _isRefreshRequest(RequestOptions o) {
    final p = o.path.toLowerCase();
    return p.contains('/auth/refresh-token');
  }

  static Future<String> _refreshToken() async {
    // ✅ لو refresh شغال حالياً: استنى نتيجته بدل ما تبعت 10 refresh بنفس الوقت
    if (_isRefreshing) {
      String? token;
      _refreshQueue.add((t) => token = t);

      while (token == null) {
        await Future.delayed(const Duration(milliseconds: 30));
      }
      return token!;
    }

    _isRefreshing = true;

    try {
      // ✅ مهم: skipAuth حتى ما يدخل في 401 loop
      final res = await dio.post(
        '/auth/refresh-token',
        options: Options(extra: {'skipAuth': true}),
      );

      final data = res.data;
      final token = (data is Map && data['data'] is Map)
          ? (data['data']['token']?.toString() ?? '')
          : '';

      if (token.trim().isEmpty) {
        throw Exception('Refresh-token response missing token');
      }

      // ✅ أي طلبات ناطرين refresh نعطيهم نفس التوكن
      for (final fn in _refreshQueue) {
        fn(token);
      }
      _refreshQueue.clear();

      return token;
    } finally {
      _isRefreshing = false;
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

  // ----------------- Logs -----------------

  static void _logRequest(RequestOptions o) {
    final auth = (o.headers['Authorization'] ?? '').toString();
    final maskedAuth = _maskBearer(auth);

    final headers = Map<String, dynamic>.from(o.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = maskedAuth;
    }

    final dataPreview = _previewBody(o.data);

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
    final ro = e.requestOptions;

    final auth = (ro.headers['Authorization'] ?? '').toString();
    final maskedAuth = _maskBearer(auth);

    final headers = Map<String, dynamic>.from(ro.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = maskedAuth;
    }

    final reqBody = _previewBody(ro.data);
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

  static String? _previewBody(dynamic data) {
    if (data == null) return null;

    if (data is FormData) {
      final fields = data.fields.map((e) => '${e.key}=${e.value}').toList();
      final files = data.files.map((e) => e.key).toList();
      return 'FormData(fields=${fields.take(20).toList()}, files=$files)';
    }

    if (data is Map || data is List) {
      try {
        return jsonEncode(data);
      } catch (_) {
        return data.toString();
      }
    }

    return data.toString();
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
