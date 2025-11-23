// lib/core/error/exceptions.dart

/// يمثل خطأ قادم من السيرفر (Dio / API).
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ServerException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// أخطاء التخزين المحلي (SharedPreferences مثلاً).
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
