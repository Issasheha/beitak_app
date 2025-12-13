import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repo;
  const UpdateProfileUseCase(this.repo);

  Future<UserProfileEntity> call(UpdateProfileParams params) =>
      repo.updateProfile(params);
}
