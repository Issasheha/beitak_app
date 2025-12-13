// upload_profile_image_usecase.dart
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UploadProfileImageUseCase {
  final ProfileRepository repo;
  const UploadProfileImageUseCase(this.repo);

  Future<UserProfileEntity> call(String filePath) => repo.uploadProfileImage(filePath);
}
