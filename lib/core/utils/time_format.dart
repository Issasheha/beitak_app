class TimeFormat {
  /// Converts "HH:mm:ss" or "HH:mm" into "h:mm ص/م"
  /// Examples:
  ///  - "09:00:00" -> "9:00 ص"
  ///  - "13:05:00" -> "1:05 م"
  ///  - "00:15"    -> "12:15 ص"
  static String to12hAr(String hhmmss) {
    final s = (hhmmss).trim();
    if (s.isEmpty) return '—';

    final parts = s.split(':');
    if (parts.length < 2) return s;

    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    final isPm = h >= 12;
    final suffix = isPm ? 'م' : 'ص';

    int hour12 = h % 12;
    if (hour12 == 0) hour12 = 12;

    final mm = m.toString().padLeft(2, '0');
    return '$hour12:$mm $suffix';
  }
}
