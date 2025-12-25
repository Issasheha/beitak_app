// lib/features/provider/home/presentation/views/profile/documents/viewmodels/provider_documents_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_documents_controller.dart';
import 'provider_documents_state.dart';

final providerDocumentsControllerProvider =
    AsyncNotifierProvider<ProviderDocumentsController, ProviderDocumentsState>(
  ProviderDocumentsController.new,
);
