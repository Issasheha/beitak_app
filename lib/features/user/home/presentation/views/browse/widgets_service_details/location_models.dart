class CityOption {
  final int id;
  final String nameAr;
  final String nameEn;
  final String slug;

  const CityOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory CityOption.fromJson(Map<String, dynamic> json) {
    return CityOption(
      id: _asInt(json['id']),
      nameEn: (json['name_en'] ?? json['name'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }
}

class AreaOption {
  final int id;
  final String nameAr;
  final String nameEn;
  final String slug;

  const AreaOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory AreaOption.fromJson(Map<String, dynamic> json) {
    return AreaOption(
      id: _asInt(json['id']),
      nameEn: (json['name_en'] ?? json['name'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }
}

class UserLocationProfile {
  final int? cityId;
  final int? areaId;

  const UserLocationProfile({this.cityId, this.areaId});

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// ✅ NEW: لو وصلك location object مباشرة:
  /// { city_id: 1, area_id: 2 } أو { cityId: 1, areaId: 2 }
  factory UserLocationProfile.fromJson(Map<String, dynamic> json) {
    return UserLocationProfile(
      cityId: _asNullableInt(json['city_id'] ?? json['cityId']),
      areaId: _asNullableInt(json['area_id'] ?? json['areaId']),
    );
  }

  /// Expected:
  /// { success:true, data:{ user:{ city_id:1, area_id:1, ... } } }
  factory UserLocationProfile.fromProfileResponse(Map<String, dynamic> root) {
    final data = root['data'];
    if (data is Map) {
      final user = data['user'];
      if (user is Map) {
        return UserLocationProfile(
          cityId: _asNullableInt(user['city_id']),
          areaId: _asNullableInt(user['area_id']),
        );
      }
    }

    // fallback (لو رجع user مباشرة)
    final user2 = root['user'];
    if (user2 is Map) {
      return UserLocationProfile(
        cityId: _asNullableInt(user2['city_id']),
        areaId: _asNullableInt(user2['area_id']),
      );
    }

    return const UserLocationProfile(cityId: null, areaId: null);
  }
}
