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
    // id
    final rawId = json['id'] ?? json['service_id'];

    // العنوان والوصف (نفضّل الـ localized لو موجود)
    final rawTitle = json['name_localized'] ??
        json['title'] ??
        json['name'] ??
        json['name_ar'] ??
        json['title_ar'];

    final rawDescription = json['description_localized'] ??
        json['description'] ??
        json['details'] ??
        json['description_ar'];

    // 🔹 الصور:
    // أولاً: image / image_url / thumbnail / icon
    final rawImage =
        json['image_url'] ?? json['image'] ?? json['thumbnail'] ?? json['icon'];

    String? imageUrl;
    if (rawImage != null && rawImage.toString().isNotEmpty) {
      imageUrl = rawImage.toString();
    } else {
      // ثانياً: لو في مصفوفة images: [url1, url2, ...]
      final images = json['images'];
      if (images is List && images.isNotEmpty) {
        imageUrl = images.first.toString();
      }
    }

    // 🔹 الموقع
    final city = json['city_name'] ?? json['city'];
    final area = json['area_name'] ?? json['area'];

    // 🔹 الأسعار
    double? minPrice = _toDouble(json['min_price'] ?? json['price_min']);
    double? maxPrice = _toDouble(json['max_price'] ?? json['price_max']);

    // بعض الـ APIs ترجع سعر واحد: base_price / hourly_rate / starting_price
    final basePrice = _toDouble(
      json['base_price'] ?? json['starting_price'] ?? json['hourly_rate'],
    );

    // لو ما في min/max نستخدم basePrice كقيمة وحيدة
    minPrice ??= basePrice;
    maxPrice ??= basePrice;

    // 🔹 التقييم
    final provider = json['provider'];

    double? rating = _toDouble(
      json['rating'] ??
          json['avg_rating'] ??
          json['rating_avg'] ??
          (provider is Map<String, dynamic> ? provider['rating_avg'] : null),
    );

    int? ratingCount;
    final rawRatingCount = json['rating_count'] ??
        json['reviews_count'] ??
        (provider is Map<String, dynamic> ? provider['rating_count'] : null);

    if (rawRatingCount is num) {
      ratingCount = rawRatingCount.toInt();
    } else if (rawRatingCount != null) {
      ratingCount = int.tryParse(rawRatingCount.toString());
    }

    // 🔹 الـ Category: ممكن تجي object أو حقول منفصلة
    CategoryModel? category;
    if (json['category'] is Map<String, dynamic>) {
      category =
          CategoryModel.fromJson(json['category'] as Map<String, dynamic>);
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
      imageUrl: imageUrl,
      category: category,
      cityName: city?.toString(),
      areaName: area?.toString(),
      minPrice: minPrice,
      maxPrice: maxPrice,
      rating: rating,
      ratingCount: ratingCount,
    );
  }

  /// تحويل الـ Model إلى Entity تستخدمه الـ Domain / UI
  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      categoryName: category?.displayName,
      categoryId: category?.id,
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
