// lib/features/auth/domain/usecases/logout_usecase.dart

import '../repositories/auth_repository.dart';

/// UseCase: تسجيل الخروج.
///
/// - ينادي الـ repository عشان:
///   - يمسح بيانات الجلسة من التخزين المحلي
///   - ينادي API logout لو موجودة في الـ implementation.
class LogoutUseCase {
  final AuthRepository _authRepository;

  const LogoutUseCase(this._authRepository);

  Future<void> call() {
    return _authRepository.logout();
  }
}
