
/// ViewModel بسيط لشاشة "الملف الشخصي".
///
/// حالياً:
/// - يحتوي بيانات وهمية (dummy) للمستخدم.
/// - يوفر دالة لتحديث البيانات بعد التعديل.
/// لاحقاً يمكن ربطه مع AuthRepository / API لجلب بيانات المستخدم الحقيقية.
class ProfileViewModel {
  String fullName;
  String email;
  String phone;

  ProfileViewModel({
    this.fullName = 'سارة أحمد',
    this.email = 'sarah.ahmed@email.com',
    this.phone = '+962 79 123 4567',
  });

  void updateProfile({
    String? fullName,
    String? email,
    String? phone,
  }) {
    if (fullName != null) {
      this.fullName = fullName;
    }
    if (email != null) {
      this.email = email;
    }
    if (phone != null) {
      this.phone = phone;
    }
  }
}
