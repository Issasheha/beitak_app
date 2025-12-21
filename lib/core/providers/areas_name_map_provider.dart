import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';

/// Map شامل:
/// - city.slug -> city.name_ar
/// - area.slug -> area.name_ar
/// - city.name_en / area.name_en -> name_ar (lowercase)
/// - city.name / area.name -> name_ar (lowercase)
final areasNameMapProvider = FutureProvider<Map<String, String>>((ref) async {
  final res = await ApiClient.dio.get(
    ApiConstants.areas, // ✅ عدّلها حسب ثابتك: مثال "/api/locations/areas"
  );

  final data = (res.data is Map) ? (res.data as Map) : const {};
  final areas = ((data['data'] as Map?)?['areas'] as List?) ?? const [];

  final map = <String, String>{};

  String normKey(String s) {
    var x = s.trim().toLowerCase();
    x = x.replaceAll(RegExp(r'\s+'), ' ');
    x = x.replaceAll(RegExp(r'\s*-\s*'), ' - ');
    return x;
  }

  void putIfValid(String? k, String? v) {
    final kk = (k ?? '').trim();
    final vv = (v ?? '').trim();
    if (kk.isEmpty || vv.isEmpty) return;
    map[normKey(kk)] = vv;
  }

  for (final item in areas) {
    if (item is! Map) continue;

    final areaSlug = item['slug']?.toString();
    final areaNameAr = item['name_ar']?.toString();
    final areaNameEn = item['name_en']?.toString();
    final areaName = item['name']?.toString();

    final city = item['city'];
    String? citySlug, cityNameAr, cityNameEn, cityName;
    if (city is Map) {
      citySlug = city['slug']?.toString();
      cityNameAr = city['name_ar']?.toString();
      cityNameEn = city['name_en']?.toString();
      cityName = city['name']?.toString();
    }

    // city mappings
    putIfValid(citySlug, cityNameAr);
    putIfValid(cityNameEn, cityNameAr);
    putIfValid(cityName, cityNameAr);

    // area mappings
    putIfValid(areaSlug, areaNameAr);
    putIfValid(areaNameEn, areaNameAr);
    putIfValid(areaName, areaNameAr);

    // combined (slug form)  "amman - abdoun"
    if ((citySlug ?? '').isNotEmpty && (areaSlug ?? '').isNotEmpty) {
      final combinedSlug = '${citySlug!.trim()} - ${areaSlug!.trim()}';
      final combinedAr = '${(cityNameAr ?? '').trim()} - ${(areaNameAr ?? '').trim()}'.trim();
      if (combinedAr.replaceAll('-', '').trim().isNotEmpty) {
        putIfValid(combinedSlug, combinedAr);
      }
    }

    // combined (EN form) "Amman - Abdoun"
    if ((cityNameEn ?? '').isNotEmpty && (areaNameEn ?? '').isNotEmpty) {
      final combinedEn = '${cityNameEn!.trim()} - ${areaNameEn!.trim()}';
      final combinedAr = '${(cityNameAr ?? '').trim()} - ${(areaNameAr ?? '').trim()}'.trim();
      if (combinedAr.replaceAll('-', '').trim().isNotEmpty) {
        putIfValid(combinedEn, combinedAr);
      }
    }
  }

  return map;
});
