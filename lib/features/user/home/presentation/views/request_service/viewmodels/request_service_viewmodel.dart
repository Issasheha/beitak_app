import 'dart:io';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/token_provider.dart';
import 'package:dio/dio.dart';

import '../models/location_models.dart' show AreaModel; // ✅
import '../models/city_model.dart';

class ServiceRequestDraft {
  final String name;
  final String phone;

  final int categoryId;
  final int cityId;
  final int? areaId; // ✅

  final String description;
  final double? budget;

  final String serviceDateIso;
  final String serviceTimeHour;

  final bool sharePhoneWithProvider;
  final List<File> files;

  const ServiceRequestDraft({
    required this.name,
    required this.phone,
    required this.categoryId,
    required this.cityId,
    required this.description,
    required this.serviceDateIso,
    required this.serviceTimeHour,
    required this.sharePhoneWithProvider,
    this.areaId,
    this.budget,
    this.files = const [],
  });
}

class RequestServiceViewModel {
  final Dio _dio;

  RequestServiceViewModel({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  static const String _sendOtp = '/auth/send-service-req-otp';
  static const String _verifyOtp = '/auth/verify-service-req-otp';
  static const String _serviceRequests = '/service-requests';

  Future<Map<String, dynamic>> _authHeadersIfAny() async {
    final token = await TokenProvider.getToken();
    if (token == null || token.trim().isEmpty) return const {};
    return {
      'Authorization': 'Bearer ${token.trim()}',
      'x-access-token': token.trim(),
    };
  }

  Future<List<CityModel>> fetchCities() async {
    final res = await _dio.get('/locations/cities');
    final body = res.data;

    if (body is Map && body['data'] is Map && body['data']['cities'] is List) {
      final list = (body['data']['cities'] as List)
          .whereType<Map>()
          .map((e) => CityModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return list;
    }
    return const [];
  }

  // ✅ مطابق تمامًا للـ JSON اللي بعتته
  Future<List<AreaModel>> fetchAreasByCitySlug(String citySlug) async {
    final res = await _dio.get('/locations/areas/$citySlug');
    final body = res.data;

    final data = (body is Map) ? body['data'] : null;
    final areas = (data is Map) ? data['areas'] : null;

    if (areas is List) {
      return areas
          .whereType<Map>()
          .map((e) => AreaModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return const [];
  }

  Future<Map<String, int>> fetchCategorySlugToId() async {
    final res = await _dio.get('/categories');
    final body = res.data;
    final map = <String, int>{};

    if (body is Map && body['data'] is Map && (body['data']['categories'] is List)) {
      final cats = body['data']['categories'] as List;
      for (final c in cats) {
        if (c is Map) {
          final slug = (c['slug'] ?? '').toString().trim();
          final id = (c['id'] as num?)?.toInt() ?? 0;
          if (slug.isNotEmpty && id > 0) map[slug] = id;
        }
      }
    }
    return map;
  }

  Future<void> sendServiceReqOtp({required String phone}) async {
    final res = await _dio.post(
      _sendOtp,
      data: {'phone': phone},
      options: Options(headers: await _authHeadersIfAny()),
    );
    _ensureSuccess(res);
  }

  Future<void> verifyServiceReqOtp({required String phone, required String otp}) async {
    final res = await _dio.post(
      _verifyOtp,
      data: {'phone': phone, 'otp': otp},
      options: Options(headers: await _authHeadersIfAny()),
    );
    _ensureSuccess(res);
  }

  Future<void> submitServiceRequest(ServiceRequestDraft draft) async {
    final formData = FormData.fromMap({
      'name': draft.name,
      'phone': draft.phone,
      'category_id': draft.categoryId,
      'city_id': draft.cityId,
      if (draft.areaId != null) 'area_id': draft.areaId, // ✅
      'description': draft.description,
      if (draft.budget != null) 'budget': draft.budget,
      'service_date': draft.serviceDateIso,
      'service_time': draft.serviceTimeHour,
      'share_phone': draft.sharePhoneWithProvider ? 1 : 0,
      if (draft.files.isNotEmpty)
        'files': [
          for (final f in draft.files)
            await MultipartFile.fromFile(
              f.path,
              filename: f.path.split('/').last,
            ),
        ],
    });

    final res = await _dio.post(
      _serviceRequests,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: await _authHeadersIfAny(),
      ),
    );

    _ensureSuccess(res);
  }

  void _ensureSuccess(Response<dynamic> res) {
    final ok = (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300;
    if (!ok) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        throw Exception((data['message'] ?? 'فشل الطلب').toString());
      }
      throw Exception('فشل الطلب: ${res.statusCode}');
    }

    final data = res.data;
    if (data is Map<String, dynamic>) {
      final success = data['success'];
      if (success == null || success == true) return;
      throw Exception((data['message'] ?? 'حدث خطأ غير متوقع').toString());
    }
  }
}
