// lib/features/user/home/domain/entities/category_entity.dart

/// Entity لتمثيل فئة خدمة (Category).
class CategoryEntity {
  final int id;
  final String nameAr;
  final String nameEn;
  final String slug;
  final String? iconUrl;

  const CategoryEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    this.iconUrl,
  });

  /// نص معرّب للعرض في الواجهة (تقدر مستقبلاً تختار حسب لغة التطبيق)
  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;
}
