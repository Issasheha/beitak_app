// lib/features/auth/domain/usecases/reset_password_usecase.dart

import '../repositories/auth_repository.dart';

/// UseCase: تعيين كلمة مرور جديدة بعد التحقق من الكود.
///
/// - تستخدمه في شاشة "تعيين كلمة مرور جديدة".
class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  const ResetPasswordUseCase(this._authRepository);

  Future<void> call({
    required String phone,
    required String code,
    required String newPassword,
  }) {
    return _authRepository.resetPassword(
      phone: phone,
      code: code,
      newPassword: newPassword,
    );
  }
}
