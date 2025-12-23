import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'account_edit_state.dart';

class AccountEditController extends StateNotifier<AsyncValue<AccountEditState>> {
  final Ref ref;

  AccountEditController(this.ref) : super(const AsyncLoading()) {
    load();
  }

  String _s(dynamic v) => (v ?? '').toString().trim();

  Future<void> load() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final res = await ApiClient.dio.get(ApiConstants.authProfile);
      final user = (res.data?['data']?['user'] ?? {}) as Map<String, dynamic>;

      final first = _s(user['first_name']);
      final last = _s(user['last_name']);

      return AccountEditState(
        fullName: ('$first $last').trim(),
        email: _s(user['email']),
        phone: _s(user['phone']),
        isEmailVerified: user['is_verified'] == true,
        isPhoneVerified: true,
        isSavingProfile: false,
        isChangingPassword: false,
      );
    });
  }

  /// ✅ حفظ الاسم + الايميل فقط للـ provider (الرقم عبر OTP)
  Future<String?> saveProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'لم يتم تحميل البيانات بعد';

    state = AsyncData(current.copyWith(isSavingProfile: true));

    try {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length >= 2 ? parts.sublist(1).join(' ') : '';

      // role من session
      final local = ref.read(authLocalDataSourceProvider);
      final session = await local.getCachedAuthSession();
      final role = session?.user?.role ?? '';

      if (role == 'provider') {
        final res = await ApiClient.dio.patch(
          ApiConstants.providerProfilePatch,
          data: <String, dynamic>{
            'first_name': firstName,
            'last_name': lastName,
            'email': email.trim(),
            // ❌ phone لا يُرسل هنا (OTP endpoints)
          },
        );

        final provider =
            (res.data?['data']?['provider'] ?? {}) as Map<String, dynamic>;
        final user = (provider['user'] ?? {}) as Map<String, dynamic>;

        // ✅ update cache (phone نخليه من الموجود بالكاش/اليوزر)
        await local.updateCachedUser(
          firstName: _s(user['first_name']),
          lastName: _s(user['last_name']),
          email: _s(user['email']),
          phone: current.phone,
          role: role,
        );

        final updatedState = current.copyWith(
          fullName:
              ('${_s(user['first_name'])} ${_s(user['last_name'])}').trim(),
          email: _s(user['email']),
          phone: current.phone,
          isSavingProfile: false,
        );

        state = AsyncData(updatedState);
        return null;
      }

      // customer fallback
      await ApiClient.dio.put(
        ApiConstants.authProfile,
        data: <String, dynamic>{
          'first_name': firstName,
          'last_name': lastName,
          'email': email.trim(),
          'phone': phone.trim(),
        },
      );

      state = AsyncData(current.copyWith(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        isSavingProfile: false,
      ));

      return null;
    } on DioException catch (e) {
      state = AsyncData(current.copyWith(isSavingProfile: false));
      return _friendlyDio(e);
    } catch (_) {
      state = AsyncData(current.copyWith(isSavingProfile: false));
      return 'تعذر حفظ البيانات حالياً';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'لم يتم تحميل البيانات بعد';

    if (newPassword.trim() != confirmPassword.trim()) {
      return 'كلمتا المرور غير متطابقتين';
    }

    state = AsyncData(current.copyWith(isChangingPassword: true));

    try {
      await ApiClient.dio.put(
        ApiConstants.changePassword,
        data: <String, dynamic>{
          'current_password': currentPassword.trim(),
          'new_password': newPassword.trim(),
          'confirm_password': confirmPassword.trim(),
        },
      );

      state = AsyncData(current.copyWith(isChangingPassword: false));
      return null;
    } on DioException catch (e) {
      state = AsyncData(current.copyWith(isChangingPassword: false));
      return _friendlyDio(e);
    } catch (_) {
      state = AsyncData(current.copyWith(isChangingPassword: false));
      return 'تعذر تغيير كلمة المرور حالياً';
    }
  }

  // ===================== OTP Phone =====================

  Future<String?> requestPhoneOtp(String phone) async {
    final p = phone.trim();
    if (p.isEmpty) return 'الرجاء إدخال رقم الهاتف';

    try {
      await ApiClient.dio.post(
        ApiConstants.providerRequestPhoneOtp,
        data: <String, dynamic>{'phone': p},
      );
      return null;
    } on DioException catch (e) {
      return _friendlyDio(e);
    } catch (_) {
      return 'تعذر إرسال رمز التحقق حالياً';
    }
  }

  Future<String?> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    final p = phone.trim();
    final code = otp.trim();

    if (p.isEmpty) return 'رقم الهاتف غير صالح';
    if (code.isEmpty) return 'الرجاء إدخال رمز التحقق';

    try {
      await ApiClient.dio.post(
        ApiConstants.providerVerifyPhoneOtp,
        data: <String, dynamic>{
          'phone': p,
          'otp': code, // ✅ مطابق للباك
        },
      );

      // ✅ بعد نجاح التحقق: اعمل refresh من /auth/profile لتحديث الرقم
      final res = await ApiClient.dio.get(ApiConstants.authProfile);
      final user = (res.data?['data']?['user'] ?? {}) as Map<String, dynamic>;
      final newPhone = _s(user['phone']);
      final newEmail = _s(user['email']);
      final first = _s(user['first_name']);
      final last = _s(user['last_name']);

      final current = state.asData?.value;
      if (current != null) {
        state = AsyncData(current.copyWith(
          phone: newPhone.isNotEmpty ? newPhone : p,
          email: newEmail.isNotEmpty ? newEmail : current.email,
          fullName: ('$first $last').trim().isNotEmpty
              ? ('$first $last').trim()
              : current.fullName,
        ));
      }

      // ✅ update cache
      final local = ref.read(authLocalDataSourceProvider);
      await local.updateCachedUser(
        firstName: first,
        lastName: last,
        email: newEmail,
        phone: newPhone.isNotEmpty ? newPhone : p,
      );

      return null;
    } on DioException catch (e) {
      return _friendlyDio(e);
    } catch (_) {
      return 'تعذر تأكيد الرمز حالياً';
    }
  }

  String _friendlyDio(DioException e) {
    final code = e.response?.statusCode;
    final msg = _s(e.response?.data?['message']);

    if (code == 401) return 'انتهت الجلسة، أعد تسجيل الدخول';
    if (code == 403) return 'ليس لديك صلاحية';
    if (code == 404) return 'المسار غير موجود';

    // ✅ OTP messages (حسب الشائع + اللي ممكن يطلع عندكم)
    if (msg == 'otp_invalid' || msg == 'invalid_otp') return 'رمز التحقق غير صحيح';
    if (msg == 'otp_expired') return 'انتهت صلاحية الرمز، اطلب رمز جديد';
    if (msg == 'phone_already_used') return 'هذا الرقم مستخدم مسبقاً';
    if (msg.isNotEmpty) return msg;

    return 'خطأ بالشبكة، حاول مرة أخرى';
  }
}
