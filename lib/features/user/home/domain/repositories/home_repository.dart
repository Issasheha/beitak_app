// lib/features/user/home/domain/repositories/home_repository.dart

import '../entities/category_entity.dart';
import '../entities/service_entity.dart';

/// Contract يحدد إيش المطلوب من Data Layer
/// عشان ميزة "الصفحة الرئيسية / الخدمات" تشتغل.
abstract class HomeRepository {
  /// جلب الفئات (Categories) المتاحة.
  Future<List<CategoryEntity>> getCategories();

  /// جلب قائمة الخدمات مع إمكانية الفلترة.
  Future<List<ServiceEntity>> getServices({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? city,
    String? area,
  });
}
