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
      categoryId: json['category_id'] == null ? null : _asInt(json['category_id']),

      name: _asString(json['name_localized'] ?? json['name'] ?? ''),
      description: _asString(json['description_localized'] ?? json['description'] ?? ''),

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
        (json['provider'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
    );
  }
}

class ProviderDetails {
  final int id;
  final String businessName;
  final double ratingAvg;
  final int ratingCount;

  final List<String> availableDays; // monday..sunday
  final WorkingHours workingHours; // start/end HH:mm
  final List<String> serviceAreas; // abdoun...

  final bool instantBooking;

  final String firstName;
  final String lastName;

  const ProviderDetails({
    required this.id,
    required this.businessName,
    required this.ratingAvg,
    required this.ratingCount,
    required this.availableDays,
    required this.workingHours,
    required this.serviceAreas,
    required this.instantBooking,
    required this.firstName,
    required this.lastName,
  });

  factory ProviderDetails.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final wh = (json['working_hours'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    return ProviderDetails(
      id: _asInt(json['id']),
      businessName: _asString(json['business_name'] ?? ''),
      ratingAvg: _asDouble(json['rating_avg']),
      ratingCount: _asInt(json['rating_count']),

      availableDays: ((json['available_days'] as List?) ?? const [])
          .map((e) => e.toString().toLowerCase().trim())
          .where((e) => e.isNotEmpty)
          .toList(),

      workingHours: WorkingHours(
        start: _asString(wh['start'] ?? '09:00'),
        end: _asString(wh['end'] ?? '18:00'),
      ),

      serviceAreas: ((json['service_areas'] as List?) ?? const [])
          .map((e) => e.toString().toLowerCase().trim())
          .where((e) => e.isNotEmpty)
          .toList(),

      instantBooking: (json['instant_booking'] == true),
      firstName: _asString(user['first_name'] ?? ''),
      lastName: _asString(user['last_name'] ?? ''),
    );
  }

  String get displayName {
    final full = ('$firstName $lastName').trim();
    return full.isEmpty ? businessName : full;
  }
}

class WorkingHours {
  final String start; // HH:mm
  final String end;   // HH:mm

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
      features: ((json['features'] as List?) ?? const []).map((e) => e.toString()).toList(),
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
