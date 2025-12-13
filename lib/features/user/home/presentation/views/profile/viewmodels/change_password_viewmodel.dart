import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:beitak_app/features/user/home/domain/usecases/change_password_usecase.dart';
import 'package:beitak_app/features/user/home/domain/repositories/profile_repository.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordViewModel({required this.changePasswordUseCase});

  bool _loading = false;
  String? _errorMessage;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  Future<bool> submit({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;

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
      _errorMessage = _mapError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;

      if (status == 401) return 'انتهت الجلسة، سجل دخول مرة ثانية';
      if (status != null && status >= 500) return 'صار خطأ بالسيرفر، جرّب لاحقًا';

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message']?.toString().trim();
        if (msg != null && msg.isNotEmpty) return msg;
      }

      // لو backend بيرجع errors
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

      return 'حدث خطأ، حاول مرة أخرى';
    }

    return 'حدث خطأ، حاول مرة أخرى';
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
