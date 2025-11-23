// lib/features/auth/domain/entities/auth_session_entity.dart

import 'user_entity.dart';

/// يمثّل حالة الجلسة الحالية في التطبيق:
/// - مستخدم مسجّل دخول (مع token و UserEntity)
/// - أو ضيف (isGuest = true)
class AuthSessionEntity {
  final String? token;
  final UserEntity? user;
  final bool isGuest;

  /// وقت انتهاء التوكن (لو الباك إند يدعمها مستقبلاً)
  final DateTime? expiresAt;

  const AuthSessionEntity({
    this.token,
    this.user,
    this.isGuest = false,
    this.expiresAt,
  });

  /// هل المستخدم مصدَّق عليه فعلاً؟
  bool get isAuthenticated =>
      !isGuest && token != null && token!.isNotEmpty && user != null;

  /// هل الجلسة منتهية (بناءً على expiresAt لو استخدمناها)؟
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
