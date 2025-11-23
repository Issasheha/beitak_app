// lib/features/auth/data/models/auth_session_model.dart

import '../../domain/entities/auth_session_entity.dart';
import 'user_model.dart';

class AuthSessionModel {
  final String? token;
  final UserModel? user;
  final bool isGuest;
  final bool isNewUser;
  final DateTime? expiresAt;

  const AuthSessionModel({
    this.token,
    this.user,
    this.isGuest = false,
    this.isNewUser = false,
    this.expiresAt,
  });

  /// Factory جاهز لإنشاء جلسة Guest.
  factory AuthSessionModel.guest() {
    return const AuthSessionModel(
      token: null,
      user: null,
      isGuest: true,
      isNewUser: false,
    );
  }

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: json['token'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      isGuest: (json['is_guest'] as bool?) ?? false,
      isNewUser: (json['is_new_user'] as bool?) ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
      'is_guest': isGuest,
      'is_new_user': isNewUser,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// تحويل الـ Model إلى Entity للـ Domain Layer.
  AuthSessionEntity toEntity() {
    return AuthSessionEntity(
      token: token,
      user: user?.toEntity(),
      isGuest: isGuest,
      expiresAt: expiresAt,
    );
  }
}
