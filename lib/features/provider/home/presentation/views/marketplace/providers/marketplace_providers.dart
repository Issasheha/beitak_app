import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:beitak_app/core/network/api_client.dart'; // ✅ عدّلها إذا مسارك مختلف

import 'package:beitak_app/features/provider/home/data/datasources/marketplace_remote_data_source.dart';
import 'package:beitak_app/features/provider/home/data/datasources/marketplace_remote_data_source_impl.dart';
import 'package:beitak_app/features/provider/home/data/repositories/marketplace_repository_impl.dart';
import 'package:beitak_app/features/provider/home/domain/repositories/marketplace_repository.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/viewmodels/marketplace_controller.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/viewmodels/marketplace_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final marketplaceDioProvider = Provider<Dio>((ref) {
  return ApiClient.dio; // ✅ هذا لازم يكون dio اللي عندك فيه baseUrl + token interceptor
});

final marketplaceRemoteDataSourceProvider = Provider<MarketplaceRemoteDataSource>((ref) {
  return MarketplaceRemoteDataSourceImpl(dio: ref.read(marketplaceDioProvider));
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(remote: ref.read(marketplaceRemoteDataSourceProvider));
});

final marketplaceControllerProvider =
    StateNotifierProvider<MarketplaceController, MarketplaceState>((ref) {
  return MarketplaceController(repo: ref.read(marketplaceRepositoryProvider));
});
