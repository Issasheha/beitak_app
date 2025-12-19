import 'package:flutter_riverpod/legacy.dart';

import 'provider_ratings_controller.dart';
import 'provider_ratings_state.dart';

final providerRatingsControllerProvider =
    StateNotifierProvider.autoDispose.family<
        ProviderRatingsController,
        ProviderRatingsState,
        int>(
  (ref, providerId) => ProviderRatingsController(providerId: providerId),
);
