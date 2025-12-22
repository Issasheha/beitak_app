import 'package:dio/dio.dart';

import 'package:beitak_app/features/user/home/domain/entities/user_profile_entity.dart';
import 'package:beitak_app/features/user/home/domain/entities/recent_activity_entity.dart';
import 'package:beitak_app/features/user/home/domain/usecases/get_profile_usecase.dart';
import 'package:beitak_app/features/user/home/domain/usecases/get_recent_activity_usecase.dart';
import 'package:beitak_app/features/user/home/domain/usecases/update_profile_usecase.dart';
import 'package:beitak_app/features/user/home/domain/usecases/upload_profile_image_usecase.dart';
import 'package:beitak_app/core/helpers/local_logout.dart';
import 'package:beitak_app/features/user/home/domain/repositories/profile_repository.dart'
    as pr;
import 'package:flutter_riverpod/legacy.dart';

import 'profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;
  final GetRecentActivityUseCase _getRecentActivityUseCase;

  ProfileController({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
    required GetRecentActivityUseCase getRecentActivityUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadProfileImageUseCase = uploadProfileImageUseCase,
        _getRecentActivityUseCase = getRecentActivityUseCase,
        super(const ProfileState.initial());

  /// نفس فكرة init القديمة: أول مرة نفتح البروفايل
  Future<void> init() async => refresh();

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    UserProfileEntity? profile;

    // 1) نجيب البروفايل
    try {
      profile = await _getProfileUseCase();
    } catch (e) {
      final msg = _mapError(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return;
    }

    // 2) نجيب آخر الأنشطة
    List<RecentActivityEntity> acts = const [];
    try {
      acts = await _getRecentActivityUseCase(limit: 10);
      acts.sort((a, b) => b.time.compareTo(a.time));
      acts = acts.take(10).toList();
    } catch (_) {
      acts = const [];
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: null,
      profile: profile,
      activities: acts,
    );
  }

 Future<bool> saveProfile({
  required String firstName,
  required String lastName,
  required String email,
  required String phone,
  String? address,

  /// (اختياري) لو بدك تمرّرهم من UI
  int? cityId,
  int? areaId,
}) async {
  state = state.copyWith(
    isLoading: true,
    clearError: true,
  );

  try {
    // ✅ تحايل مؤقت: خذهم من البروفايل الحالي
    // وإذا مش موجودين لأي سبب: fallback = 1
    final effectiveCityId = cityId ?? state.profile?.cityId ?? 1;
    final effectiveAreaId = areaId ?? state.profile?.areaId ?? 1;

    final updated = await _updateProfileUseCase(
      pr.UpdateProfileParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        cityId: effectiveCityId,
        areaId: effectiveAreaId,
        address: address,
      ),
    );

    // نحدّث البروفايل محلياً + نعمل refresh للـ activity من الباك
    state = state.copyWith(profile: updated);
    await refresh();
    return true;
  } catch (e) {
    final msg = _mapError(e);
    state = state.copyWith(
      isLoading: false,
      errorMessage: msg,
    );
    return false;
  }
}


  Future<bool> uploadImage(String filePath) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final updated = await _uploadProfileImageUseCase(filePath);
      state = state.copyWith(
        isLoading: false,
        profile: updated,
      );
      return true;
    } catch (e) {
      final msg = _mapError(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await LocalLogout.clearSessionOnly();
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;

      if (status == 401) {
        return 'انتهت الجلسة، سجل دخول مرة ثانية';
      }
      if (status != null && status >= 500) {
        return 'صار خطأ بالسيرفر، جرّب لاحقًا';
      }

      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        final msg = data['message']?.toString().trim();
        if (msg != null && msg.isNotEmpty) return msg;
      }

      // لو backend بيرجع errors بالشكل التقليدي
      if (data is Map && data['errors'] != null) {
        final errs = data['errors'];
        if (errs is Map && errs.isNotEmpty) {
          final firstKey = errs.keys.first;
          final firstVal = errs[firstKey];
          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          }
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'الاتصال بطيء، حاول مرة أخرى';
      }

      return 'حدث خطأ بالشبكة، حاول مرة أخرى';
    }

    return 'حدث خطأ، حاول مرة أخرى';
  }
}
