// lib/core/error/error_text.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'exceptions.dart';

String errorText(Object err) {
  if (err is ServerException) {
    final m = err.message.trim();
    return m.isEmpty ? 'حدث خطأ غير متوقع. حاول مرة أخرى.' : m;
  }
  if (err is CacheException) {
    final m = err.message.trim();
    return m.isEmpty ? 'حدث خطأ غير متوقع. حاول مرة أخرى.' : m;
  }

  if (err is DioException) return friendlyDioText(err);

  var s = err.toString().trim();

  // تنظيف prefixes شائعة
  s = s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  s = s.replaceFirst(RegExp(r'^DioException.*?:\s*'), '');

  // Dio validateStatus message (اللي بالصورة)
  if (s.contains('validateStatus') && s.contains('status code')) {
    return 'حدث خطأ من الخادم. حاول مرة أخرى لاحقاً.';
  }

  // Failed host lookup (اللي بالصورة)
  if (s.toLowerCase().contains('failed host lookup')) {
    return 'تعذر الاتصال بالخادم. تأكد من الإنترنت أو جرّب لاحقاً.';
  }

  // أخطاء runtime ما بدنا المستخدم يشوفها
  if (s.contains("type 'String' is not a subtype of type")) {
    return 'استجابة غير متوقعة من الخادم. حاول مرة أخرى لاحقاً.';
  }

  if (s.isEmpty) return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  return s;
}

String friendlyDioText(DioException e) {
  final code = e.response?.statusCode;
  final data = e.response?.data;

  // ✅ لو رجع HTML/Cloudflare بدل JSON
  if (data is String) {
    final lower = data.toLowerCase();
    if (lower.contains('<html') || lower.contains('cloudflare')) {
      return 'يوجد عطل مؤقت في الخادم. حاول مرة أخرى بعد قليل.';
    }
  }

  // Socket / DNS (Failed host lookup)
  final msg = (e.message ?? '').toLowerCase();
  if (msg.contains('failed host lookup') ||
      msg.contains('socketexception') ||
      msg.contains('network is unreachable')) {
    return 'تعذر الاتصال بالخادم. تأكد من الإنترنت أو جرّب لاحقاً.';
  }

  // 1) تايم آوت/اتصال
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'انتهت مهلة الاتصال. تأكد من الإنترنت وحاول مرة أخرى.';
  }

  if (e.type == DioExceptionType.connectionError) {
    return 'تعذر الاتصال بالخادم. تأكد من الإنترنت أو جرّب لاحقاً.';
  }

  if (e.type == DioExceptionType.cancel) {
    return 'تم إلغاء الطلب.';
  }

  // 2) Status Codes
  if (code == 530) return 'يوجد عطل مؤقت في الخادم (530). حاول مرة أخرى بعد قليل.';
  if (code == 502 || code == 503 || code == 504) {
    return 'الخدمة غير متاحة حالياً. حاول مرة أخرى بعد قليل.';
  }

  if (code == 401) return 'انتهت الجلسة. أعد تسجيل الدخول.';
  if (code == 403) return 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';
  if (code == 404) return 'المسار غير موجود على الخادم.';
  if (code != null && code >= 500) return 'حدث خطأ من الخادم. حاول مرة أخرى لاحقاً.';

  // 3) رسالة من السيرفر (لو موجودة)
  String serverMsg = '';
  if (data is Map) {
    serverMsg = (data['message']?.toString() ?? '').trim();
  }
if (data is Map) {
    final apiCode = (data['code']?.toString() ?? '').trim();

    if (apiCode == 'SERVICE_HAS_CONFIRMED_BOOKINGS') {
      return 'لا يمكن تعديل الباقات لأن هذه الخدمة لديها حجوزات مؤكدة.';
    }
  }
  if (serverMsg.isNotEmpty) {
    if (serverMsg == 'account_activated') return 'تم تفعيل الحساب';
    if (serverMsg == 'account_deactivated') return 'تم تعطيل الحساب';
    if (serverMsg == 'email_cannot_be_empty') return 'السيرفر يتطلب إرسال البريد الإلكتروني مع أي تعديل.';
    return serverMsg;
  }

  // 4) خطأ IO خام
  if (e.error is SocketException || e.error is IOException) {
    return 'تعذر الاتصال بالخادم. تأكد من الإنترنت أو جرّب لاحقاً.';
  }

  return 'حدث خطأ بالشبكة، حاول مرة أخرى.';
}
