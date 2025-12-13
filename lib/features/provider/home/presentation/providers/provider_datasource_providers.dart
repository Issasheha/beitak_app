import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/features/provider/home/data/datasources/provider_dashboard_remote_datasource.dart';

/// Shared Remote DS for provider home/browse/etc.
final providerDashboardRemoteDataSourceProvider =
    Provider<ProviderDashboardRemoteDataSource>((ref) {
  return ProviderDashboardRemoteDataSource();
});
