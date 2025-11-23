// lib/features/auth/domain/entities/user_entity.dart

/// Entity تمثّل المستخدم داخل الـ Domain Layer.
/// ما فيها أي تفاصيل JSON أو Dio أو Flutter.
/// تقدر توسّعها لاحقًا حسب ما تحتاج من بيانات من الـ backend.
class UserEntity {
  final int id;
  final String firstName;
  final String lastName;

  final String? email;
  final String? phone;
  final String? role; // user / provider / admin ...

  final bool isVerified;
  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.role,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// اسم كامل جاهز للـ UI
  String get fullName => '$firstName $lastName';

  /// هل المستخدم مزوّد خدمة؟ (مؤقتًا بناءً على الـ role)
  bool get isProvider => role == 'provider' || role == 'service_provider';
}
