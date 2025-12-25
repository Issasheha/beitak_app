// lib/features/provider/home/presentation/views/profile/viewmodels/provider_profile_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'provider_profile_controller.dart';
import 'provider_profile_state.dart';

final providerProfileControllerProvider =
    StateNotifierProvider.autoDispose<ProviderProfileController, AsyncValue<ProviderProfileState>>(
  (ref) {
    ref.keepAlive();
    return ProviderProfileController(ref);
  },
);
