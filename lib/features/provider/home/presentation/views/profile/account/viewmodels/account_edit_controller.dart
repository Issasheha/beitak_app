import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'account_edit_state.dart';

class AccountEditController extends StateNotifier<AsyncValue<AccountEditState>> {
  AccountEditController(this.ref) : super(const AsyncLoading()) {
    load();
  }

  final Ref ref;

  int _reqId = 0; // ✅ لمنع race بين load/refresh

  String _s(dynamic v) => (v ?? '').toString().trim();

  Future<AccountEditState> _fetchProfile() async {
    final res = await ApiClient.dio.get(ApiConstants.authProfile);
    final root = res.data ?? {};
    final data = root['data'] ?? root;

    final user = (data is Map && data['user'] is Map)
        ? data['user'] as Map
        : (data is Map ? data : <String, dynamic>{});

    final fullName = '${_s(user['first_name'])} ${_s(user['last_name'])}'.trim();
    final email = _s(user['email']);
    final phone = _s(user['phone']);

    final isEmailVerified =
        user['email_verified'] == true || user['email_verified_at'] != null;
    final isPhoneVerified =
        user['phone_verified'] == true || user['phone_verified_at'] != null;

    return AccountEditState(
      fullName: fullName,
      email: email,
      phone: phone,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      isSavingProfile: false,
      isChangingPassword: false,
    );
  }

  Future<void> load() async {
    final id = ++_reqId;
    state = const AsyncLoading();

    try {
      final profile = await _fetchProfile();
      if (id != _reqId) return; // ✅ تجاهل نتيجة قديمة
      state = AsyncData(profile);
    } on DioException catch (e, st) {
      if (id != _reqId) return;
      state = AsyncError(e, st);
    } catch (e, st) {
      if (id != _reqId) return;
      state = AsyncError(e, st);
    }
  }

  Future<void> _refreshSilently({
    bool keepSavingProfile = false,
    bool keepChangingPassword = false,
  }) async {
    try {
      final current = state.asData?.value;
      final profile = await _fetchProfile();

      state = AsyncData(
        profile.copyWith(
          isSavingProfile: keepSavingProfile ? (current?.isSavingProfile ?? false) : false,
          isChangingPassword:
              keepChangingPassword ? (current?.isChangingPassword ?? false) : false,
        ),
      );
    } catch (_) {
      // تجاهل
    }
  }

  Future<String?> saveProfile({
    required String fullName,
    required String email,
    String? phone, // (واجهة فقط)
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'تعذر حفظ البيانات حالياً';

    // ✅ لا تعمل state churn كثير
    state = AsyncData(current.copyWith(isSavingProfile: true));

    try {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      await ApiClient.dio.patch(
        ApiConstants.providerProfilePatch,
        data: {
          'email': email.trim(),
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      // ✅ هات أحدث بيانات لكن خلي saving flag true لحين ما نخلص
      await _refreshSilently(keepSavingProfile: true);

      final now = state.asData?.value;
      if (now != null) {
        state = AsyncData(now.copyWith(isSavingProfile: false));
      } else {
        state = AsyncData(current.copyWith(isSavingProfile: false));
      }

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
    String? confirmPassword, // واجهة فقط
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'تعذر تحديث كلمة المرور';

    state = AsyncData(current.copyWith(isChangingPassword: true));

    try {
      await ApiClient.dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      final now = state.asData?.value ?? current;
      state = AsyncData(now.copyWith(isChangingPassword: false));
      return null;
    } on DioException catch (e) {
      state = AsyncData(current.copyWith(isChangingPassword: false));
      return _friendlyDio(e);
    } catch (_) {
      state = AsyncData(current.copyWith(isChangingPassword: false));
      return 'تعذر تحديث كلمة المرور';
    }
  }

  Future<String?> requestPhoneOtp(String phone) async {
    try {
      await ApiClient.dio
          .post(ApiConstants.providerRequestPhoneOtp, data: {'phone': phone});
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
    try {
      await ApiClient.dio.post(
        ApiConstants.providerVerifyPhoneOtp,
        data: {'phone': phone, 'otp': otp},
      );

      await _refreshSilently();
      return null;
    } on DioException catch (e) {
      return _friendlyDio(e);
    } catch (_) {
      return 'تعذر تأكيد الرقم حالياً';
    }
  }

  String _friendlyDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;

    String msg = '';
    if (data is Map) msg = (data['message'] ?? data['error'] ?? '').toString();
    if (data is String) msg = data;

    if (code == 400) return msg.isNotEmpty ? msg : 'بيانات غير صحيحة';
    if (code == 401) return 'انتهت الجلسة، أعد تسجيل الدخول';
    if (code == 403) return 'ليس لديك صلاحية';

    if (msg == 'otp_invalid' || msg == 'invalid_otp') return 'رمز التحقق غير صحيح';
    if (msg == 'otp_expired') return 'انتهت صلاحية الرمز، اطلب رمز جديد';
    if (msg == 'phone_already_used') return 'هذا الرقم مستخدم مسبقاً';
    if (msg.isNotEmpty) return msg;

    return 'خطأ بالشبكة، حاول مرة أخرى';
  }
}
