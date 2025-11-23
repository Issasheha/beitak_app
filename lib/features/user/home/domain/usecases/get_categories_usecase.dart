// lib/features/user/home/domain/usecases/get_categories_usecase.dart

import '../entities/category_entity.dart';
import '../repositories/home_repository.dart';

/// UseCase: جلب كل الفئات (Categories) لصفحة التصفّح والفلاتر.
class GetCategoriesUseCase {
  final HomeRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<List<CategoryEntity>> call() {
    return _repository.getCategories();
  }
}
