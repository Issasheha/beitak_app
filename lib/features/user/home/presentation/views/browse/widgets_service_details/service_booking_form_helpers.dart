import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';

/// ✅ Source of truth locally (backend no longer reliable for this field)
const int kMinAdvanceBookingHours = 12;

DateTime todayDateOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int minutesOfDay(DateTime dt) => dt.hour * 60 + dt.minute;

int roundUpToStep(int minutes, int step) {
  if (step <= 1) return minutes;
  final r = minutes % step;
  if (r == 0) return minutes;
  return minutes + (step - r);
}

String fmtDate(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

String weekdayKey(DateTime d) {
  switch (d.weekday) {
    case DateTime.monday:
      return 'monday';
    case DateTime.tuesday:
      return 'tuesday';
    case DateTime.wednesday:
      return 'wednesday';
    case DateTime.thursday:
      return 'thursday';
    case DateTime.friday:
      return 'friday';
    case DateTime.saturday:
      return 'saturday';
    case DateTime.sunday:
      return 'sunday';
  }
  return 'monday';
}

Time12Ar formatHmTo12hWithSuffix(String hm) {
  final s = hm.trim();
  final parts = s.split(':');
  if (parts.length < 2) return const Time12Ar(label: '—', suffix: '—');

  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;

  final isPm = h >= 12;
  final suffix = isPm ? 'م' : 'ص';

  int hour12 = h % 12;
  if (hour12 == 0) hour12 = 12;

  final mm = m.toString().padLeft(2, '0');
  return Time12Ar(label: '$hour12:$mm', suffix: suffix);
}

String toTimeWithSeconds(String hm) {
  final s = hm.trim();
  final parts = s.split(':');
  if (parts.length == 2) {
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
  }
  if (parts.length >= 3) {
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0')}';
  }
  return '09:00:00';
}

Set<String> safeAvailableDateSet(dynamic state) {
  String? extractDate(String s) {
    s = s.trim();
    if (s.isEmpty) return null;
    final match = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(s);
    if (match != null) return match.group(0);
    return null;
  }

  void addOne(dynamic v, Set<String> out) {
    if (v == null) return;

    if (v is Map) {
      final raw = v['date'] ?? v['day_date'] ?? v['booking_date'] ?? v['dayDate'];
      if (raw != null) {
        final d = extractDate(raw.toString());
        if (d != null && d.isNotEmpty) out.add(d);
      }
      return;
    }

    final d = extractDate(v.toString());
    if (d != null && d.isNotEmpty) out.add(d);
  }

  Set<String> normalize(dynamic raw) {
    final out = <String>{};
    if (raw is Iterable) {
      for (final v in raw) {
        addOne(v, out);
      }
    } else {
      addOne(raw, out);
    }
    return out;
  }

  try {
    final raw = (state as dynamic).availableDates;
    final normalized = normalize(raw);
    if (normalized.isNotEmpty) return normalized;
  } catch (_) {}

  try {
    final raw = (state as dynamic).availableDays;
    final normalized = normalize(raw);
    if (normalized.isNotEmpty) return normalized;
  } catch (_) {}

  return <String>{};
}

List<String> buildTimeSlots(
  String start,
  String end, {
  required int durationMinutes,
  int stepMinutes = 30,
  int? minStartMinutes,
}) {
  int? parseToMin(String v) {
    final s = v.trim();
    if (s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return h * 60 + m;
  }

  String fmt(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  final a0 = parseToMin(start);
  final b = parseToMin(end);
  if (a0 == null || b == null) return const [];
  if (b <= a0) return const [];

  final a = (minStartMinutes == null) ? a0 : (minStartMinutes > a0 ? minStartMinutes : a0);

  final lastStart = b - durationMinutes;
  if (lastStart < a) return const [];

  final out = <String>[];
  for (int t = a; t <= lastStart; t += stepMinutes) {
    out.add(fmt(t));
  }
  return out;
}

bool hasAnySlotForDay({
  required ServiceDetails service,
  required DateTime dateOnly,
  required int minAdvanceHours,
}) {
  final provider = service.provider;
  final dayKey = weekdayKey(dateOnly);
  final day = provider.dayHours(dayKey);

  if (day != null && day.active == false) return false;

  final start = (day?.start ?? provider.workingHours.start);
  final end = (day?.end ?? provider.workingHours.end);

  int? parseToMin(String v) {
    final s = v.trim();
    if (s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  final startMin0 = parseToMin(start);
  final endMin = parseToMin(end);
  if (startMin0 == null || endMin == null) return false;
  if (endMin <= startMin0) return false;

  final durationHours = service.durationHours <= 0 ? 1.0 : service.durationHours;
  final durationMinutes = (durationHours * 60).round();

  const stepMinutes = 30;

  final now = DateTime.now();
  final earliestAllowed = now.add(Duration(hours: minAdvanceHours));

  int? minStartMinutes;
  final earliestDateOnly = DateTime(earliestAllowed.year, earliestAllowed.month, earliestAllowed.day);

  if (isSameDay(dateOnly, earliestDateOnly)) {
    minStartMinutes = roundUpToStep(minutesOfDay(earliestAllowed), stepMinutes);
  } else if (minAdvanceHours <= 0 && isSameDay(dateOnly, todayDateOnly())) {
    minStartMinutes = roundUpToStep(minutesOfDay(now), stepMinutes);
  }

  final startMin = (minStartMinutes == null) ? startMin0 : (minStartMinutes > startMin0 ? minStartMinutes : startMin0);

  final lastStart = endMin - durationMinutes;
  return lastStart >= startMin;
}

class Time12Ar {
  final String label;
  final String suffix;
  const Time12Ar({required this.label, required this.suffix});
}
