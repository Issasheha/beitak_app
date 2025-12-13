import 'package:beitak_app/features/provider/home/presentation/viewmodels/provider_home_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/providers/provider_datasource_providers.dart';
import 'package:flutter_riverpod/legacy.dart';

final providerHomeViewModelProvider =
    ChangeNotifierProvider.autoDispose<ProviderHomeViewModel>((ref) {
  final remote = ref.watch(providerDashboardRemoteDataSourceProvider);

  return ProviderHomeViewModel(
    remote: remote,
    initialName: 'الياس شهاب',
  );
});
