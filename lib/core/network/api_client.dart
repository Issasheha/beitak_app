// lib/core/network/api_client.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'token_provider.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.apiBase, // http://.../api
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenProvider.getToken();

          // ✅ Authorization فقط (لا x-access-token)
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          } else {
            options.headers.remove('Authorization');
          }

          // ====== LOG REQUEST ======
          _logRequest(options);

          handler.next(options);
        },
        onResponse: (response, handler) {
          // ====== LOG RESPONSE ======
          _logResponse(response);
          handler.next(response);
        },
        onError: (DioException e, handler) {
          // ====== LOG ERROR ======
          _logError(e);
          handler.next(e);
        },
      ),
    );

  // ----------------- Logs -----------------

  static void _logRequest(RequestOptions o) {
    // اخفاء التوكن بالكامل، نخلي أول/آخر كم حرف فقط
    final auth = (o.headers['Authorization'] ?? '').toString();
    final maskedAuth = _maskBearer(auth);

    final headers = Map<String, dynamic>.from(o.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = maskedAuth;
    }

    // Body (قد يكون FormData أو Map أو String)
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

    // FormData
    if (data is FormData) {
      final fields = data.fields.map((e) => '${e.key}=${e.value}').toList();
      final files = data.files.map((e) => e.key).toList();
      return 'FormData(fields=${fields.take(20).toList()}, files=$files)';
    }

    // Map/List
    if (data is Map || data is List) {
      try {
        return jsonEncode(data);
      } catch (_) {
        return data.toString();
      }
    }

    // String/other
    return data.toString();
  }

  static String? _previewResponse(dynamic data) {
    if (data == null) return null;

    // حاول نقصه إذا كبير
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
