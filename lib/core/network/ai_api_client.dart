// lib/core/network/ai_api_client.dart

import 'package:dio/dio.dart';

/// ✅ Dio منفصل للـ AI (FastAPI/ngrok)
/// - ما بنلمس ApiClient الأساسي تبع Node
/// - بيدعم تغيير baseUrl لاحقاً (مفيد لأن ngrok ممكن يتغير)
class AiApiClient {
  AiApiClient._();

  /// 🔗 الافتراضي (بدّله إذا تغيّر ngrok)
  static String _baseUrl = 'https://eugenia-overflorid-nonparadoxically.ngrok-free.dev';

  /// (اختياري) لو قررتوا لاحقًا تستخدموا API Key
  static String? _apiKey;

  /// ✅ Dio instance للـ AI فقط
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // ✅ لو في API Key (مستقبلاً)
          final key = _apiKey;
          if (key != null && key.trim().isNotEmpty) {
            options.headers['x-api-key'] = key.trim();
          }

          // ✅ FastAPI عادة ما بده gzip/deflate مشاكل، بس اتركها افتراضي
          return handler.next(options);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
    );

  /// ✅ تغيير baseUrl وقت التشغيل (لو تغيّر ngrok)
  static void setBaseUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return;

    _baseUrl = u;
    dio.options.baseUrl = _baseUrl;
  }

  /// ✅ تعيين API Key (اختياري للمستقبل)
  static void setApiKey(String? key) {
    final k = key?.trim();
    _apiKey = (k == null || k.isEmpty) ? null : k;
  }

  /// (مساعدة) قراءة baseUrl الحالي
  static String get baseUrl => dio.options.baseUrl;
}
