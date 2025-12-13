import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_history_controller.dart';
import 'provider_history_state.dart';

final providerHistoryControllerProvider =
    AsyncNotifierProvider.autoDispose<ProviderHistoryController,
        ProviderHistoryState>(
  ProviderHistoryController.new,
);
