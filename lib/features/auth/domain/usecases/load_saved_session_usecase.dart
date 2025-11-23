// lib/features/auth/domain/usecases/load_saved_session_usecase.dart

import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: تحميل الجلسة المحفوظة محليًا (إن وجدت).
///
/// تستعمله مثلاً في:
/// - SplashViewModel
/// - AuthGateViewModel
///
/// عشان تعرف:
/// - هل المستخدم مسجل دخول؟
/// - ولا ضيف؟
/// - ولا ما فيه أي جلسة؟
class LoadSavedSessionUseCase {
  final AuthRepository _authRepository;

  const LoadSavedSessionUseCase(this._authRepository);

  Future<AuthSessionEntity?> call() {
    return _authRepository.loadSavedSession();
  }
}
