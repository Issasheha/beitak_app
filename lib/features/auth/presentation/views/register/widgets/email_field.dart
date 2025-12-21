// lib/features/auth/presentation/views/register/widgets/email_field.dart
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_text_field.dart';
import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final TextEditingController? controller;

  /// لقاعدة: لازم رقم أو إيميل
  final TextEditingController? phoneController;

  /// خطأ من الباك (مثلاً: إيميل مكرر)
  final String? backendErrorText;

  const EmailField({
    super.key,
    this.controller,
    this.phoneController,
    this.backendErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return RegisterTextField(
      controller: controller,
      label: 'البريد الإلكتروني',
      hint: 'ahmad@example.com',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        final raw = value ?? '';
        final v = raw.trim();

        final phoneRaw = phoneController?.text ?? '';
        final phoneTrim = phoneRaw.trim();

        // ✅ قاعدة: لازم وحدة تواصل (تظهر تحت الحقلين)
        if (v.isEmpty && phoneTrim.isEmpty) {
          return 'يرجى إدخال(رقم الجوال أو البريد الإلكتروني).';
        }

        // إذا فاضي والإيميل مش مطلوب لأنه الهاتف موجود
        if (v.isEmpty) {
          return null;
        }

        // مسافات فقط
        if (raw.isNotEmpty && v.isEmpty) {
          return 'لا يمكن إدخال مسافات فقط في البريد الإلكتروني.';
        }

        // مسافات داخل البريد
        if (v.contains(' ')) {
          return 'البريد الإلكتروني لا يجب أن يحتوي مسافات.';
        }

        // Regex أبسط وواضح
        final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
        if (!emailRegex.hasMatch(v)) {
          return 'صيغة البريد الإلكتروني غير صحيحة (مثال: name@example.com).';
        }

        // ✅ خطأ من الباك (مكرر مثلاً)
        if (backendErrorText != null && backendErrorText!.trim().isNotEmpty) {
          return backendErrorText;
        }

        return null;
      },
    );
  }
}
