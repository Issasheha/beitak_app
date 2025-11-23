// lib/features/auth/domain/usecases/verify_reset_code_usecase.dart

import '../repositories/auth_repository.dart';

/// UseCase: التحقق من كود إعادة تعيين كلمة المرور.
///
/// - يستخدم في شاشة إدخال الكود.
/// - لو الكود غير صحيح، الـ repository يرمي Exception / Failure.
class VerifyResetCodeUseCase {
  final AuthRepository _authRepository;

  const VerifyResetCodeUseCase(this._authRepository);

  Future<void> call({
    required String phone,
    required String code,
  }) {
    return _authRepository.verifyResetCode(
      phone: phone,
      code: code,
    );
  }
}
