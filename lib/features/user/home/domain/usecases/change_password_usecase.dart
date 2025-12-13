import '../repositories/profile_repository.dart';

class ChangePasswordUseCase {
  final ProfileRepository repo;
  const ChangePasswordUseCase(this.repo);

  Future<void> call(ChangePasswordParams params) => repo.changePassword(params);
}
