import 'package:beitak_app/features/user/home/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:beitak_app/features/user/home/domain/usecases/change_password_usecase.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordViewModel({required this.changePasswordUseCase});

  bool _loading = false;
  String? _errorMessage;

  // ✅ خطأ مباشر لحقل كلمة المرور الحالية
  String? _currentPasswordError;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  String? get currentPasswordError => _currentPasswordError;

  void clearCurrentPasswordError() {
    if (_currentPasswordError != null) {
      _currentPasswordError = null;
      notifyListeners();
    }
  }

  Future<bool> submit({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _currentPasswordError = null;

    try {
      await changePasswordUseCase(
        ChangePasswordParams(
          currentPassword: currentPassword.trim(),
          newPassword: newPassword.trim(),
          confirmPassword: confirmPassword.trim(),
        ),
      );
      return true;
    } catch (e) {
      final mapped = _mapError(e);

      // ✅ إذا كان الخطأ متعلق بكلمة المرور الحالية، اربطه بالحقل
      if (_isCurrentPasswordWrong(mapped)) {
        _currentPasswordError = 'كلمة المرور الحالية غير صحيحة';
        _errorMessage = 'كلمة المرور الحالية غير صحيحة';
      } else {
        _errorMessage = mapped;
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool _isCurrentPasswordWrong(String msg) {
    final m = msg.toLowerCase();
    // إنجليزي شائع
    if (m.contains('current') && m.contains('password') &&
        (m.contains('incorrect') || m.contains('wrong') || m.contains('invalid'))) {
      return true;
    }
    // عربي شائع
    if (msg.contains('الحالية') && (msg.contains('غير') || msg.contains('خطأ'))) {
      return true;
    }
    return false;
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;

      if (status == 401) return 'انتهت الجلسة، سجل دخول مرة ثانية';
      if (status != null && status >= 500) return 'صار خطأ بالسيرفر، جرّب لاحقًا';

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message']?.toString().trim();
        if (msg != null && msg.isNotEmpty) {
          final lower = msg.toLowerCase();

          // ✅ تحويل رسائل إنجليزية شائعة لعربي واضح
          if (lower.contains('current') && lower.contains('password') &&
              (lower.contains('incorrect') || lower.contains('wrong') || lower.contains('invalid'))) {
            return 'كلمة المرور الحالية غير صحيحة';
          }

          if (lower.contains('confirm') && (lower.contains('match') || lower.contains('same'))) {
            return 'تأكيد كلمة المرور غير متطابق';
          }

          if (lower.contains('at least') && lower.contains('8')) {
            return 'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل';
          }

          return msg;
        }
      }

      // errors map
      if (data is Map && data['errors'] != null) {
        final errs = data['errors'];
        if (errs is Map && errs.isNotEmpty) {
          final firstKey = errs.keys.first.toString().toLowerCase();
          final firstVal = errs[errs.keys.first];

          if (firstVal is List && firstVal.isNotEmpty) {
            final msg = firstVal.first.toString();

            if (firstKey.contains('current') && firstKey.contains('password')) {
              return 'كلمة المرور الحالية غير صحيحة';
            }
            return msg;
          }
        }
      }

      return 'حدث خطأ، حاول مرة أخرى';
    }

    return 'حدث خطأ، حاول مرة أخرى';
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
