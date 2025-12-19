// lib/features/user/home/presentation/views/request_service/viewmodels/request_service_viewmodel.dart

import 'dart:io';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/token_provider.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/viewmodels/request_service_draft.dart';
import 'package:dio/dio.dart';

import '../models/location_models.dart' show AreaModel;
import '../models/city_model.dart';

class RequestServiceViewModel {
  final Dio _dio;

  RequestServiceViewModel({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  static const String _sendOtp = '/auth/send-service-req-otp';
  static const String _verifyOtp = '/auth/verify-service-req-otp';

  static const String _serviceRequests = '/service-requests';
  static const String _serviceRequestsGuest = '/service-requests/guest';

  // ✅ Normalize slug to avoid space/case issues
  static String _normSlug(String s) {
    var x = s.trim().toLowerCase();

    // collapse spaces
    x = x.replaceAll(RegExp(r'\s+'), ' ');

    // support separators (optional)
    x = x.replaceAll('_', ' ');
    x = x.replaceAll('-', ' ');

    x = x.replaceAll(RegExp(r'\s+'), ' ').trim();
    return x;
  }

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

  /// ✅ يرجّع Map: normalizedSlug -> id
  Future<Map<String, int>> fetchCategorySlugToId() async {
    final res = await _dio.get('/categories');
    final body = res.data;
    final map = <String, int>{};

    if (body is Map && body['data'] is Map && (body['data']['categories'] is List)) {
      final cats = body['data']['categories'] as List;
      for (final c in cats) {
        if (c is Map) {
          final slugRaw = (c['slug'] ?? '').toString();
          final slug = _normSlug(slugRaw);

          final id = (c['id'] as num?)?.toInt() ?? 0;

          if (slug.isNotEmpty && id > 0) {
            map[slug] = id;

            // ✅ bonus: دعم لو slug جاي بشكل مختلف (مسافات/داش/أندر)
            // (يعني لو عندك option مكتوب appliance-repair أو appliance_repair)
            final dashed = slug.replaceAll(' ', '-');
            final underscored = slug.replaceAll(' ', '_');
            map[dashed] = id;
            map[underscored] = id;
          }
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

  Future<void> verifyServiceReqOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await _dio.post(
      _verifyOtp,
      data: {'phone': phone, 'otp': otp},
      options: Options(headers: await _authHeadersIfAny()),
    );
    _ensureSuccess(res);
  }

  Future<void> submitServiceRequest(ServiceRequestDraft draft) async {
    // ✅ فلترة ملفات غير موجودة لتفادي crash
    final existingFiles = <File>[];
    for (final f in draft.files) {
      try {
        if (await f.exists()) existingFiles.add(f);
      } catch (_) {}
    }

    final formData = FormData.fromMap({
      'name': draft.name,
      'phone': draft.phone,

      // ✅✅ مهم: category_id لازم يكون رقم صحيح > 0
      'category_id': draft.categoryId,

      'city_id': draft.cityId,
      if (draft.areaId != null) 'area_id': draft.areaId,
      'description': draft.description,
      if (draft.budget != null) 'budget': draft.budget,

      'service_date_type': draft.serviceDateType,
      'service_date': draft.serviceDateIso,

      if (draft.serviceDateValueForApi != null)
        'service_date_value': draft.serviceDateValueForApi,

      'service_time': draft.serviceTimeHour,
      'share_phone': draft.sharePhoneWithProvider ? 1 : 0,

      if (draft.isGuest && draft.otp != null && draft.otp!.trim().isNotEmpty)
        'otp': draft.otp!.trim(),

      if (existingFiles.isNotEmpty)
        'files': [
          for (final f in existingFiles)
            await MultipartFile.fromFile(
              f.path,
              filename: f.path.split('/').last,
            ),
        ],
    });

    final path = draft.isGuest ? _serviceRequestsGuest : _serviceRequests;

    final res = await _dio.post(
      path,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: draft.isGuest ? const {'Accept': 'application/json'} : await _authHeadersIfAny(),
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
