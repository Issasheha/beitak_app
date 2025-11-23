// lib/features/user/home/domain/entities/service_entity.dart

/// Entity تمثّل خدمة واحدة كما يتعامل معها الـ Domain Layer.
/// بدون JSON ولا Dio ولا Widgets.
class ServiceEntity {
  final int id;
  final String title;
  final String? description;

  final String? imageUrl;

  final String? categoryName;
  final int? categoryId;

  final String? cityName;
  final String? areaName;

  /// السعر (ممكن backend يرجّع range، فنخليها min/max)
  final double? minPrice;
  final double? maxPrice;

  final double? rating;
  final int? ratingCount;

  const ServiceEntity({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.categoryName,
    this.categoryId,
    this.cityName,
    this.areaName,
    this.minPrice,
    this.maxPrice,
    this.rating,
    this.ratingCount,
  });

  /// نص جاهز للعرض للسعر في الـ UI
  String get priceLabel {
    if (minPrice == null && maxPrice == null) return 'غير محدد';
    if (minPrice != null && maxPrice != null && minPrice != maxPrice) {
      return '${minPrice!.toStringAsFixed(0)} - ${maxPrice!.toStringAsFixed(0)} د.أ';
    }
    final value = (minPrice ?? maxPrice) ?? 0;
    return '${value.toStringAsFixed(0)} د.أ';
  }

  /// نص جاهز للعرض للموقع
  String get locationLabel {
    if (cityName == null && areaName == null) return '';
    if (cityName != null && areaName != null) return '$cityName - $areaName';
    return cityName ?? areaName ?? '';
  }

  double get safeRating => rating ?? 0.0;
}
