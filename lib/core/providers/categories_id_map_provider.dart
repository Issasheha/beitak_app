// lib/core/providers/categories_id_map_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';

/// يرجّع ماب: category_key/alias -> category_id (من /api/categories)
final categoriesIdMapProvider = FutureProvider<Map<String, int>>((ref) async {
  final res = await ApiClient.dio.get(ApiConstants.categories);
  final data = res.data;

  final rawList =
      (data is Map && data['data'] is Map && data['data']['categories'] is List)
          ? (data['data']['categories'] as List)
          : (data is Map && data['categories'] is List)
              ? (data['categories'] as List)
              : <dynamic>[];

  String normU(String s) {
    var x = s.trim().toLowerCase();
    x = x.replaceAll(RegExp(r'\s+'), '_'); // spaces -> _
    x = x.replaceAll('-', '_');
    x = x.replaceAll(RegExp(r'_+'), '_');
    return x;
  }

  String normS(String s) {
    return s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  final out = <String, int>{};

  void addAliases(int id, Iterable<String> keys) {
    for (final k in keys) {
      final kk = k.trim().toLowerCase();
      if (kk.isEmpty) continue;
      out[kk] = id;
    }
  }

  bool hasAny(Set<String> candidates, Iterable<String> expected) {
    for (final e in expected) {
      final ee = e.trim().toLowerCase();
      if (ee.isEmpty) continue;
      if (candidates.contains(ee)) return true;
    }
    return false;
  }

  for (final item in rawList) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);

    final idRaw = m['id'];
    final id = (idRaw is num) ? idRaw.toInt() : int.tryParse('$idRaw');
    if (id == null || id <= 0) continue;

    final slugRaw = (m['slug'] ?? '').toString();
    final nameRaw = (m['name'] ?? '').toString();
    final nameEnRaw = (m['name_en'] ?? '').toString();
    final nameArRaw = (m['name_ar'] ?? '').toString();

    final slugU = normU(slugRaw);
    final nameU = normU(nameRaw);
    final nameEnU = normU(nameEnRaw);
    final nameArU = normU(nameArRaw);

    final slugS = normS(slugRaw);
    final nameS = normS(nameRaw);
    final nameEnS = normS(nameEnRaw);
    final nameArS = normS(nameArRaw);

    final cU = <String>{slugU, nameU, nameEnU, nameArU}..remove('');
    final cS = <String>{slugS, nameS, nameEnS, nameArS}..remove('');

    // ✅ خزّن slug نفسه كـ key (spaces + underscore)
    if (slugS.isNotEmpty) out[slugS] = id;
    if (slugU.isNotEmpty) out[slugU] = id;

    // ===== classify precisely (بدون كلمات عامة) =====

    // Cleaning
    if (hasAny(cU, ['cleaning', 'تنظيف']) || hasAny(cS, ['cleaning', 'تنظيف'])) {
      addAliases(id, [
        'cleaning',
        'تنظيف',
      ]);
      continue;
    }

    // Plumbing
    if (hasAny(cU, ['plumbing', 'سباكة']) || hasAny(cS, ['plumbing', 'سباكة'])) {
      addAliases(id, [
        'plumbing',
        'سباكة',
        'plumber',
      ]);
      continue;
    }

    // Electrical (server slug: electrical) -> key ثابت عندك: electricity
    if (hasAny(cU, ['electrical', 'كهرباء']) || hasAny(cS, ['electrical', 'كهرباء'])) {
      addAliases(id, [
        'electrical',
        'electricity',
        'كهرباء',
      ]);
      continue;
    }

    // General Maintenance (server slug: "general maintenance") -> home_maintenance
    if (hasAny(cU, ['general_maintenance', 'صيانة_عامة']) ||
        hasAny(cS, ['general maintenance', 'صيانة عامة', 'صيانة عامه'])) {
      addAliases(id, [
        'general maintenance',
        'general_maintenance',
        'home_maintenance',
        'صيانة عامة',
        'صيانة عامه',
        'صيانة_عامة',
      ]);
      continue;
    }

    // Appliance Repair (server slug: "appliance repair") -> appliance_maintenance
    if (hasAny(cU, ['appliance_repair', 'اصلاح_الاجهزة', 'إصلاح_الأجهزة', 'صيانة_الاجهزة']) ||
        hasAny(cS, ['appliance repair', 'اصلاح الاجهزة', 'إصلاح الأجهزة', 'صيانة الاجهزة', 'صيانة الأجهزة'])) {
      addAliases(id, [
        'appliance repair',
        'appliance_repair',
        'appliance_maintenance',
        'إصلاح الأجهزة',
        'اصلاح الاجهزة',
        'صيانة الأجهزة',
        'صيانة الاجهزة',
        'إصلاح_الأجهزة',
        'اصلاح_الاجهزة',
        'صيانة_الاجهزة',
      ]);
      continue;
    }
  }

  return out;
});
