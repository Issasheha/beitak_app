import 'package:beitak_app/core/utils/number_format.dart';

class ServiceDetailsFormatters {
  ServiceDetailsFormatters._();

  static bool hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  static String onlyArabicCity(String raw) {
    var r = raw.trim();
    if (r.isEmpty) return '';

    r = r.split(',').first.trim();
    r = r.split('،').first.trim();

    if (hasArabic(r)) return r;

    final k = r.toLowerCase().trim();
    const map = <String, String>{
      'amman': 'عمان',
      'zarqa': 'الزرقاء',
      'irbid': 'إربد',
      'aqaba': 'العقبة',
      'salt': 'السلط',
      'madaba': 'مادبا',
      'jerash': 'جرش',
      'mafraq': 'المفرق',
      'karak': 'الكرك',
      'tafileh': 'الطفيلة',
      'maan': 'معان',
      'ajloun': 'عجلون',
      'dubai': 'دبي',
    };

    return map[k] ?? '';
  }

  // =========================
  // ✅ Bidi helpers (تثبيت الاتجاه)
  // =========================
  static String _ltrIsolate(String s) => '\u2066$s\u2069'; // LTR isolate
  static String _rtlIsolate(String s) => '\u2067$s\u2069'; // RTL isolate

  static String _normalizeAmPm(String s) {
    return s
        .trim()
        .replaceAll('صباحاً', 'ص')
        .replaceAll('مساءً', 'م')
        .replaceAll('PM', 'م')
        .replaceAll('AM', 'ص');
  }

  /// ✅ time: دائماً Prefix: "م 3:00" / "ص 10:30"
  static String timePrefix(String raw) {
    final r0 = _normalizeAmPm(raw);
    if (r0.isEmpty) return '';

    // Prefix: "م3:00" / "م 3:00"
    final mPrefix =
        RegExp(r'^([صم])\s*([0-9]{1,2}:[0-9]{2})$').firstMatch(r0);
    if (mPrefix != null) {
      final suf = mPrefix.group(1)!;
      final time = mPrefix.group(2)!;
      return '${_rtlIsolate(suf)} ${_ltrIsolate(time)}';
    }

    // Suffix: "3:00 م" -> convert to prefix
    final mSuffix =
        RegExp(r'^([0-9]{1,2}:[0-9]{2})\s*([صم])$').firstMatch(r0);
    if (mSuffix != null) {
      final time = mSuffix.group(1)!;
      final suf = mSuffix.group(2)!;
      return '${_rtlIsolate(suf)} ${_ltrIsolate(time)}';
    }

    // API: "14:00:00" أو "14:00"
    final parts = r0.split(':');
    if (parts.length >= 2) {
      int h = int.tryParse(parts[0]) ?? 0;
      final mm = (parts[1]).padLeft(2, '0');

      final isPm = h >= 12;
      final suf = isPm ? 'م' : 'ص';

      int hour12 = h % 12;
      if (hour12 == 0) hour12 = 12;

      final time = '$hour12:$mm';
      return '${_rtlIsolate(suf)} ${_ltrIsolate(time)}';
    }

    return _ltrIsolate(r0);
  }

  /// ✅ money: دائماً Prefix: "د.أ 80"
  static String moneyJodPrefix(double v) {
    final m = NumberFormat.money(v);
    return '${_rtlIsolate('د.أ')} ${_ltrIsolate(m)}';
  }

  static String incompleteNoteArabic(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '';
    if (hasArabic(r)) return r;

    final lower = r.toLowerCase();
    if (lower.contains('automatically marked as incomplete')) {
      final isoMatch = RegExp(r'on\s+([0-9T:\.\-Z]+)').firstMatch(r);
      final hoursMatch = RegExp(r'\(([\d\.]+)\s*hours').firstMatch(r);

      final iso = isoMatch?.group(1) ?? '';
      final hours = hoursMatch?.group(1) ?? '';

      String when = '';
      if (iso.isNotEmpty && iso.contains('T')) {
        final parts = iso.split('T');
        final date = parts[0];
        final time = parts[1].replaceAll('Z', '');
        final hhmm = time.length >= 5 ? time.substring(0, 5) : time;
        when = '${NumberFormat.smart(date)} ${NumberFormat.smart(hhmm)}';
      } else if (iso.isNotEmpty) {
        when = NumberFormat.smart(iso);
      }

      final hoursText = hours.isEmpty ? '' : NumberFormat.smart(hours);

      final w = when.isEmpty ? '' : ' بتاريخ $when';
      final h = hoursText.isEmpty ? '' : ' بعد تأخر $hoursText ساعة عن الموعد';

      return 'تم تحويل الحجز إلى "غير مكتمل"$w$h.';
    }

    return 'ملاحظة: $r';
  }
}
