import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';
import 'package:flutter/material.dart';

class BookingCardUtils {
  BookingCardUtils._();

  // ---------- Placeholder / clean ----------
  static bool isPlaceholder(String s) {
    final x = s.trim().toLowerCase();
    return x.isEmpty ||
        x == 'n/a' ||
        x == 'na' ||
        x == 'none' ||
        x == 'null' ||
        x == '-' ||
        x == '—';
  }

  static String clean(String? s) {
    final v = (s ?? '').trim();
    if (v.isEmpty) return '';
    if (isPlaceholder(v)) return '';
    return v;
  }

  /// ✅ "amman, abdoun" أو "amman - abdoun" أو "amman، abdoun"
  static List<String> splitCityArea(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return const [];

    var norm = s;
    norm = norm.replaceAll('،', ',');
    norm = norm.replaceAll(' - ', '-');
    norm = norm.replaceAll(' — ', '-');

    List<String> parts;
    if (norm.contains(',')) {
      parts = norm.split(',');
    } else if (norm.contains('-')) {
      parts = norm.split('-');
    } else {
      parts = [norm];
    }

    parts = parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (parts.length == 1) return ['', parts[0]];
    return [parts[0], parts[1]];
  }

  // ---------- Time & Date ----------
  static String time12hArLong(String hhmmss) {
    final s = hhmmss.trim();
    if (s.isEmpty) return '—';

    final parts = s.split(':');
    if (parts.length < 2) return s;

    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    final isPm = h >= 12;
    final suffix = isPm ? 'مساء' : 'صباحاً';

    int hour12 = h % 12;
    if (hour12 == 0) hour12 = 12;

    final mm = m.toString().padLeft(2, '0');
    return '$hour12:$mm $suffix';
  }

  static String dateArLong(String isoDate) {
    final d = DateTime.tryParse(isoDate.trim());
    if (d == null) return isoDate.trim().replaceAll('-', '/');

    const months = <String>[
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final m = (d.month >= 1 && d.month <= 12) ? months[d.month - 1] : d.month;
    return '${d.day} $m ${d.year}';
  }

  // ---------- Avatar ----------
  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'م';

    String firstChar(String s) {
      final t = s.trim();
      if (t.isEmpty) return '';
      return t.characters.first.toUpperCase();
    }

    final a = firstChar(parts[0]);
    final b = parts.length > 1 ? firstChar(parts[1]) : '';
    final out = (a + b).trim();
    return out.isEmpty ? 'م' : out;
  }

  static Color avatarColor(String seed) {
    const palette = <Color>[
      Color(0xFF22C55E),
      Color(0xFF10B981),
      Color(0xFF06B6D4),
      Color(0xFF3B82F6),
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFF97316),
      Color(0xFFEF4444),
      Color(0xFF14B8A6),
      Color(0xFFA3A3A3),
    ];

    final s = seed.trim().isEmpty ? 'NA' : seed.trim();
    int hash = 0;
    for (final codeUnit in s.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return palette[hash % palette.length];
  }

  static bool hasContactInfo(ProviderBookingModel b) {
    final p = (b.customerPhone ?? '').trim();
    final e = (b.customerEmail ?? '').trim();
    return p.isNotEmpty || e.isNotEmpty;
  }

  // ---------- Price ----------
  static String priceTextAr(dynamic totalPrice) {
    final raw = (totalPrice ?? '').toString().trim();
    if (raw.isEmpty) return '';

    final v = double.tryParse(raw);
    if (v == null) return '$raw د.أ';

    final asInt = v.truncateToDouble() == v;
    final numText = asInt ? v.toInt().toString() : v.toStringAsFixed(2);
    return '$numText د.أ';
  }

  // ---------- Category icon ----------
  static String serviceIconFromServiceName(String serviceNameAr) {
    final key = FixedServiceCategories.keyFromAnyString(serviceNameAr);
    switch (key) {
      case 'electricity':
        return '⚡';
      case 'plumbing':
        return '🔧';
      case 'cleaning':
        return '🧹';
      case 'home_maintenance':
        return '🛠️';
      case 'appliance_maintenance':
        return '🧺';
      default:
        return '🧰';
    }
  }
}
