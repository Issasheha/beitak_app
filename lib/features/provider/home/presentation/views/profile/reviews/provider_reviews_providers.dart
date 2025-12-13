// lib/features/provider/home/presentation/views/reviews/provider_reviews_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_reviews_controller.dart';
import 'provider_reviews_state.dart';

final providerReviewsControllerProvider =
    AsyncNotifierProvider.autoDispose<ProviderReviewsController,
        ProviderReviewsState>(
  ProviderReviewsController.new,
);
