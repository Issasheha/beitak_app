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
      id: (json['id'] ?? 0) as int,
      nameAr: (json['name_ar'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }

  String localizedName({required bool preferArabic}) {
    final ar = nameAr.trim();
    final en = nameEn.trim();
    if (preferArabic) return ar.isNotEmpty ? ar : (en.isNotEmpty ? en : slug);
    return en.isNotEmpty ? en : (ar.isNotEmpty ? ar : slug);
  }
}
