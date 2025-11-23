// lib/features/user/home/data/models/service_model.dart

import '../../domain/entities/service_entity.dart';
import 'category_model.dart';

class ServiceModel {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;

  final CategoryModel? category;

  final String? cityName;
  final String? areaName;

  final double? minPrice;
  final double? maxPrice;

  final double? rating;
  final int? ratingCount;

  const ServiceModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.category,
    this.cityName,
    this.areaName,
    this.minPrice,
    this.maxPrice,
    this.rating,
    this.ratingCount,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // نحاول نقرأ أكثر من شكل متوقّع من الـ backend (مرن قدر الإمكان)
    final rawId = json['id'] ?? json['service_id'];
    final rawTitle = json['title'] ?? json['name'] ?? json['title_ar'];
    final rawDescription =
        json['description'] ?? json['details'] ?? json['description_ar'];

    // صور ممكن تكون image / image_url / thumbnail
    final rawImage =
        json['image_url'] ?? json['image'] ?? json['thumbnail'] ?? json['icon'];

    // موقع
    final city = json['city_name'] ?? json['city'];
    final area = json['area_name'] ?? json['area'];

    // أسعار
    final minPrice = _toDouble(json['min_price'] ?? json['price_min']);
    final maxPrice = _toDouble(json['max_price'] ?? json['price_max']);

    // تقييم
    final rating = _toDouble(json['rating'] ?? json['avg_rating']);
    final ratingCount = (json['rating_count'] ?? json['reviews_count']) as int?;

    // Category ممكن تجي كـ object أو كـ اسم/معرّف مفصول
    CategoryModel? category;
    if (json['category'] is Map<String, dynamic>) {
      category = CategoryModel.fromJson(json['category'] as Map<String, dynamic>);
    } else if (json['category_id'] != null || json['category_name'] != null) {
      category = CategoryModel(
        id: (json['category_id'] as num?)?.toInt() ?? 0,
        nameAr: (json['category_name_ar'] ??
                json['category_name'] ??
                json['category'] ??
                '') as String,
        nameEn: (json['category_name_en'] ??
                json['category_name'] ??
                json['category'] ??
                '') as String,
        slug: (json['category_slug'] ?? '') as String,
        iconUrl: null,
      );
    }

    return ServiceModel(
      id: (rawId as num?)?.toInt() ?? 0,
      title: (rawTitle ?? '').toString(),
      description: rawDescription?.toString(),
      imageUrl: rawImage?.toString(),
      category: category,
      cityName: city?.toString(),
      areaName: area?.toString(),
      minPrice: minPrice,
      maxPrice: maxPrice,
      rating: rating,
      ratingCount: ratingCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'category': category?.toJson(),
      'city_name': cityName,
      'area_name': areaName,
      'min_price': minPrice,
      'max_price': maxPrice,
      'rating': rating,
      'rating_count': ratingCount,
    };
  }

  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      categoryId: category?.id,
      categoryName: category?.displayName,
      cityName: cityName,
      areaName: areaName,
      minPrice: minPrice,
      maxPrice: maxPrice,
      rating: rating,
      ratingCount: ratingCount,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
