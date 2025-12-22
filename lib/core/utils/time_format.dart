import 'package:flutter/material.dart';

class TimeFormat {
  /// 12-hour Arabic label: 1:05 م / 9:00 ص
  static String timeOfDayAr(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute;

    final isPm = h >= 12;
    final suffix = isPm ? 'م' : 'ص';

    int hour12 = h % 12;
    if (hour12 == 0) hour12 = 12;

    final mm = m.toString().padLeft(2, '0');
    return '$hour12:$mm $suffix';
  }

  /// API format: HH:mm:ss (24-hour) -> "09:00:00"
  static String timeOfDayToApi(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  /// لو عندك وقت سترينغ من API مثل "09:00:00" أو "09:00"
  static String timeStringToAr12(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';

    final parts = s.split(':');
    if (parts.length < 2) return s;

    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    return timeOfDayAr(TimeOfDay(hour: h, minute: m));
  }

  // ✅ Alias عشان ما ينكسر أي كود قديم كان يستعمل to12hAr
  static String to12hAr(String raw) => timeStringToAr12(raw);
}
