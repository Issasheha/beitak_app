import 'package:beitak_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class CityOption {
  final int id;
  final String name;
  const CityOption({required this.id, required this.name});
}

class LocationsCache {
  LocationsCache._();

  static Future<List<CityOption>>? _citiesFuture;

  static Future<List<CityOption>> getCities() {
    // ✅ لو موجودة، رجّعها مباشرة
    final existing = _citiesFuture;
    if (existing != null) return existing;

    // ✅ لو مش موجودة، أنشئ Future مرة واحدة
    _citiesFuture = _fetchCities();
    return _citiesFuture!;
  }

  static Future<List<CityOption>> refreshCities() {
    _citiesFuture = _fetchCities();
    return _citiesFuture!;
  }

  static void clear() {
    _citiesFuture = null;
  }

  static Future<List<CityOption>> _fetchCities() async {
    final Dio dio = ApiClient.dio;
    final res = await dio.get('/locations/cities');
    return _parseCities(res.data);
  }

  static List<CityOption> _parseCities(dynamic raw) {
    dynamic data = (raw is Map<String, dynamic>) ? raw['data'] : null;

    List<dynamic>? citiesRaw;
    if (data is List) {
      citiesRaw = data;
    } else if (data is Map<String, dynamic>) {
      final c = data['cities'];
      if (c is List) citiesRaw = c;
    } else if (raw is Map<String, dynamic>) {
      final c = raw['cities'];
      if (c is List) citiesRaw = c;
    }

    if (citiesRaw == null) return const [];

    final parsed = <CityOption>[];
    for (final item in citiesRaw) {
      if (item is! Map) continue;

      final id = (item['id'] as num?)?.toInt();
      if (id == null) continue;

      final nameAr = item['name_ar']?.toString().trim();
      final nameEn = item['name_en']?.toString().trim();
      final name = (nameAr != null && nameAr.isNotEmpty)
          ? nameAr
          : ((nameEn != null && nameEn.isNotEmpty) ? nameEn : 'City');

      parsed.add(CityOption(id: id, name: name));
    }
    return parsed;
  }
}
