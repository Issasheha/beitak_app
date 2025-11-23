// lib/features/user/home/data/models/category_model.dart

import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String slug;
  final String? iconUrl;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    this.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameAr: (json['name_ar'] ?? json['name'] ?? '') as String,
      nameEn: (json['name_en'] ?? json['name_en_us'] ?? json['name'] ?? '') as String,
      slug: (json['slug'] ?? json['key'] ?? '') as String,
      iconUrl:
          (json['icon_url'] ?? json['icon'] ?? json['image_url']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'slug': slug,
      'icon_url': iconUrl,
    };
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      slug: slug,
      iconUrl: iconUrl,
    );
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;
}
