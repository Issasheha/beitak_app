import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_documents_controller.dart';
import 'provider_documents_state.dart';

final providerDocumentsControllerProvider =
    AsyncNotifierProvider.autoDispose<ProviderDocumentsController, ProviderDocumentsState>(
  ProviderDocumentsController.new,
);
