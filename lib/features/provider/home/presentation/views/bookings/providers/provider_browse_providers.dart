import 'dart:async';

import 'package:beitak_app/features/provider/home/presentation/providers/provider_datasource_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/viewmodels/provider_browse_viewmodel.dart';
import 'package:flutter_riverpod/legacy.dart';

final providerBrowseViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ProviderBrowseViewModel, String?>((ref, initialTab) {
  final remote = ref.watch(providerDashboardRemoteDataSourceProvider);

  final vm = ProviderBrowseViewModel(remote: remote);

  final tab = (initialTab ?? '').toLowerCase().trim();
  if (tab == 'pending') {
    vm.setTab(ProviderBrowseTab.pending);
  } else if (tab == 'upcoming') {
    vm.setTab(ProviderBrowseTab.upcoming);
  }

  Future.microtask(vm.refresh);
  return vm;
});
