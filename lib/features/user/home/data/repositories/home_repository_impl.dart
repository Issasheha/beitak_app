// lib/features/user/home/data/repositories/home_repository_impl.dart

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remote;

  HomeRepositoryImpl({required HomeRemoteDataSource remote}) : _remote = remote;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final models = await _remote.getCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
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
  }) async {
    final models = await _remote.getServices(
      page: page,
      limit: limit,
      categoryId: categoryId,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      city: city,
      area: area,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}
