// lib/features/provider/home/presentation/views/bookings/viewmodels/provider_availability_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';

@immutable
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({required this.start, required this.end});

  String format(BuildContext context) =>
      '${start.format(context)} - ${end.format(context)}';

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

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  factory AvailabilityException.closedDay(DateTime date) =>
      AvailabilityException._(
        date: dateOnly(date),
        type: AvailabilityExceptionType.closedDay,
        available: false,
        range: null,
      );

  factory AvailabilityException.customHours(DateTime date, TimeRange range) =>
      AvailabilityException._(
        date: dateOnly(date),
        type: AvailabilityExceptionType.customHours,
        available: true,
        range: range,
      );
}

class ProviderAvailabilityViewModel extends ChangeNotifier {
  ProviderAvailabilityViewModel() {
    _weekly = _buildDefaultWeekly();
    _originalSignature = _computeSignature(); // baseline
  }

  final Dio _dio = ApiClient.dio;

  bool isLoading = false;
  bool isSaving = false;

  late Map<int, WeeklyDayAvailability> _weekly; // key weekday (1..7)
  final Map<DateTime, AvailabilityException> _exceptions = {}; // key dateOnly

  Map<int, WeeklyDayAvailability> get weekly => _weekly;
  Map<DateTime, AvailabilityException> get exceptions => _exceptions;

  // ==== QA: change tracking ====
  late String _originalSignature;

  bool get hasChanges => _computeSignature() != _originalSignature;

  void _commitSnapshot() {
    _originalSignature = _computeSignature();
  }

  String _computeSignature() {
    // weekly: weekday|available|start-end
    final weeklyParts = <String>[];
    final keys = _weekdayIntToApiName.keys.toList()..sort();
    for (final w in keys) {
      final day = _weekly[w] ??
          WeeklyDayAvailability(
            weekday: w,
            available: false,
            range: _defaultRange(),
          );
      final r = day.range ?? _defaultRange();
      final rangePart = '${_formatTime(r.start)}-${_formatTime(r.end)}';
      weeklyParts.add('$w|${day.available ? 1 : 0}|$rangePart');
    }

    // exceptions: only closed days (yyyy-mm-dd)
    final closed = _exceptions.values
        .where((e) => e.type == AvailabilityExceptionType.closedDay)
        .map((e) => _formatDate(e.date))
        .toList()
      ..sort();

    return 'W:${weeklyParts.join(",")};C:${closed.join(",")}';
  }

  /// ✅ QA: validate before saving
  /// يرجّع null إذا تمام، أو رسالة جاهزة للعرض إذا في مشكلة
  String? validateForSave() {
    // weekly ranges must be valid if day is enabled
    for (final entry in _weekdayIntToApiName.entries) {
      final weekday = entry.key;
      final label = entry.value; // Sunday/Monday.. (مش مهم للعرض الآن)

      final day = _weekly[weekday];
      if (day == null) continue;

      if (day.available) {
        final r = day.range ?? _defaultRange();
        if (!r.isValid) {
          // رسالة عربي واضحة للمستخدم
          return 'وقت النهاية يجب أن يكون بعد وقت البداية.';
        }
      }
    }
    return null;
  }

  // ---------------- mapping بين أسماء الأيام و int ----------------

