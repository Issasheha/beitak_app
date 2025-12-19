import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'account_edit_state.dart';

class AccountEditController extends StateNotifier<AsyncValue<AccountEditState>> {
  AccountEditController() : super(const AsyncValue.loading()) {
    _loadAccount();
  }

  // ================= تحميل بيانات الحساب =================

  Future<void> _loadAccount() async {
    try {
      final res = await ApiClient.dio.get(ApiConstants.authProfile);
      final nextState = _mapResponseToState(res.data);
      state = AsyncValue.data(nextState);
    } on DioException catch (e) {
      state = AsyncValue.error(_errorMessageFromDio(e), StackTrace.current);
    } catch (_) {
      state = const AsyncValue.error('فشل تحميل بيانات الحساب', StackTrace.empty);
    }
  }

  AccountEditState _mapResponseToState(dynamic data) {
    Map<String, dynamic> _asMap(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return <String, dynamic>{};
    }

    final root = _asMap(data);
    final dataNode = _asMap(root['data']);

    final user = _asMap(
      dataNode['user'] ??
          dataNode['profile'] ??
          (dataNode.isNotEmpty ? dataNode : root['user']),
    );

    final firstName =
        (user['first_name'] ?? user['firstname'] ?? '').toString().trim();
    final lastName =
        (user['last_name'] ?? user['lastname'] ?? '').toString().trim();
    final fullNameField =
        (user['full_name'] ?? user['name'] ?? '').toString().trim();

    final fullName = fullNameField.isNotEmpty
        ? fullNameField
        : [firstName, lastName].where((e) => e.isNotEmpty).join(' ').trim();

    final email = (user['email'] ?? '').toString().trim();
    final phone = (user['phone'] ?? '').toString().trim();

    bool _b(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    final isEmailVerified =
        _b(user['is_email_verified'] ?? user['email_verified']);
    final isPhoneVerified = _b(
      user['is_phone_verified'] ?? user['phone_verified'] ?? user['is_verified'],
    );

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

  // ================= تحديث الاسم / الإيميل =================
  // ملاحظة: السيرفر لا يسمح بإرسال phone على /auth/profile
  Future<String?> saveProfile({
    required String fullName,
    required String email,
    required String phone, // موجود بالـ UI بس مش راح نرسله
  }) async {
    final current = state.value ?? AccountEditState.initial();

    final normalizedFullName = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = normalizedFullName.split(' ');
    final firstName = parts.isNotEmpty ? parts.first.trim() : '';
    final lastName =
        parts.length > 1 ? parts.sublist(1).join(' ').trim() : '';

    final normalizedEmail = email.trim();

    state = AsyncValue.data(current.copyWith(isSavingProfile: true));

    try {
      await ApiClient.dio.put(
        ApiConstants.authProfile,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': normalizedEmail,
          // ❌ لا phone
        },
      );

      // ✅ أفضل ممارسة: نعمل reload بعد الحفظ حتى نضمن state مطابق للسيرفر
      await _loadAccount();
      // وبعد _loadAccount بيصير isSavingProfile false داخل state الجديد؟
      // لا، _loadAccount يرجع state جديد بدون saving flags، فتمام.

      return null;
    } on DioException catch (e) {
      state = AsyncValue.data(current.copyWith(isSavingProfile: false));
      return _errorMessageFromDio(e);
    } catch (_) {
      state = AsyncValue.data(current.copyWith(isSavingProfile: false));
      return 'حدث خطأ غير متوقع أثناء حفظ البيانات';
    }
  }

  // ================= تغيير كلمة المرور =================
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final current = state.value ?? AccountEditState.initial();

    state = AsyncValue.data(current.copyWith(isChangingPassword: true));

    try {
      await ApiClient.dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword.trim(),
          'new_password': newPassword.trim(),
          'confirm_password': confirmPassword.trim(),
        },
      );

      state = AsyncValue.data(current.copyWith(isChangingPassword: false));
      return null;
    } on DioException catch (e) {
      state = AsyncValue.data(current.copyWith(isChangingPassword: false));
      return _errorMessageFromDio(e);
    } catch (_) {
      state = AsyncValue.data(current.copyWith(isChangingPassword: false));
      return 'حدث خطأ غير متوقع أثناء تغيير كلمة المرور';
    }
  }

  String _errorMessageFromDio(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is Map && data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final first = (data['errors'] as List).first;
        if (first is Map && first['message'] != null) return first['message'].toString();
      }
    } catch (_) {}
    return 'خطأ في الاتصال بالخادم (${e.response?.statusCode ?? ''})';
  }
}
