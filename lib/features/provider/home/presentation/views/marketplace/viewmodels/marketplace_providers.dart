import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:beitak_app/core/network/api_client.dart';

import 'package:beitak_app/features/provider/home/presentation/views/marketplace/data/marketplace_remote_data_source.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/data/marketplace_remote_data_source_impl.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/viewmodels/marketplace_controller.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/viewmodels/marketplace_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final marketplaceDioProvider = Provider<Dio>((ref) {
  return ApiClient.dio;
});

final marketplaceRemoteDataSourceProvider =
    Provider<MarketplaceRemoteDataSource>((ref) {
  return MarketplaceRemoteDataSourceImpl(
    dio: ref.read(marketplaceDioProvider),
  );
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(
    remote: ref.read(marketplaceRemoteDataSourceProvider),
  );
});

final marketplaceControllerProvider =
    StateNotifierProvider.autoDispose<MarketplaceController, MarketplaceState>(
        (ref) {
  final controller =
      MarketplaceController(repo: ref.read(marketplaceRepositoryProvider));

  ref.onDispose(() {});

  return controller;
});
