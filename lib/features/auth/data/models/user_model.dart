import '../../domain/entities/user_entity.dart';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? role;

  /// ✅ NEW: provider profile id (user.provider_profile.id) — مهم لـ GET /api/providers/:id
  final int? providerProfileId;

  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.role,
    this.providerProfileId,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
    int? providerProfileId,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      providerProfileId: providerProfileId ?? this.providerProfileId,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int? parseProviderProfileId(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    int? providerId;

    // ✅ 1) من login: user.provider_profile.id
    final pp = json['provider_profile'];
    if (pp is Map) {
      providerId = parseProviderProfileId(pp['id']);
    }

    // ✅ 2) fallback لو الباك رجّع provider_profile_id مباشرة
    providerId ??= parseProviderProfileId(json['provider_profile_id']);

    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: (json['first_name'] ?? '') as String,
      lastName: (json['last_name'] ?? '') as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      providerProfileId: providerId,
      isVerified: (json['is_verified'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'provider_profile_id': providerProfileId, // ✅ نخزّنه محليًا
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل الـ Model إلى Entity للـ Domain Layer.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      role: role,
      isVerified: isVerified,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
