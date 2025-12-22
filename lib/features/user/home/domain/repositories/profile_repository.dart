import '../entities/recent_activity_entity.dart';
import '../entities/user_profile_entity.dart';


class UpdateProfileParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  /// ✅ Required by backend currently
  final int cityId;
  final int areaId;

  /// Optional
  final String? address;

  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.cityId,
    required this.areaId,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,

      // ✅ backend fields
      "city_id": cityId,
      "area_id": areaId,
    };

    // ✅ لا تبعث address إذا null (عشان ما تعمل overwrite)
    if (address != null) {
      map["address"] = address;
    }

    return map;
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
