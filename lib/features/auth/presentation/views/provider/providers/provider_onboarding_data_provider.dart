import 'package:beitak_app/core/error/exceptions.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOnboardingDataProvider =
    FutureProvider<ProviderOnboardingData>((ref) async {
  final dio = ApiClient.dio;

  try {
    final citiesResp = await dio.get(ApiConstants.cities);
    final categoriesResp = await dio.get(ApiConstants.categories);

    final cities = _parseCities(citiesResp.data);
    final categories = _parseCategories(categoriesResp.data);

    // ✅ حسب المتطلبات: 5 فئات + شيل Painting
    // من API عندك: 6 فئات (ومنها Painting) → بنشيل Painting → بتضل 5
    final filteredCategories = categories.where((c) {
      final slug = (c.slug ?? '').toLowerCase();
      final name = (c.nameEn ?? c.name ?? '').toLowerCase();
      final nameAr = (c.nameAr ?? '').toLowerCase();
      final isPainting = slug == 'painting' || name.contains('painting') || nameAr.contains('رسم');
      return !isPainting;
    }).toList();

    return ProviderOnboardingData(
      cities: cities,
      categories: filteredCategories,
    );
  } on DioException catch (e) {
    throw ServerException(
      message: _friendlyDioMessage(e),
      statusCode: e.response?.statusCode ?? 0,
    );
  }
});

class ProviderOnboardingData {
  final List<CityOption> cities;
  final List<CategoryOption> categories;

  ProviderOnboardingData({
    required this.cities,
    required this.categories,
  });
}

class CityOption {
  final int id;
  final String? nameEn;
  final String? nameAr;
  final String? slug;

  CityOption({
    required this.id,
    this.nameEn,
    this.nameAr,
    this.slug,
  });

  String get displayName => (nameAr?.trim().isNotEmpty ?? false)
      ? nameAr!.trim()
      : (nameEn?.trim().isNotEmpty ?? false)
          ? nameEn!.trim()
          : 'City #$id';
}

class CategoryOption {
  final int id;
  final String? name;
  final String? nameEn;
  final String? nameAr;
  final String? slug;

  CategoryOption({
    required this.id,
    this.name,
    this.nameEn,
    this.nameAr,
    this.slug,
  });

  String get displayName => (nameAr?.trim().isNotEmpty ?? false)
      ? nameAr!.trim()
      : (nameEn?.trim().isNotEmpty ?? false)
          ? nameEn!.trim()
          : (name?.trim().isNotEmpty ?? false)
              ? name!.trim()
              : 'Category #$id';
}

List<CityOption> _parseCities(dynamic raw) {
  if (raw is! Map<String, dynamic>) return [];
  final data = raw['data'];
  if (data is! Map<String, dynamic>) return [];
  final list = data['cities'];
  if (list is! List) return [];

  return list
      .whereType<Map>()
      .map((m) {
        final mm = Map<String, dynamic>.from(m);
        final id = mm['id'];
        if (id is! int) return null;
        return CityOption(
          id: id,
          nameEn: mm['name_en']?.toString(),
          nameAr: mm['name_ar']?.toString(),
          slug: mm['slug']?.toString(),
        );
      })
      .whereType<CityOption>()
      .toList();
}

List<CategoryOption> _parseCategories(dynamic raw) {
  if (raw is! Map<String, dynamic>) return [];
  final data = raw['data'];
  if (data is! Map<String, dynamic>) return [];
  final list = data['categories'];
  if (list is! List) return [];

  return list
      .whereType<Map>()
      .map((m) {
        final mm = Map<String, dynamic>.from(m);
        final id = mm['id'];
        if (id is! int) return null;
        return CategoryOption(
          id: id,
          name: mm['name']?.toString(),
          nameEn: mm['name_en']?.toString(),
          nameAr: mm['name_ar']?.toString(),
          slug: mm['slug']?.toString(),
        );
      })
      .whereType<CategoryOption>()
      .toList();
}

String _friendlyDioMessage(DioException e) {
  final status = e.response?.statusCode;
  if (status == 404) return 'تعذر تحميل البيانات (Not Found)';
  if (status == 500) return 'خطأ من الخادم أثناء تحميل البيانات';
  return 'تعذر تحميل بيانات المدن/الفئات، تأكد من الاتصال بالإنترنت';
}
