class ServiceDetailsResponse {
  final ServiceDetails service;

  const ServiceDetailsResponse({required this.service});

  factory ServiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>();
    final serviceJson =
        (data?['service'] as Map?)?.cast<String, dynamic>() ??
        (json['service'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return ServiceDetailsResponse(service: ServiceDetails.fromJson(serviceJson));
  }
}

class ServiceDetails {
  final int id;
  final int providerId;
  final int? categoryId;

  final String name;
  final String description;

  final double basePrice;
  final String priceType;
  final double durationHours;

  final List<ServicePackage> packages;
  final List<ServiceAddOn> addOns;

  final int minAdvanceBookingHours;
  final int maxAdvanceBookingDays;

  final ProviderDetails provider;

  const ServiceDetails({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.priceType,
    required this.durationHours,
    required this.packages,
    required this.addOns,
    required this.minAdvanceBookingHours,
    required this.maxAdvanceBookingDays,
    required this.provider,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    final packagesRaw = (json['packages'] as List?) ?? const [];
    final addOnsRaw = (json['add_ons'] as List?) ?? const [];

    return ServiceDetails(
      id: _asInt(json['id']),
      providerId: _asInt(json['provider_id']),
      categoryId:
          json['category_id'] == null ? null : _asInt(json['category_id']),
      name: _asString(json['name_localized'] ?? json['name'] ?? ''),
      description: _asString(
          json['description_localized'] ?? json['description'] ?? ''),
      basePrice: _asDouble(json['base_price']),
      priceType: _asString(json['price_type'] ?? 'fixed'),
      durationHours: _asDouble(json['duration_hours']),
      packages: packagesRaw
          .whereType<Map>()
          .map((e) => ServicePackage.fromJson(e.cast<String, dynamic>()))
          .toList(),
      addOns: addOnsRaw
          .whereType<Map>()
          .map((e) => ServiceAddOn.fromJson(e.cast<String, dynamic>()))
          .toList(),
      minAdvanceBookingHours: _asInt(json['min_advance_booking_hours'] ?? 0),
      maxAdvanceBookingDays: _asInt(json['max_advance_booking_days'] ?? 30),
      provider: ProviderDetails.fromJson(
        (json['provider'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
    );
  }
}

class ProviderDayHours {
  final String start; // HH:mm
  final String end; // HH:mm
  final bool active;

  const ProviderDayHours({
    required this.start,
    required this.end,
    required this.active,
  });

  factory ProviderDayHours.fromJson(Map<String, dynamic> json) {
    return ProviderDayHours(
      start: _normalizeHm(_asString(json['start'] ?? '09:00')),
      end: _normalizeHm(_asString(json['end'] ?? '18:00')),
      active: json['active'] == true,
    );
  }
}

class ProviderDetails {
  final int id;
  final String businessName;
  final double ratingAvg;
  final int ratingCount;

  final List<String> availableDays; // monday..sunday

  /// ✅ NEW: working hours per day (monday..sunday) with active
  final Map<String, ProviderDayHours> workingHoursByDay;

  /// ✅ keep legacy (used by older UI) - will fallback to first active day
  final WorkingHours workingHours;

  final List<String> serviceAreas; // abdoun...
  final bool instantBooking;

  final String firstName;
  final String lastName;

  final String bio;
  final int experienceYears;
  final DateTime? createdAt;

  const ProviderDetails({
    required this.id,
    required this.businessName,
    required this.ratingAvg,
    required this.ratingCount,
    required this.availableDays,
    required this.workingHoursByDay,
    required this.workingHours,
    required this.serviceAreas,
    required this.instantBooking,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.experienceYears,
    required this.createdAt,
  });

  factory ProviderDetails.fromJson(Map<String, dynamic> json) {
    final user =
        (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    final whRaw = (json['working_hours'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    final availableDays = ((json['available_days'] as List?) ?? const [])
        .map((e) => e.toString().toLowerCase().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final byDay = _parseWorkingHoursByDay(whRaw);

    // legacy fallback: لو السيرفر رجع {start,end} فقط أو ما رجع أيام
    ProviderDayHours? generic;
    for (final k in _weekKeys) {
      final d = byDay[k];
      if (d != null && d.active) {
        generic = d;
        break;
      }
    }
    generic ??= byDay.values.isNotEmpty ? byDay.values.first : null;

    final legacyStart = _normalizeHm(_asString(whRaw['start'] ?? '09:00'));
    final legacyEnd = _normalizeHm(_asString(whRaw['end'] ?? '18:00'));

    final wh = WorkingHours(
      start: _normalizeHm(generic?.start ?? legacyStart),
      end: _normalizeHm(generic?.end ?? legacyEnd),
    );

    return ProviderDetails(
      id: _asInt(json['id']),
      businessName: _asString(json['business_name'] ?? ''),
      ratingAvg: _asDouble(json['rating_avg']),
      ratingCount: _asInt(json['rating_count']),
      availableDays: availableDays,
      workingHoursByDay: byDay,
      workingHours: wh,
      serviceAreas: ((json['service_areas'] as List?) ?? const [])
          .map((e) => e.toString().toLowerCase().trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      instantBooking: (json['instant_booking'] == true),
      firstName: _asString(user['first_name'] ?? ''),
      lastName: _asString(user['last_name'] ?? ''),
      bio: _asString(json['bio_localized'] ?? json['bio'] ?? ''),
      experienceYears: _asInt(json['experience_years'] ?? 0),
      createdAt: _parseDate(json['created_at']),
    );
  }

  String get displayName {
    final full = ('$firstName $lastName').trim();
    return full.isEmpty ? businessName : full;
  }

  String get memberSinceLabel {
    final d = createdAt;
    if (d == null) return '—';
    return '${d.year}';
  }

  ProviderDayHours? dayHours(String dayKey) {
    final k = dayKey.toLowerCase().trim();
    return workingHoursByDay[k];
  }

  bool isDateAvailable(DateTime date) {
    final key = _weekdayKey(date);
    final inList = availableDays.isEmpty ? true : availableDays.contains(key);

    final dh = workingHoursByDay.isEmpty ? null : workingHoursByDay[key];
    final active = (dh == null) ? true : dh.active;

    return inList && active;
  }
}

class WorkingHours {
  final String start; // HH:mm
  final String end; // HH:mm

  const WorkingHours({required this.start, required this.end});
}

class ServicePackage {
  final String name;
  final double price;
  final List<String> features;
  final String description;

  const ServicePackage({
    required this.name,
    required this.price,
    required this.features,
    required this.description,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    return ServicePackage(
      name: _asString(json['name'] ?? ''),
      price: _asDouble(json['price']),
      features: ((json['features'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      description: _asString(json['description'] ?? ''),
    );
  }
}

class ServiceAddOn {
  final String name;
  final double price;
  final String description;

  const ServiceAddOn({
    required this.name,
    required this.price,
    required this.description,
  });

  factory ServiceAddOn.fromJson(Map<String, dynamic> json) {
    return ServiceAddOn(
      name: _asString(json['name'] ?? ''),
      price: _asDouble(json['price']),
      description: _asString(json['description'] ?? ''),
    );
  }
}

// ---------- helpers ----------
const _weekKeys = <String>[
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

String _weekdayKey(DateTime d) {
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
    default:
      return 'monday';
  }
}

Map<String, ProviderDayHours> _parseWorkingHoursByDay(
  Map<String, dynamic> whRaw,
) {
  final out = <String, ProviderDayHours>{};

  // إذا كان working_hours بالشكل الجديد: {monday:{start,end,active}, ...}
  bool hasWeekKeys = false;
  for (final k in _weekKeys) {
    if (whRaw[k] is Map) {
      hasWeekKeys = true;
      break;
    }
  }

  if (hasWeekKeys) {
    for (final k in _weekKeys) {
      final v = whRaw[k];
      if (v is Map) {
        out[k] = ProviderDayHours.fromJson(v.cast<String, dynamic>());
      }
    }
    return out;
  }

  // fallback: {start,end} فقط
  final start = _normalizeHm(_asString(whRaw['start'] ?? '09:00'));
  final end = _normalizeHm(_asString(whRaw['end'] ?? '18:00'));
  for (final k in _weekKeys) {
    out[k] = ProviderDayHours(start: start, end: end, active: true);
  }
  return out;
}

String _normalizeHm(String v) {
  final s = v.trim();
  if (s.isEmpty) return '09:00';
  final parts = s.split(':');
  if (parts.length < 2) return s;
  final h = parts[0].padLeft(2, '0');
  final m = parts[1].padLeft(2, '0');
  return '$h:$m';
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic v) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0.0;
}

String _asString(dynamic v) => (v ?? '').toString();

DateTime? _parseDate(dynamic v) {
  final s = (v ?? '').toString().trim();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}
