// lib/features/auth/domain/usecases/continue_as_guest_usecase.dart

import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: متابعة كضيف.
///
/// - تستخدمه لو عندك زر "متابعة كزائر".
/// - ممكن يحفظ Flag في local إن المستخدم ضيف.
/// - يرجع [AuthSessionEntity] فيها isGuest = true.
class ContinueAsGuestUseCase {
  final AuthRepository _authRepository;

  const ContinueAsGuestUseCase(this._authRepository);

  Future<AuthSessionEntity> call() {
    return _authRepository.continueAsGuest();
  }
}
