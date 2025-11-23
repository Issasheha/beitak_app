// lib/features/auth/domain/usecases/login_with_identifier_usecase.dart

import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: تسجيل الدخول باستخدام (إيميل أو جوال) + كلمة سر.
///
/// هذا الـ UseCase هو اللي تستعمله في LoginViewModel.
/// ما فيه أي تفاصيل عن Dio أو JSON.
/// يتعامل فقط مع [AuthRepository].
class LoginWithIdentifierUseCase {
  final AuthRepository _authRepository;

  const LoginWithIdentifierUseCase(this._authRepository);

  /// [identifier]: ممكن يكون إيميل أو رقم جوال
  /// [password]: كلمة المرور
  Future<AuthSessionEntity> call({
    required String identifier,
    required String password,
  }) {
    return _authRepository.loginWithIdentifier(
      identifier: identifier,
      password: password,
    );
  }
}
