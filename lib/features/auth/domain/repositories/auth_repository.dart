// lib/features/auth/domain/repositories/auth_repository.dart

import '../entities/auth_session_entity.dart';

/// Contract بين الـ Domain Layer و الـ Data Layer.
/// ViewModels (عبر UseCases) تتعامل مع هذا الـ interface فقط.
abstract class AuthRepository {
  /// تسجيل الدخول باستخدام إيميل أو رقم هاتف + كلمة سر.
  ///
  /// - [identifier]: إيميل أو رقم هاتف
  /// - [password]: كلمة المرور
  ///
  /// يرجع [AuthSessionEntity] تحتوي على:
  /// - token
  /// - user
  /// - isGuest = false
  Future<AuthSessionEntity> loginWithIdentifier({
    required String identifier,
    required String password,
  });

  /// إنشاء حساب جديد (تسجيل جديد).
  ///
  /// يطابق الـ backend:
  /// POST /api/auth/signup
  ///
  /// body:
  /// {
  ///   "first_name": "...",
  ///   "last_name": "...",
  ///   "phone": "...",
  ///   "email": "...",
  ///   "password": "...",
  ///   "role": "customer" | "provider",
  ///   "city_id": 1,
  ///   "area_id": 1
  /// }
  Future<AuthSessionEntity> signup({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required int cityId,
    required int areaId,
    String role = 'customer',
  });

  /// إرسال كود إعادة تعيين كلمة السر إلى رقم هاتف (أو لاحقًا إيميل).
  Future<void> sendResetCode({
    required String phone,
  });

  /// التحقق من كود إعادة التعيين.
  /// هنا نكتفي بالتحقق، والـ login يتم بعملية منفصلة (أنظف معماريًا).
  Future<void> verifyResetCode({
    required String phone,
    required String code,
  });

  /// تعيين كلمة سر جديدة بعد التحقق من الكود.
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });

  /// تحميل الجلسة المحفوظة (من التخزين المحلي).
  ///
  /// - ممكن ترجع:
  ///   - `null` إذا ما فيه جلسة محفوظة
  ///   - أو `AuthSessionEntity` (مستخدم أو guest)
  Future<AuthSessionEntity?> loadSavedSession();

  /// تسجيل خروج المستخدم:
  /// - تنظيف التوكن من التخزين المحلي
  /// - استدعاء API للـ logout لو موجودة (في الـ implementation).
  Future<void> logout();

  /// متابعة كضيف:
  ///
  /// - تستخدم لما يختار المستخدم “متابعة كزائر”
  /// - ممكن تحفظ حالة guest في local
  /// - ترجع [AuthSessionEntity] فيها isGuest = true.
  Future<AuthSessionEntity> continueAsGuest();
}
