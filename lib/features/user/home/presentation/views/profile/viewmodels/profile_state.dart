import 'package:flutter/foundation.dart';

import 'package:beitak_app/features/user/home/domain/entities/user_profile_entity.dart';
import 'package:beitak_app/features/user/home/domain/entities/recent_activity_entity.dart';

@immutable
class ProfileState {
  final bool isLoading;
  final String? errorMessage;
  final UserProfileEntity? profile;
  final List<RecentActivityEntity> activities;

  const ProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.profile,
    this.activities = const [],
  });

  const ProfileState.initial()
      : isLoading = false,
        errorMessage = null,
        profile = null,
        activities = const [];

  ProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    UserProfileEntity? profile,
    List<RecentActivityEntity>? activities,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      profile: profile ?? this.profile,
      activities: activities ?? this.activities,
    );
  }
}
