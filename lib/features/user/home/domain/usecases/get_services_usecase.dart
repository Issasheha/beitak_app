// lib/features/user/home/domain/usecases/get_services_usecase.dart

import '../entities/service_entity.dart';
import '../repositories/home_repository.dart';

/// باراميترات الفلترة والـ pagination.
/// نخليها class صغيرة عشان الكود يكون مرتب.
class GetServicesParams {
  final int page;
  final int limit;
  final int? categoryId;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? city;
  final String? area;

  const GetServicesParams({
    this.page = 1,
    this.limit = 10,
    this.categoryId,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.city,
    this.area,
  });
}

/// UseCase: جلب الخدمات (مع إمكانية الفلترة) لصفحة Browse Services.
class GetServicesUseCase {
  final HomeRepository _repository;

  const GetServicesUseCase(this._repository);

  Future<List<ServiceEntity>> call(GetServicesParams params) {
    return _repository.getServices(
      page: params.page,
      limit: params.limit,
      categoryId: params.categoryId,
      search: params.search,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      minRating: params.minRating,
      city: params.city,
      area: params.area,
    );
  }
}
