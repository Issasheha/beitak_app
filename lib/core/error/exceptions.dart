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

  /// ✅ مهم: حتى لو حدا عمل err.toString() ما يطلع "ServerException" ولا أي انجليزي
  @override
  String toString() => message;
}

/// أخطاء التخزين المحلي (SharedPreferences مثلاً).
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  /// ✅ نفس الفكرة: ما نطلع أي prefix انجليزي
  @override
  String toString() => message;
}
