import 'package:flutter/material.dart';

@immutable
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({required this.start, required this.end});

  String format(BuildContext context) => '${start.format(context)} - ${end.format(context)}';

  int get startMinutes => start.hour * 60 + start.minute;
  int get endMinutes => end.hour * 60 + end.minute;

  bool get isValid => endMinutes > startMinutes;
}

@immutable
class WeeklyDayAvailability {
  final int weekday; // 1=Mon..7=Sun (Dart DateTime)
  final bool available;
  final TimeRange? range;

  const WeeklyDayAvailability({
    required this.weekday,
    required this.available,
    required this.range,
  });

  WeeklyDayAvailability copyWith({
    bool? available,
    TimeRange? range,
  }) {
    return WeeklyDayAvailability(
      weekday: weekday,
      available: available ?? this.available,
      range: range ?? this.range,
    );
  }
}

enum AvailabilityExceptionType { closedDay, customHours }

@immutable
class AvailabilityException {
  final DateTime date; // dateOnly
  final AvailabilityExceptionType type;
  final bool available; // closedDay => false, customHours => true
  final TimeRange? range; // only for customHours

  const AvailabilityException._({
    required this.date,
    required this.type,
    required this.available,
    required this.range,
  });

  // ✅ FIX: helper داخل نفس الـ class
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  factory AvailabilityException.closedDay(DateTime date) => AvailabilityException._(
        date: dateOnly(date),
        type: AvailabilityExceptionType.closedDay,
        available: false,
        range: null,
      );

  factory AvailabilityException.customHours(DateTime date, TimeRange range) => AvailabilityException._(
        date: dateOnly(date),
        type: AvailabilityExceptionType.customHours,
        available: true,
        range: range,
      );
}

class ProviderAvailabilityViewModel extends ChangeNotifier {
  ProviderAvailabilityViewModel() {
    _weekly = _buildDefaultWeekly();
  }

  late Map<int, WeeklyDayAvailability> _weekly; // key weekday (1..7)
  final Map<DateTime, AvailabilityException> _exceptions = {}; // key dateOnly

  Map<int, WeeklyDayAvailability> get weekly => _weekly;
  Map<DateTime, AvailabilityException> get exceptions => _exceptions;

  // ---------------- Weekly ----------------

  void toggleWeeklyDay(int weekday, bool available) {
    final current = _weekly[weekday];
    if (current == null) return;

    final next = current.copyWith(
      available: available,
      range: available ? (current.range ?? _defaultRange()) : null,
    );

    _weekly = {..._weekly, weekday: next};
    notifyListeners();
  }

  void setWeeklyRange(int weekday, TimeRange range) {
    final current = _weekly[weekday];
    if (current == null) return;

    _weekly = {
      ..._weekly,
      weekday: current.copyWith(available: true, range: range),
    };
    notifyListeners();
  }

  // ---------------- Exceptions ----------------

  AvailabilityException? exceptionOf(DateTime date) {
    return _exceptions[_dateOnly(date)];
  }

  void setExceptionClosed(DateTime date) {
    final key = _dateOnly(date);
    _exceptions[key] = AvailabilityException.closedDay(key);
    notifyListeners();
  }

  void setExceptionCustomHours(DateTime date, TimeRange range) {
    final key = _dateOnly(date);
    _exceptions[key] = AvailabilityException.customHours(key, range);
    notifyListeners();
  }

  void clearException(DateTime date) {
    final key = _dateOnly(date);
    if (_exceptions.remove(key) != null) {
      notifyListeners();
    }
  }

  // ---------------- Computed ----------------

  WeeklyDayAvailability weeklyForDate(DateTime date) {
    final weekday = date.weekday; // 1..7
    return _weekly[weekday] ?? WeeklyDayAvailability(weekday: weekday, available: false, range: null);
  }

  bool isDateAvailable(DateTime date) {
    final ex = exceptionOf(date);
    if (ex != null) return ex.available;
    return weeklyForDate(date).available;
  }

  TimeRange? effectiveRange(DateTime date) {
    final ex = exceptionOf(date);
    if (ex != null && ex.type == AvailabilityExceptionType.customHours) return ex.range;
    final w = weeklyForDate(date);
    return w.available ? w.range : null;
  }

  // ---------------- Defaults ----------------

  static Map<int, WeeklyDayAvailability> _buildDefaultWeekly() {
    final r = _defaultRange();
    return {
      1: WeeklyDayAvailability(weekday: 1, available: true, range: r),
      2: WeeklyDayAvailability(weekday: 2, available: true, range: r),
      3: WeeklyDayAvailability(weekday: 3, available: true, range: r),
      4: WeeklyDayAvailability(weekday: 4, available: true, range: r),
      5: WeeklyDayAvailability(weekday: 5, available: true, range: r),
      6: WeeklyDayAvailability(weekday: 6, available: true, range: r),
      7: WeeklyDayAvailability(weekday: 7, available: true, range: r),
    };
  }

  static TimeRange _defaultRange() => const TimeRange(
        start: TimeOfDay(hour: 9, minute: 0),
        end: TimeOfDay(hour: 17, minute: 0),
      );

  static DateTime _dateOnly(DateTime d) => AvailabilityException.dateOnly(d);
}
