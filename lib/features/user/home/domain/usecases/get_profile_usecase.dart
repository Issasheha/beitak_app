// get_profile_usecase.dart
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repo;
  const GetProfileUseCase(this.repo);

  Future<UserProfileEntity> call() => repo.getProfile();
}
