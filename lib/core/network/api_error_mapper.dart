import 'package:dio/dio.dart';

class ApiErrorMapper {
  static String toArabic(Object err) {
    // DioException
    if (err is DioException) {
      final data = err.response?.data;

      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        return _fromResponseMap(m);
      }

      // fallback (network, timeout...)
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'انتهت مهلة الاتصال. حاول مرة أخرى.';
        case DioExceptionType.connectionError:
          return 'تعذر الاتصال بالإنترنت. تأكد من الشبكة وحاول مرة أخرى.';
        case DioExceptionType.badCertificate:
          return 'مشكلة في شهادة الأمان (SSL).';
        case DioExceptionType.cancel:
          return 'تم إلغاء الطلب.';
        case DioExceptionType.badResponse:
          return 'تعذر إتمام العملية. حاول مرة أخرى.';
        case DioExceptionType.unknown:
          return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
      }
    }

    // Normal Exception fallback
    final s = err.toString().replaceFirst('Exception: ', '').trim();
    if (s.isEmpty) return 'حدث خطأ غير متوقع';
    return s;
  }

  static String _fromResponseMap(Map<String, dynamic> m) {
    final code = (m['code'] ?? '').toString().trim();
    final msg = (m['message'] ?? '').toString().trim();

    // إذا الباك رجّع عربي أصلاً
    if (_looksArabic(msg)) return msg;

    switch (code) {
      case 'OUTDATED_REQUEST':
        return 'هذا الطلب قديم: تاريخ الخدمة انتهى.';
      case 'OUTDATED_REQUEST_TIME':
        return 'هذا الطلب قديم: وقت الخدمة المحدد مرّ بالفعل.';
      case 'DATE_CONFLICT':
        final d = (m['conflicting_date'] ?? '').toString().trim();
        final bn = (m['existing_booking'] is Map)
            ? ((m['existing_booking']['booking_number'] ?? '').toString().trim())
            : '';
        final dateTxt = d.isEmpty ? '' : ' بتاريخ ${_prettyDate(d)}';
        final bnTxt = bn.isEmpty ? '' : ' (رقم الحجز: $bn)';
        return 'لديك حجز مؤكد$dateTxt. الرجاء مراجعة جدولك.$bnTxt';
      case 'CATEGORY_MISMATCH':
        return 'لا يمكنك قبول هذا الطلب لأن نوع الخدمة المطلوبة لا يطابق خدماتك.';
      case 'REQUEST_ALREADY_ACCEPTED':
        return 'تم قبول هذا الطلب مسبقاً من مزوّد آخر.';
      case 'NOT_FOUND':
        return 'العنصر المطلوب غير موجود.';
      case 'UNAUTHORIZED':
        return 'انتهت الجلسة. الرجاء تسجيل الدخول مرة أخرى.';
      default:
        // fallback: اعرض message لكن بصياغة عربية عامة
        if (msg.isNotEmpty) return msg;
        return 'تعذر إتمام العملية. حاول مرة أخرى.';
    }
  }

  static bool _looksArabic(String s) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(s);
  }

  static String _prettyDate(String iso) {
    // iso = yyyy-MM-dd
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}
