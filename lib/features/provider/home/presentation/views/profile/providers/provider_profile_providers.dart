import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../viewmodels/provider_profile_controller.dart';
import '../viewmodels/provider_profile_state.dart';

final providerProfileControllerProvider = StateNotifierProvider.autoDispose<
    ProviderProfileController, AsyncValue<ProviderProfileState>>(
  (ref) => ProviderProfileController(),
);
