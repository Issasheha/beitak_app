// lib/features/auth/domain/usecases/signup_usecase.dart

import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: إنشاء حساب جديد (Sign up)
///
/// يستدعي [AuthRepository.signup] ويرجع [AuthSessionEntity]
class SignupUseCase {
  final AuthRepository _authRepository;

  const SignupUseCase(this._authRepository);

  Future<AuthSessionEntity> call({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required int cityId,
    required int areaId,
    String role = 'customer',
  }) {
    return _authRepository.signup(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
      cityId: cityId,
      areaId: areaId,
      role: role,
    );
  }
}
