class CityModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String slug;

  const CityModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameAr: (json['name_ar'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;
}

class AreaModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String slug;

  const AreaModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameAr: (json['name_ar'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;
}
