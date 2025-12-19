// lib/features/auth/presentation/views/provider/providers/provider_application_controller.dart

import 'dart:convert';

import 'package:beitak_app/core/error/exceptions.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:beitak_app/features/auth/data/models/auth_session_model.dart';
import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path/path.dart' as p;

import 'provider_application_state.dart';

final providerApplicationControllerProvider = StateNotifierProvider<
    ProviderApplicationController, ProviderApplicationState>(
  (ref) {
    final dio = ApiClient.dio;
    final local = AuthLocalDataSourceImpl();
    final authCtrl = ref.read(authControllerProvider.notifier);

    return ProviderApplicationController(
      dio: dio,
      local: local,
      authControllerReload: authCtrl.reload,
    );
  },
);

class ProviderApplicationController
    extends StateNotifier<ProviderApplicationState> {
  final Dio _dio;
  final AuthLocalDataSource _local;
  final Future<void> Function() _authControllerReload;

  ProviderApplicationController({
    required Dio dio,
    required AuthLocalDataSource local,
    required Future<void> Function() authControllerReload,
  })  : _dio = dio,
        _local = local,
        _authControllerReload = authControllerReload,
        super(const ProviderApplicationState());

  Future<bool> submitFullApplication({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    required String password,
    required String businessName,
    required String bio,
    required int experienceYears,
    required double hourlyRate,
    required List<String> languages,
    required List<String> serviceAreas,
    required List<String> availableDaysAr,
    required String workingStart,
    required String workingEnd,
    String? idDocPath,
    String? licenseDocPath,
    String? policeDocPath,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final registered = await _registerProvider(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
      );
      if (!registered) return false;

      final completed = await _completeProviderProfile(
        businessName: businessName,
        bio: bio,
        experienceYears: experienceYears,
        hourlyRate: hourlyRate,
        languages: languages,
        serviceAreas: serviceAreas,
        availableDaysAr: availableDaysAr,
        workingStart: workingStart,
        workingEnd: workingEnd,
        idDocPath: idDocPath,
        licenseDocPath: licenseDocPath,
        policeDocPath: policeDocPath,
      );
      if (!completed) return false;

      await _authControllerReload();
      return true;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<bool> _registerProvider({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'password': password,
      };

      if (phone != null && phone.trim().isNotEmpty) {
        body['phone'] = phone.trim();
      }

      if (email != null && email.trim().isNotEmpty) {
        body['email'] = email.trim();
      }

      final response =
          await _dio.post(ApiConstants.providerRegister, data: body);

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const ServerException(message: 'Invalid response format');
      }

      if (data['success'] != true) {
        // ✅ حاول نقرأ status / errors لو موجودين (pending/rejected/suspended وغيرها)
        final msg = _extractBackendMessage(data) ?? 'فشل إنشاء حساب المزوّد';
        final statusText = _extractProviderStatus(data);
        final finalMsg = _mapProviderStatusMessage(statusText) ?? msg;

        throw ServerException(
          message: finalMsg,
          statusCode: response.statusCode ?? 0,
        );
      }

      final payload = data['data'];
      if (payload is! Map<String, dynamic>) {
        throw const ServerException(message: 'Invalid response payload');
      }

      // ✅ لو الباك رجع status ضمن data بعد التسجيل
      final statusText = _extractProviderStatus(data);
      final statusMsg = _mapProviderStatusMessage(statusText);
      if (statusMsg != null) {
        state = state.copyWith(errorMessage: statusMsg);
        return false;
      }

      final sessionModel = AuthSessionModel.fromJson({
        ...payload,
        'is_guest': false,
      });

      await _local.cacheAuthSession(sessionModel);
      return true;
    } on DioException catch (e) {
      final msg = _mapDioErrorToMessage(e);
      state = state.copyWith(errorMessage: msg);
      return false;
    } on ServerException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      state =
          state.copyWith(errorMessage: 'حدث خطأ غير متوقع أثناء إنشاء الحساب');
      return false;
    }
  }

  Future<bool> _completeProviderProfile({
  required String businessName,
  required String bio,
  required int experienceYears,
  required double hourlyRate,
  required List<String> languages,
  required List<String> serviceAreas,
  required List<String> availableDaysAr,
  required String workingStart,
  required String workingEnd,
  String? idDocPath,
  String? licenseDocPath,
  String? policeDocPath,
}) async {
  try {
    const dayMap = {
      'السبت': 'saturday',
      'الأحد': 'sunday',
      'الاثنين': 'monday',
      'الثلاثاء': 'tuesday',
      'الأربعاء': 'wednesday',
      'الخميس': 'thursday',
      'الجمعة': 'friday',
    };

    final availableDays =
        availableDaysAr.map((d) => dayMap[d.trim()] ?? d.trim()).toList();

    final workingHoursJson = jsonEncode({
      'start': workingStart,
      'end': workingEnd,
    });

    final formData = FormData();

    // إذا businessName/bio فاضيين بعد trim → ما نضيفهم للـ FormData
    final bn = businessName.trim();
    final b = bio.trim();

    if (bn.isNotEmpty) {
      formData.fields.add(MapEntry('business_name', bn));
    }

    if (b.isNotEmpty) {
      formData.fields.add(MapEntry('bio', b));
    }

    formData.fields.addAll([
      MapEntry('experience_years', experienceYears.toString()),
      MapEntry('hourly_rate', hourlyRate.toString()),
      MapEntry('working_hours', workingHoursJson),
    ]);

    for (final lang in languages) {
      final v = lang.trim();
      if (v.isNotEmpty) formData.fields.add(MapEntry('languages[]', v));
    }

    for (final area in serviceAreas) {
      final v = area.trim();
      if (v.isNotEmpty) formData.fields.add(MapEntry('service_areas[]', v));
    }

    for (final d in availableDays) {
      final v = d.trim();
      if (v.isNotEmpty) formData.fields.add(MapEntry('available_days[]', v));
    }

    if (idDocPath != null && idDocPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'id_verified_image',
          await MultipartFile.fromFile(
            idDocPath,
            filename: p.basename(idDocPath),
          ),
        ),
      );
    }

    if (licenseDocPath != null && licenseDocPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'vocational_license_image',
          await MultipartFile.fromFile(
            licenseDocPath,
            filename: p.basename(licenseDocPath),
          ),
        ),
      );
    }

    if (policeDocPath != null && policeDocPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'police_clearance_image',
          await MultipartFile.fromFile(
            policeDocPath,
            filename: p.basename(policeDocPath),
          ),
        ),
      );
    }

    final response = await _dio.post(
      ApiConstants.providerCompleteProfile,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ServerException(message: 'Invalid response format');
    }

    if (data['success'] != true) {
      final msg = _extractBackendMessage(data) ?? 'فشل إكمال ملف مزوّد الخدمة';
      final statusText = _extractProviderStatus(data);
      final finalMsg = _mapProviderStatusMessage(statusText) ?? msg;
      throw ServerException(message: finalMsg);
    }

    // ✅ status مثل pending بعد النجاح = معلومة فقط
    // لا نعمل return false ولا نخزنها في errorMessage
    // (اعرضها بالـ UI إذا بدك بعد ok==true)
    return true;
  } on DioException catch (e) {
    final msg = _mapDioErrorToMessage(e);
    state = state.copyWith(errorMessage: msg);
    return false;
  } on ServerException catch (e) {
    state = state.copyWith(errorMessage: e.message);
    return false;
  } catch (_) {
    state = state.copyWith(errorMessage: 'حدث خطأ غير متوقع أثناء إكمال الملف');
    return false;
  }
}


  // =========================
  // Helpers (Strict, Form-level)
  // =========================

  String _mapDioErrorToMessage(DioException e) {
    final statusCode = e.response?.statusCode;
    final resp = e.response?.data;

    // ✅ Duplicate check (الأكثر شيوعاً 409)
    if (statusCode == 409) {
      return 'رقم الجوال أو البريد الإلكتروني مستخدم مسبقًا';
    }

    if (resp is Map<String, dynamic>) {
      // لو في message
      final msg = _extractBackendMessage(resp);

      // لو في errors (Laravel-style) مثلاً: {errors: {email:[...], phone:[...]}}
      final errorsMsg = _extractErrorsAsSingleMessage(resp);
      final combined = (errorsMsg ?? msg)?.trim();

      // إذا الرسالة بتدل على duplicate حتى لو مش 409
      final duplicateDetected = _looksLikeDuplicate(combined);

      if (duplicateDetected) {
        return 'رقم الجوال أو البريد الإلكتروني مستخدم مسبقًا';
      }

      // pending/rejected/suspended من الرسالة نفسها
      final statusText = _extractProviderStatus(resp) ?? combined;
      final statusMsg = _mapProviderStatusMessage(statusText);
      if (statusMsg != null) return statusMsg;

      if (combined != null && combined.isNotEmpty) return combined;
    }

    return 'تعذر الاتصال بالخادم، تأكد من الاتصال بالإنترنت';
  }

  String? _extractBackendMessage(Map<String, dynamic> data) {
    final m = data['message'];
    if (m == null) return null;
    final s = m.toString().trim();
    return s.isEmpty ? null : s;
    }

  String? _extractErrorsAsSingleMessage(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is! Map) return null;

    final buffer = <String>[];
    errors.forEach((k, v) {
      if (v is List && v.isNotEmpty) {
        buffer.add(v.first.toString());
      }
    });

    if (buffer.isEmpty) return null;
    // رسالة واحدة Form-level
    return buffer.join('\n');
  }

  bool _looksLikeDuplicate(String? msg) {
    if (msg == null) return false;
    final t = msg.toLowerCase();
    return t.contains('already') ||
        t.contains('exists') ||
        t.contains('taken') ||
        t.contains('duplicate') ||
        msg.contains('موجود') ||
        msg.contains('مستخدم') ||
        msg.contains('مسجل') ||
        msg.contains('سابقاً') ||
        msg.contains('سابقًا');
  }

  // نحاول نلقط status من أي مكان محتمل بالريسبونس
  String? _extractProviderStatus(Map<String, dynamic> data) {
    // حالات محتملة: data['status'], data['data']['status'], data['data']['provider']['status']...
    final s1 = data['status'];
    if (s1 != null) return s1.toString();

    final d = data['data'];
    if (d is Map<String, dynamic>) {
      final s2 = d['status'];
      if (s2 != null) return s2.toString();

      final provider = d['provider'];
      if (provider is Map<String, dynamic>) {
        final s3 = provider['status'];
        if (s3 != null) return s3.toString();
      }
    }

    return null;
  }

  String? _mapProviderStatusMessage(String? statusOrMessage) {
    if (statusOrMessage == null) return null;

    final t = statusOrMessage.toLowerCase();

    // إنجليزي
    if (t.contains('pending')) {
      return 'طلبك قيد المراجعة حاليًا (Pending).';
    }
    if (t.contains('rejected')) {
      return 'تم رفض طلبك (Rejected). يرجى التواصل مع الدعم أو تعديل بياناتك.';
    }
    if (t.contains('suspended') || t.contains('blocked')) {
      return 'حسابك موقوف مؤقتًا (Suspended). يرجى التواصل مع الدعم.';
    }

    // عربي
    if (statusOrMessage.contains('قيد المراجعة') ||
        statusOrMessage.contains('قيد الانتظار') ||
        statusOrMessage.contains('معلق')) {
      return 'طلبك قيد المراجعة حاليًا.';
    }

    if (statusOrMessage.contains('مرفوض') ||
        statusOrMessage.contains('تم الرفض')) {
      return 'تم رفض طلبك. يرجى التواصل مع الدعم أو تعديل بياناتك.';
    }

    if (statusOrMessage.contains('موقوف') ||
        statusOrMessage.contains('محظور')) {
      return 'حسابك موقوف مؤقتًا. يرجى التواصل مع الدعم.';
    }

    return null;
  }
}
