// lib/features/auth/domain/usecases/send_reset_code_usecase.dart

import '../repositories/auth_repository.dart';

/// UseCase: إرسال كود إعادة تعيين كلمة المرور.
///
/// - يستعمل في شاشة "نسيت كلمة المرور".
/// - يأخذ رقم جوال (أو لاحقًا إيميل لو حبيت توسّع).
class SendResetCodeUseCase {
  final AuthRepository _authRepository;

  const SendResetCodeUseCase(this._authRepository);

  Future<void> call({required String phone}) {
    return _authRepository.sendResetCode(phone: phone);
  }
}
