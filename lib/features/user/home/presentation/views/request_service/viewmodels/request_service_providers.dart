// lib/features/user/home/presentation/views/request_service/viewmodels/request_service_providers.dart

import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'request_service_controller.dart';
import 'request_service_state.dart';
import 'request_service_viewmodel.dart';

final requestServiceControllerProvider =
    StateNotifierProvider.autoDispose<RequestServiceController, RequestServiceState>(
  (ref) {
    final vm = RequestServiceViewModel();
    final authLocal = AuthLocalDataSourceImpl();
    return RequestServiceController(vm, authLocal);
  },
);
