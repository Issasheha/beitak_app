// lib/core/providers/categories_id_map_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';

/// يرجّع ماب: FixedServiceCategories.key -> category_id (من /api/categories)
final categoriesIdMapProvider = FutureProvider<Map<String, int>>((ref) async {
  final res = await ApiClient.dio.get(ApiConstants.categories);
  final data = res.data;

  final rawList =
      (data is Map && data['data'] is Map && data['data']['categories'] is List)
          ? (data['data']['categories'] as List)
          : (data is Map && data['categories'] is List)
              ? (data['categories'] as List)
              : <dynamic>[];

  String norm(String s) {
    var x = s.trim().toLowerCase();
    x = x.replaceAll(RegExp(r'\s+'), '_'); // ✅ لا تحذف مسافات
    x = x.replaceAll('-', '_');
    x = x.replaceAll(RegExp(r'_+'), '_');
    return x;
  }

  final out = <String, int>{};

  for (final item in rawList) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);

    final idRaw = m['id'];
    final id = (idRaw is num) ? idRaw.toInt() : int.tryParse('$idRaw');
    if (id == null || id <= 0) continue;

    final slug = norm((m['slug'] ?? '').toString());
    final name = norm((m['name'] ?? '').toString());
    final nameEn = norm((m['name_en'] ?? '').toString());
    final nameAr = norm((m['name_ar'] ?? '').toString());

    final candidates = <String>{slug, name, nameEn, nameAr}..remove('');

    // ✅ نربط نتائج السيرفر بمفاتيحك الثابتة
    if (candidates.contains('cleaning')) out['cleaning'] = id;
    if (candidates.contains('plumbing')) out['plumbing'] = id;

    if (candidates.contains('electrical')) out['electricity'] = id;

    if (candidates.contains('general_maintenance')) out['home_maintenance'] = id;

    if (candidates.contains('appliance_repair')) out['appliance_maintenance'] = id;

    // (اختياري) لو في painting ومش مستخدم عندك حالياً، طنشه
  }

  return out;
});
