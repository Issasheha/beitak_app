import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_controller.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final providerProfileControllerProvider = StateNotifierProvider.autoDispose<
    ProviderProfileController,
    AsyncValue<ProviderProfileState>>(
  (ref) => ProviderProfileController(),
);
