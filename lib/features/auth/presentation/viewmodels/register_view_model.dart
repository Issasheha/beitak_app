// lib/features/auth/presentation/viewmodels/register_view_model.dart
class RegisterViewModel {
  bool isSubmitting = false;
  String? errorMessage;

  /// يحاكي إرسال بيانات التسجيل إلى الخادم.
  /// لاحقًا يمكن ربطه مع AuthRepository / API حقيقية.
  Future<bool> submitRegistration() async {
    isSubmitting = true;
    errorMessage = null;
    try {
      // TODO: ربط مع API حقيقية (Dio + Repository)
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      errorMessage = 'تعذر إنشاء الحساب، حاول مرة أخرى.';
      return false;
    } finally {
      isSubmitting = false;
    }
  }
}
