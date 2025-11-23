// lib/features/user/home/presentation/viewmodels/browse_services_viewmodel.dart

import 'package:beitak_app/core/error/exceptions.dart';
import 'package:beitak_app/features/user/home/data/datasources/home_remote_datasource.dart';
import 'package:beitak_app/features/user/home/data/repositories/home_repository_impl.dart';
import 'package:beitak_app/features/user/home/domain/entities/category_entity.dart';
import 'package:beitak_app/features/user/home/domain/entities/service_entity.dart';
import 'package:beitak_app/features/user/home/domain/usecases/get_categories_usecase.dart';
import 'package:beitak_app/features/user/home/domain/usecases/get_services_usecase.dart';
import 'package:dio/dio.dart';



/// ViewModel خاص بشاشة "تصفّح الخدمات" (BrowseServiceView).
///
/// مسؤول عن:
/// - تحميل الفئات (Categories)
/// - تحميل الخدمات (Services)
/// - إدارة الفلاتر (السعر، التقييم، الفئة، البحث)
/// - إدارة الباجينيشن (load more) مستقبلاً لو حبّينا
class BrowseServicesViewModel {
  late final GetServicesUseCase _getServicesUseCase;
  late final GetCategoriesUseCase _getCategoriesUseCase;

  // ======= حالة عامة =======
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  bool hasMore = true;

  // ======= بيانات من الـ API =======
  List<CategoryEntity> categories = [];
  List<ServiceEntity> services = [];
  List<ServiceEntity> filteredServices = [];

  // ======= حالة الباجينشن =======
  int _currentPage = 1;
  final int _pageSize;

  // ======= حالة الفلاتر =======
  int? selectedCategoryId;
  double minPrice = 0.0;
  double maxPrice = 150.0;
  double minRating = 0.0;
  String? searchTerm;

  BrowseServicesViewModel({int pageSize = 20})
      : _pageSize = pageSize {
    // إعداد الـ dependencies بنفس أسلوب LoginViewModel
    final dio = Dio(
      BaseOptions(
        // 👈 غيّر الـ baseUrl لما تربط فعلياً مع الـ backend (أو اسحبه من مكان مركزي)
        baseUrl: 'http://192.168.1.87:3026/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final remote = HomeRemoteDataSourceImpl(dio);
    final repo = HomeRepositoryImpl(remote: remote);
    _getServicesUseCase = GetServicesUseCase(repo);
    _getCategoriesUseCase = GetCategoriesUseCase(repo);
  }

  // =====================================================
  //                    Public API
  // =====================================================

  /// تحميل أولي للبيانات (يُستدعى مثلاً في initState في BrowseServiceView)
  Future<void> loadInitial() async {
    isLoading = true;
    errorMessage = null;
    hasMore = true;
    _currentPage = 1;

    try {
      // 1) جلب الفئات
      categories = await _getCategoriesUseCase();

      // 2) جلب الصفحة الأولى من الخدمات
      final result = await _getServicesUseCase(
        GetServicesParams(
          page: _currentPage,
          limit: _pageSize,
          categoryId: selectedCategoryId,
          search: searchTerm,
          minPrice: minPrice,
          maxPrice: maxPrice,
          minRating: minRating,
        ),
      );

      services = result;
      filteredServices = List<ServiceEntity>.from(services);

      // لو أقل من pageSize نعتبر أنه ما في صفحات أكثر
      hasMore = result.length == _pageSize;
    } on ServerException catch (e) {
      errorMessage = e.message;
      services = [];
      filteredServices = [];
    } catch (_) {
      errorMessage = 'حدث خطأ أثناء تحميل الخدمات، حاول مرة أخرى.';
      services = [];
      filteredServices = [];
    } finally {
      isLoading = false;
    }
  }

  /// إعادة تحميل (Pull-to-refresh مثلاً)
  Future<void> refresh() async {
    _currentPage = 1;
    hasMore = true;
    await loadInitial();
  }

  /// تحميل صفحة إضافية (لو حبيت تدعم infinite scroll لاحقاً)
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    errorMessage = null;

    try {
      final nextPage = _currentPage + 1;
      final result = await _getServicesUseCase(
        GetServicesParams(
          page: nextPage,
          limit: _pageSize,
          categoryId: selectedCategoryId,
          search: searchTerm,
          minPrice: minPrice,
          maxPrice: maxPrice,
          minRating: minRating,
        ),
      );

      if (result.isEmpty) {
        hasMore = false;
      } else {
        _currentPage = nextPage;
        services = [...services, ...result];
        _recalculateFiltered();
      }
    } on ServerException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'تعذر تحميل المزيد من الخدمات حالياً.';
    } finally {
      isLoadingMore = false;
    }
  }

  /// تحديث الفلاتر وإعادة تصفية القائمة الحالية (دون ضرب API جديدة مباشرة)
  ///
  /// بإمكانك استدعاء هذا من `_applyFilters` في `BrowseServiceView`
  /// أو لاحقاً تربطه مباشرة مع FilterBottomSheet.
  void updateFilters({
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? search,
  }) {
    if (categoryId != null) selectedCategoryId = categoryId;
    if (minPrice != null) this.minPrice = minPrice;
    if (maxPrice != null) this.maxPrice = maxPrice;
    if (minRating != null) this.minRating = minRating;
    if (search != null) searchTerm = search;

    _recalculateFiltered();
  }

  /// لو حبيت تاخذ الفلاتر بنفس شكل الـ Map اللي تستخدمه الآن في الـ UI
  Map<String, dynamic> get currentFiltersMap {
    return {
      'categoryId': selectedCategoryId,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRating': minRating,
      'search': searchTerm ?? '',
    };
  }

  // =====================================================
  //                    Helpers
  // =====================================================

  void _recalculateFiltered() {
    filteredServices = services.where((service) {
      final categoryOk = selectedCategoryId == null ||
          service.categoryId == selectedCategoryId;

      final priceOk = (() {
        final min = minPrice;
        final max = maxPrice;
        // لو الخدمة ما لها سعر → نعتبرها ضمن النتائج
        if (service.minPrice == null && service.maxPrice == null) return true;

        final serviceMin = service.minPrice ?? service.maxPrice ?? 0;
        final serviceMax = service.maxPrice ?? service.minPrice ?? serviceMin;

        // تداخل الباند مع [min, max]
        final overlaps = serviceMax >= min && serviceMin <= max;
        return overlaps;
      })();

      final ratingOk = (service.rating ?? 0) >= minRating;

      final searchOk = (() {
        if (searchTerm == null || searchTerm!.trim().isEmpty) return true;
        final q = searchTerm!.toLowerCase();
        return service.title.toLowerCase().contains(q) ||
            (service.description ?? '').toLowerCase().contains(q) ||
            (service.categoryName ?? '').toLowerCase().contains(q) ||
            (service.cityName ?? '').toLowerCase().contains(q) ||
            (service.areaName ?? '').toLowerCase().contains(q);
      })();

      return categoryOk && priceOk && ratingOk && searchOk;
    }).toList();
  }
}
