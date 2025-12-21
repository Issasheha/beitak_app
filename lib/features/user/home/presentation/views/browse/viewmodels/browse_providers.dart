// lib/features/user/home/presentation/views/browse/viewmodels/browse_providers.dart

import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_controller.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_services_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final browseControllerProvider =
    StateNotifierProvider.autoDispose.family<BrowseController, BrowseState, BrowseArgs>(
  (ref, args) {
    final vm = BrowseServicesViewModel(ref);
    final controller = BrowseController(viewModel: vm, args: args);
    return controller;
  },
);
