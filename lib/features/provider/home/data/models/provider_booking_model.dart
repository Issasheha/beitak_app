import 'package:flutter/foundation.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';

@immutable
class ProviderBookingModel {
  final int id;
  final String bookingNumber;
  final String status;
  final String bookingDate;
  final String bookingTime;
  final double totalPrice;

  /// غالباً جايين slug مثل: amman / abdoun
  final String serviceCity;
  final String? serviceArea;

  final double durationHours;

  final String? serviceAddress;
  final String? customerNotes;
  final String? packageSelected;
  final List<String> addOnsSelected;

  final _PersonModel customer;
  final _ServiceModel service;

  const ProviderBookingModel({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.bookingDate,
    required this.bookingTime,
    required this.totalPrice,
    required this.serviceCity,
    required this.serviceArea,
    required this.durationHours,
    required this.customer,
    required this.service,
    this.serviceAddress,
    this.customerNotes,
    this.packageSelected,
    this.addOnsSelected = const [],
  });

  factory ProviderBookingModel.fromJson(Map<String, dynamic> json) {
    final customerJson = (json['customer'] as Map?)?.cast<String, dynamic>() ??
        (json['user'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    final serviceJson =
        (json['service'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};

    final rawAddons = (json['add_ons_selected'] as List?) ?? const [];
    final addons = rawAddons.map((e) => e.toString()).toList();

    String? nullableString(dynamic v) {
      final s = (v ?? '').toString().trim();
      if (s.isEmpty) return null;

      // ✅ نمسك N/A هون كمان
      final lower = s.toLowerCase();
      if (lower == 'n/a' || lower == 'na' || lower == 'none' || lower == 'null') return null;

      return s;
    }

    return ProviderBookingModel(
      id: _asInt(json['id']),
      bookingNumber: (json['booking_number'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      bookingDate: (json['booking_date'] ?? '').toString(),
      bookingTime: (json['booking_time'] ?? '').toString(),
      totalPrice: _asDouble(json['total_price']),
      serviceCity: (json['service_city'] ?? '').toString(),
      serviceArea: nullableString(json['service_area']),
      durationHours: _asDouble(json['duration_hours']),
      serviceAddress: nullableString(json['service_address']),
      customerNotes: nullableString(json['customer_notes']),
      packageSelected: nullableString(json['package_selected']),
      addOnsSelected: addons,
      customer: _PersonModel.fromJson(customerJson),
      service: _ServiceModel.fromJson(serviceJson),
    );
  }

  // ---------------- UI helpers ----------------

  String get customerName => customer.fullName.isEmpty ? 'عميل' : customer.fullName;
  String? get customerPhone => customer.phone?.trim().isEmpty == true ? null : customer.phone;
  String? get customerEmail => customer.email?.trim().isEmpty == true ? null : customer.email;

  /// raw (قد تكون cleaning)
  String get serviceName => service.name.isEmpty ? 'خدمة' : service.name;

  /// ✅ عربي للفئة (fallback ممتاز حتى لو ما استخدمت AppLocalizer)
  String get serviceNameAr {
    final raw = serviceName.trim();
    if (raw.isEmpty) return 'خدمة';

    final key = FixedServiceCategories.keyFromAnyString(raw);
    if (key != null) return FixedServiceCategories.labelArFromKey(key);

    // إذا جاي عربي أصلاً
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(raw);
    return hasArabic ? raw : raw;
  }

  String? get serviceDescription => service.description.trim().isEmpty ? null : service.description;

  /// raw "amman - abdoun"
  String get locationText {
    final area = (serviceArea ?? '').trim();
    if (area.isEmpty) return serviceCity;
    return '$serviceCity - $area';
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }
}

@immutable
class _PersonModel {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;

  const _PersonModel({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
  });

  factory _PersonModel.fromJson(Map<String, dynamic> json) => _PersonModel(
        firstName: (json['first_name'] ?? '').toString(),
        lastName: (json['last_name'] ?? '').toString(),
        phone: (json['phone'] ?? '')?.toString(),
        email: (json['email'] ?? '')?.toString(),
      );

  String get fullName => ('$firstName $lastName').trim();
}

@immutable
class _ServiceModel {
  final String name;
  final String description;

  const _ServiceModel({
    required this.name,
    required this.description,
  });

  factory _ServiceModel.fromJson(Map<String, dynamic> json) => _ServiceModel(
        name: (json['name'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
      );
}
