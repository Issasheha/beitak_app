// lib/features/user/home/presentation/viewmodels/request_service_viewmodel.dart

import 'dart:io';

/// ViewModel لشاشة "طلب خدمة جديدة".
///
/// حالياً:
/// - ما في اتصال حقيقي مع الـ backend، فقط يحاكي عملية الإرسال.
/// - جاهز لاحقاً تربطه مع Repository / UseCase لاستدعاء API.
class RequestServiceViewModel {
  bool isSubmitting = false;
  String? lastErrorMessage;

  Future<bool> submitRequest({
    required String categoryName,
    required String serviceName,
    required String description,
    required String city,
    required String address,
    DateTime? preferredDate,
    double? expectedPrice,
    String? phone,
    required bool sharePhone,
    File? imageFile,
  }) async {
    isSubmitting = true;
    lastErrorMessage = null;

    try {
      // TODO: هنا لاحقاً تربط مع Dio + Repository + Endpoint حقيقي
      // مثال:
      // final formData = FormData.fromMap({...});
      // final response = await _dio.post('/service-requests', data: formData);
      await Future.delayed(const Duration(seconds: 1)); // محاكاة تأخير الشبكة

      return true; // نفترض نجاح العملية حالياً
    } catch (e) {
      lastErrorMessage = 'تعذر إرسال الطلب حالياً، حاول مرة أخرى.';
      return false;
    } finally {
      isSubmitting = false;
    }
  }
}
