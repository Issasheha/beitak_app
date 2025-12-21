// lib/features/auth/presentation/views/provider/providers/provider_application_state.dart

class ProviderApplicationState {
  final bool isSubmitting;
  final String? errorMessage;

  /// ✅ صار عندنا تسجيل مبكر: إذا true يعني Step 0 تم وتخزن التوكن
  final bool isRegistered;

  const ProviderApplicationState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isRegistered = false,
  });

  ProviderApplicationState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? isRegistered,
  }) {
    return ProviderApplicationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
