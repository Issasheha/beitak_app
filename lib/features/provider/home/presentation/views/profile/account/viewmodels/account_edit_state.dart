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

  const AccountEditState({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isSavingProfile,
    required this.isChangingPassword,
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
  }) {
    return AccountEditState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isSavingProfile: isSavingProfile ?? this.isSavingProfile,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
    );
  }
}
