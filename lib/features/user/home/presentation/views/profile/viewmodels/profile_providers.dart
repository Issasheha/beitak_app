import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/features/user/home/data/datasources/profile_remote_datasource.dart';
import 'package:beitak_app/features/user/home/data/repositories/profile_repository_impl.dart';
import 'package:beitak_app/features/user/home/domain/usecases/get_profile_usecase.dart';
import 'package:beitak_app/features/user/home/domain/usecases/get_recent_activity_usecase.dart';
import 'package:beitak_app/features/user/home/domain/usecases/update_profile_usecase.dart';
import 'package:beitak_app/features/user/home/domain/usecases/upload_profile_image_usecase.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'profile_controller.dart';
import 'profile_state.dart';

/// Remote data source
final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ApiClient.dio);
});

/// Repository (implementation)
final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  final remote = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remote);
});

/// UseCases

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return GetProfileUseCase(repo);
});

final getRecentActivityUseCaseProvider =
    Provider<GetRecentActivityUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return GetRecentActivityUseCase(repo);
});

final updateProfileUseCaseProvider =
    Provider<UpdateProfileUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repo);
});

final uploadProfileImageUseCaseProvider =
    Provider<UploadProfileImageUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return UploadProfileImageUseCase(repo);
});

/// Controller + State

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>(
  (ref) => ProfileController(
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
    uploadProfileImageUseCase:
        ref.watch(uploadProfileImageUseCaseProvider),
    getRecentActivityUseCase:
        ref.watch(getRecentActivityUseCaseProvider),
  ),
);
