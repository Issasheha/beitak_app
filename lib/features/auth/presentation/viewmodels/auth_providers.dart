import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:beitak_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:beitak_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:beitak_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'auth_controller.dart';
import 'auth_state.dart';

// ===== Data sources =====

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ApiClient.dio);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

// ===== Repository =====

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  );
});

// ===== Controller (Single Source of Truth) =====

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final controller = AuthController(repo);
  // bootstrap مرة واحدة عند الإنشاء
  controller.bootstrap();
  return controller;
});