  // نستخدم lower-case للقراءة من الـ GET (Sunday → sunday → 7)
  static const Map<String, int> _weekdayNameToInt = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7,
  };

  // نستخدم PascalCase للإرسال (نطابق الويب)
  static const Map<int, String> _weekdayIntToApiName = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _dateOnly(DateTime d) => AvailabilityException.dateOnly(d);

  // ---------------- API: LOAD ----------------

  Future<void> loadFromApi() async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await _dio.get(ApiConstants.providerAvailability);
      final data = (res.data ?? {})['data'] as Map<String, dynamic>? ?? {};

      // working_hours
      final wh = data['working_hours'] as Map<String, dynamic>? ?? {};

      final Map<int, WeeklyDayAvailability> weekly = {};

      wh.forEach((key, value) {
        final v = value as Map<String, dynamic>? ?? {};
        final dayKey = key.toString().toLowerCase(); // Sunday / sunday
        final weekday = _weekdayNameToInt[dayKey];
        if (weekday == null) return;

        // السيرفر أحيانًا يرجّع enabled، وأحيانًا active
        final enabled =
            (v['enabled'] as bool?) ?? (v['active'] as bool?) ?? false;

        final startStr = v['start'] as String?;
        final endStr = v['end'] as String?;

        TimeRange? range;
        if (startStr != null && endStr != null) {
          final start = _parseTime(startStr);
          final end = _parseTime(endStr);
          range = TimeRange(start: start, end: end);
        }

        weekly[weekday] = WeeklyDayAvailability(
          weekday: weekday,
          available: enabled,
          range: range ?? _defaultRange(),
        );
      });

      // نتأكد إنه كل الأيام موجودة
      for (final entry in _weekdayIntToApiName.entries) {
        final w = entry.key;
        weekly[w] = weekly[w] ??
            WeeklyDayAvailability(
              weekday: w,
              available: false,
              range: _defaultRange(),
            );
      }

      _weekly = weekly;

      // unavailable_dates → exceptions closedDay
      _exceptions.clear();
      final rawDates = data['unavailable_dates'] as List<dynamic>? ?? [];
      for (final raw in rawDates) {
        final s = raw.toString();
        try {
          final dt = DateTime.parse(s);
          final dOnly = _dateOnly(dt);
          _exceptions[dOnly] = AvailabilityException.closedDay(dOnly);
        } catch (_) {
          if (kDebugMode) {
            debugPrint('Failed to parse unavailable date: $s');
          }
        }
      }

      // ✅ بعد التحميل: اعتبره baseline (بدون تغييرات)
      _commitSnapshot();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('loadFromApi error: $e\n$st');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- API: SAVE (PUT) ----------------

  Future<bool> saveToApi() async {
    isSaving = true;
    notifyListeners();

    try {
      final Map<String, dynamic> workingHoursJson = {};

      for (final entry in _weekdayIntToApiName.entries) {
        final weekday = entry.key;
        final apiName = entry.value;

        final day = _weekly[weekday] ??
            WeeklyDayAvailability(
              weekday: weekday,
              available: false,
              range: _defaultRange(),
            );

        final range = day.range ?? _defaultRange();

        workingHoursJson[apiName] = {
          'start': _formatTime(range.start),
          'end': _formatTime(range.end),
          'enabled': day.available,
        };
      }

      final closedDates = _exceptions.values
          .where((ex) => ex.type == AvailabilityExceptionType.closedDay)
          .map((ex) => _formatDate(ex.date))
          .toSet()
          .toList();

      final body = {
        'working_hours': workingHoursJson,
        'unavailable_dates': closedDates,
      };

      await _dio.put(
        ApiConstants.providerAvailability,
        data: body,
      );

      // ✅ إذا حفظنا بنجاح: اعتمد snapshot جديد
      _commitSnapshot();

      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('saveToApi error: $e\n$st');
      }
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ---------------- Weekly (local) ----------------

  void toggleWeeklyDay(int weekday, bool available) {
    final current = _weekly[weekday];
    if (current == null) return;

    final next = current.copyWith(
      available: available,
      range: available ? (current.range ?? _defaultRange()) : current.range,
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

  // ---------------- Exceptions (closed days) ----------------

  AvailabilityException? exceptionOf(DateTime date) {
    return _exceptions[_dateOnly(date)];
  }

  void setExceptionClosed(DateTime date) {
    final key = _dateOnly(date);
    _exceptions[key] = AvailabilityException.closedDay(key);
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
    return _weekly[weekday] ??
        WeeklyDayAvailability(
          weekday: weekday,
          available: false,
          range: _defaultRange(),
        );
  }

  bool isDateAvailable(DateTime date) {
    final ex = exceptionOf(date);
    if (ex != null) return ex.available;
    return weeklyForDate(date).available;
  }

  TimeRange? effectiveRange(DateTime date) {
    final ex = exceptionOf(date);
    if (ex != null && ex.type == AvailabilityExceptionType.customHours) {
      return ex.range;
    }
    final w = weeklyForDate(date);
    return w.available ? w.range : null;
  }

  // ---------------- Defaults ----------------

  static Map<int, WeeklyDayAvailability> _buildDefaultWeekly() {
    final r = _defaultRange();
    return {
      1: WeeklyDayAvailability(weekday: 1, available: false, range: r),
      2: WeeklyDayAvailability(weekday: 2, available: false, range: r),
      3: WeeklyDayAvailability(weekday: 3, available: false, range: r),
      4: WeeklyDayAvailability(weekday: 4, available: false, range: r),
      5: WeeklyDayAvailability(weekday: 5, available: false, range: r),
      6: WeeklyDayAvailability(weekday: 6, available: false, range: r),
      7: WeeklyDayAvailability(weekday: 7, available: false, range: r),
    };
  }

  static TimeRange _defaultRange() => const TimeRange(
        start: TimeOfDay(hour: 9, minute: 0),
        end: TimeOfDay(hour: 17, minute: 0),
      );
}
