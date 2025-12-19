// lib/features/auth/presentation/providers/locations_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';

class CityOption {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? slug;

  const CityOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.slug,
  });

  factory CityOption.fromJson(Map<String, dynamic> json) {
    return CityOption(
      id: (json['id'] as num).toInt(),
      nameAr: (json['name_ar'] ?? json['nameAr'] ?? '').toString(),
      nameEn: (json['name_en'] ?? json['nameEn'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString().isEmpty
          ? null
          : (json['slug'] ?? '').toString(),
    );
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;
}

final citiesProvider = FutureProvider.autoDispose<List<CityOption>>((ref) async {
  final res = await ApiClient.dio.get(ApiConstants.cities);
  final body = res.data;

  List<dynamic> rawList = const [];

  // ✅ يدعم كل الاحتمالات الشائعة
  if (body is Map<String, dynamic>) {
    final data = body['data'];

    // حالتك: data = { cities: [...] }
    if (data is Map<String, dynamic>) {
      final cities = data['cities'];
      if (cities is List) rawList = cities;
    }

    // احتياط: data ممكن تكون List مباشرة
    if (rawList.isEmpty && data is List) {
      rawList = data;
    }

    // احتياط إضافي
    if (rawList.isEmpty) {
      final cities2 = body['cities'] ?? body['items'] ?? body['result'];
      if (cities2 is List) rawList = cities2;
    }
  } else if (body is List) {
    rawList = body;
  }

  final cities = rawList
      .whereType<Map>()
      .map((m) => CityOption.fromJson(Map<String, dynamic>.from(m)))
      .toList();

  cities.sort((a, b) => a.displayName.compareTo(b.displayName));
  return cities;
});
