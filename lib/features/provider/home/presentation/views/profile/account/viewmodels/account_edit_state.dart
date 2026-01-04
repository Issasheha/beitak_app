// lib/features/provider/home/presentation/views/profile/account/account_edit_state.dart
import 'package:flutter/foundation.dart';

@immutable
class AccountEditState {
  final String fullName;
  final String email;
  final String phone;

  final bool isEmailVerified;
  final bool isPhoneVerified;

  final bool isSavingProfile;
  final bool isChangingPassword;

  // ✅ provider fields (مطلوبة للـ PATCH)
  final int providerId;
  final String businessName;
  final String bio;
  final int experienceYears;

  const AccountEditState({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isSavingProfile,
    required this.isChangingPassword,
    required this.providerId,
    required this.businessName,
    required this.bio,
    required this.experienceYears,
  });

  factory AccountEditState.initial() {
    return const AccountEditState(
      fullName: '',
      email: '',
      phone: '',
      isEmailVerified: false,
      isPhoneVerified: false,
      isSavingProfile: false,
      isChangingPassword: false,
      providerId: 0,
      businessName: '',
      bio: '',
      experienceYears: 0,
    );
  }

  AccountEditState copyWith({
    String? fullName,
    String? email,
    String? phone,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isSavingProfile,
    bool? isChangingPassword,
    int? providerId,
    String? businessName,
    String? bio,
    int? experienceYears,
  }) {
    return AccountEditState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isSavingProfile: isSavingProfile ?? this.isSavingProfile,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      providerId: providerId ?? this.providerId,
      businessName: businessName ?? this.businessName,
      bio: bio ?? this.bio,
      experienceYears: experienceYears ?? this.experienceYears,
    );
  }
}
