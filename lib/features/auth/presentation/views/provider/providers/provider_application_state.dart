// lib/features/auth/presentation/views/provider/providers/provider_application_state.dart

class ProviderApplicationState {
  final bool isSubmitting;
  final String? errorMessage;

  const ProviderApplicationState({
    this.isSubmitting = false,
    this.errorMessage,
  });

  ProviderApplicationState copyWith({
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ProviderApplicationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}
