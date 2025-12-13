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
        throw ServerException(
          message: data['message']?.toString() ?? 'فشل إنشاء حساب المزوّد',
          statusCode: response.statusCode ?? 0,
        );
      }

      final payload = data['data'];
      if (payload is! Map<String, dynamic>) {
        throw const ServerException(message: 'Invalid response payload');
      }

      final sessionModel = AuthSessionModel.fromJson({
        ...payload,
        'is_guest': false,
      });

      await _local.cacheAuthSession(sessionModel);
      return true;
    } on DioException catch (e) {
      final resp = e.response?.data;
      final msg = (resp is Map<String, dynamic>)
          ? (resp['message']?.toString() ?? 'تعذر الاتصال بالخادم')
          : 'تعذر الاتصال بالخادم، تأكد من الاتصال بالإنترنت';
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

      formData.fields.addAll([
        MapEntry('business_name', businessName),
        MapEntry('bio', bio),
        MapEntry('experience_years', experienceYears.toString()),
        MapEntry('hourly_rate', hourlyRate.toString()),
        MapEntry('working_hours', workingHoursJson),
      ]);

      for (final lang in languages) {
        formData.fields.add(MapEntry('languages[]', lang));
      }
      for (final area in serviceAreas) {
        formData.fields.add(MapEntry('service_areas[]', area));
      }
      for (final d in availableDays) {
        formData.fields.add(MapEntry('available_days[]', d));
      }

      if (idDocPath != null && idDocPath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'id_verified_image',
            await MultipartFile.fromFile(idDocPath,
                filename: p.basename(idDocPath)),
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
        throw ServerException(
          message: data['message']?.toString() ?? 'فشل إكمال ملف مزوّد الخدمة',
        );
      }

      return true;
    } on DioException catch (e) {
      final resp = e.response?.data;
      final msg = (resp is Map<String, dynamic>)
          ? (resp['message']?.toString() ?? 'تعذر إكمال ملف مزوّد الخدمة')
          : 'تعذر الاتصال بالخادم أثناء إكمال الملف';
      state = state.copyWith(errorMessage: msg);
      return false;
    } on ServerException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      state =
          state.copyWith(errorMessage: 'حدث خطأ غير متوقع أثناء إكمال الملف');
      return false;
    }
  }
}
