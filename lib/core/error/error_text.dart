import 'package:dio/dio.dart';
import 'exceptions.dart';

String errorText(Object err) {
  // لو Server/Cache -> رح يطلع نص عربي مباشرة (لأن toString رجع message)
  if (err is ServerException) return err.message.trim().isEmpty ? 'حدث خطأ غير متوقع. حاول مرة أخرى.' : err.message;
  if (err is CacheException) return err.message.trim().isEmpty ? 'حدث خطأ غير متوقع. حاول مرة أخرى.' : err.message;

  // DioException مباشرة
  if (err is DioException) return friendlyDioText(err);

  // تنظيف prefixes شائعة
  var s = err.toString().trim();

  s = s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  s = s.replaceFirst(RegExp(r'^DioException.*?:\s*'), '');

  // أخطاء runtime ما بدنا المستخدم يشوفها
  if (s.contains("type 'String' is not a subtype of type 'int' of 'index'")) {
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
  String msg = '';
  if (data is Map) {
    msg = (data['message']?.toString() ?? '').trim();
  }

  if (msg.isNotEmpty) {
    if (msg == 'account_activated') return 'تم تفعيل الحساب';
    if (msg == 'account_deactivated') return 'تم تعطيل الحساب';
    if (msg == 'email_cannot_be_empty') return 'السيرفر يتطلب إرسال البريد الإلكتروني مع أي تعديل.';
    return msg;
  }

  return 'حدث خطأ بالشبكة، حاول مرة أخرى.';
}
