import '../entities/recent_activity_entity.dart';
import '../entities/user_profile_entity.dart';


class UpdateProfileParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? address;

  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}


abstract class ProfileRepository {
  Future<UserProfileEntity> getProfile();
  Future<UserProfileEntity> updateProfile(UpdateProfileParams params);
  Future<UserProfileEntity> uploadProfileImage(String filePath);
  Future<List<RecentActivityEntity>> getRecentActivity({int limit = 10});
  Future<void> changePassword(ChangePasswordParams params);
  Future<void> deleteAccount();

}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
}
