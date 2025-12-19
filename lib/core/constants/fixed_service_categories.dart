// lib/core/constants/fixed_service_categories.dart

class FixedServiceCategory {
  final String key; // internal (backend-friendly)
  final String labelAr; // UI label (Arabic)
  const FixedServiceCategory({required this.key, required this.labelAr});
}

class FixedServiceCategories {
  FixedServiceCategories._();

  static const List<FixedServiceCategory> all = [
    FixedServiceCategory(key: 'plumbing', labelAr: 'السباكة'),
    FixedServiceCategory(key: 'cleaning', labelAr: 'التنظيف'),
    FixedServiceCategory(key: 'home_maintenance', labelAr: 'صيانه للمنزل'),
    FixedServiceCategory(key: 'appliance_maintenance', labelAr: 'صيانه للاجهزة'),
    FixedServiceCategory(key: 'electricity', labelAr: 'كهرباء'),
  ];

  static const Map<String, String> keyToAr = {
    'plumbing': 'السباكة',
    'cleaning': 'التنظيف',
    'home_maintenance': 'صيانه للمنزل',
    'appliance_maintenance': 'صيانه للاجهزة',
    'electricity': 'كهرباء',
  };

  // ---------- Normalization helpers ----------

  static String _normAr(String s) {
    var x = s.trim();

    // remove spaces + tatweel
    x = x.replaceAll(RegExp(r'\s+'), '');
    x = x.replaceAll('ـ', '');

    // normalize alef variants
    x = x.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');

    // normalize ya/ta marbuta
    x = x.replaceAll('ى', 'ي');
    x = x.replaceAll('ة', 'ه');

    // remove Arabic "ال" prefix (optional)
    if (x.startsWith('ال')) x = x.substring(2);

    return x;
  }

  static String _normKey(String s) {
    var x = s.trim().toLowerCase();

    // ✅ أهم تعديل: لا تحذف المسافات، حولها إلى underscore
    x = x.replaceAll(RegExp(r'\s+'), '_');
    x = x.replaceAll('-', '_');
    x = x.replaceAll(RegExp(r'_+'), '_');

    return x;
  }

  static String? keyFromArabicLabel(String labelAr) {
    final want = _normAr(labelAr);

    for (final c in all) {
      if (_normAr(c.labelAr) == want) return c.key;
    }

    // allow some common variants
    final variants = <String, String>{
      _normAr('صيانة للمنزل'): 'home_maintenance',
      _normAr('صيانه للمنزل'): 'home_maintenance',

      _normAr('صيانة للاجهزة'): 'appliance_maintenance',
      _normAr('صيانه للاجهزة'): 'appliance_maintenance',
      _normAr('صيانة للأجهزة'): 'appliance_maintenance',

      _normAr('كهرباء'): 'electricity',
      _normAr('سباكة'): 'plumbing',
      _normAr('تنظيف'): 'cleaning',
    };

    return variants[want];
  }

  static String labelArFromKey(String key) {
    final k = _normKey(key);
    return keyToAr[k] ?? key;
  }

  /// Try detect category key from *any* string (arabic label / key / slug)
  static String? keyFromAnyString(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    // looks like key/slug
    final hasLatin = RegExp(r'[a-zA-Z_/-]').hasMatch(s);
    if (hasLatin) {
      final k = _normKey(s);

      // ✅ Aliases: السيرفر vs مفاتيحك الثابتة
      if (k == 'electrical') return 'electricity';
      if (k == 'general_maintenance') return 'home_maintenance';
      if (k == 'appliance_repair') return 'appliance_maintenance';

      if (keyToAr.containsKey(k)) return k;

      // sometimes slug is "home-maintenance" (بعد _normKey غالباً تصير home_maintenance)
      final back = k.replaceAll('-', '_');
      if (keyToAr.containsKey(back)) return back;

      return null;
    }

    // assume arabic label
    return keyFromArabicLabel(s);
  }

  /// Best effort: get key from service json (works with category_other / name / slug / category.slug)
  static String? keyFromServiceJson(Map<String, dynamic> json) {
    // 1) category.slug
    final cat = json['category'];
    if (cat is Map) {
      final slug = cat['slug']?.toString();
      final k = keyFromAnyString(slug);
      if (k != null) return k;
    }

    // 2) category_other (Arabic)
    final other = json['category_other']?.toString();
    final k2 = keyFromAnyString(other);
    if (k2 != null) return k2;

    // 3) name (could be key OR arabic)
    final name = json['name']?.toString();
    final k3 = keyFromAnyString(name);
    if (k3 != null) return k3;

    // 4) slug (could be key)
    final slug = json['slug']?.toString();
    final k4 = keyFromAnyString(slug);
    if (k4 != null) return k4;

    return null;
  }

  static String labelArFromServiceJson(Map<String, dynamic> json) {
    final other = (json['category_other'] ?? '').toString().trim();
    if (other.isNotEmpty) return other;

    final cat = json['category'];
    if (cat is Map) {
      final nameAr = (cat['name_ar'] ?? '').toString().trim();
      if (nameAr.isNotEmpty) return nameAr;

      final nameLoc = (cat['name_localized'] ?? '').toString().trim();
      if (nameLoc.isNotEmpty) return nameLoc;

      final name = (cat['name'] ?? '').toString().trim();
      if (name.isNotEmpty) return name;
    }

    final key = keyFromServiceJson(json);
    if (key != null) return labelArFromKey(key);

    return '—';
  }
}
