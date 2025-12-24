import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  // ================== Login ==================

  @override
  Future<AuthSessionEntity> loginWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final AuthSessionModel sessionModel = await _remote.loginWithIdentifier(
      identifier: identifier,
      password: password,
    );

    await _local.cacheAuthSession(sessionModel);

    return sessionModel.toEntity();
  }

  // ================== Signup ==================

  @override
  Future<AuthSessionEntity> signup({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required int cityId,
    required int areaId,
    String role = 'customer',
  }) async {
    final AuthSessionModel sessionModel = await _remote.signup(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
      role: role,
      cityId: cityId,
      areaId: areaId,
    );

    await _local.cacheAuthSession(sessionModel);

    return sessionModel.toEntity();
  }

  // ================== Reset Password / OTP ==================

  @override
  Future<void> sendResetCode({required String phone}) {
    return _remote.sendResetCode(phone: phone);
  }

  @override
  Future<void> verifyResetCode({
    required String phone,
    required String code,
  }) {
    return _remote.verifyResetCode(phone: phone, code: code);
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) {
    return _remote.resetPassword(
      phone: phone,
      code: code,
      newPassword: newPassword,
    );
  }

  // ================== Session / Logout / Guest ==================

  @override
  Future<AuthSessionEntity?> loadSavedSession() async {
    final sessionModel = await _local.getCachedAuthSession();
    return sessionModel?.toEntity();
  }

  @override
  Future<void> logout() async {
    await _local.clearSession();
  }

  @override
  Future<AuthSessionEntity> continueAsGuest() async {
    final guestSession = AuthSessionModel.guest();

    // ✅ ممنوع نخزّن الضيف (Runtime فقط)
    // await _local.cacheAuthSession(guestSession);

    return guestSession.toEntity();
  }
}
