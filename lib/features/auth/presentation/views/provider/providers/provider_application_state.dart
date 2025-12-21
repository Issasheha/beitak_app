class ProviderApplicationState {
  final bool isSubmitting;
  final String? errorMessage;

  // ✅ لتثبيت حالة التسجيل المبكر (حتى نمنع إعادة register)
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
