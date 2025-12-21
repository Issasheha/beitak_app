// lib/features/auth/presentation/views/register/widgets/phone_field.dart
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_text_field.dart';
import 'package:flutter/material.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController? controller;

  /// لقاعدة: لازم رقم أو إيميل
  final TextEditingController? emailController;

  /// خطأ من الباك (مثلاً: رقم مكرر)
  final String? backendErrorText;

  const PhoneField({
    super.key,
    this.controller,
    this.emailController,
    this.backendErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return RegisterTextField(
      controller: controller,
      label: 'رقم الجوال',
      hint: '07X XXX XXXX',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        final raw = value ?? '';
        final v = raw.trim();

        final emailRaw = emailController?.text ?? '';
        final emailTrim = emailRaw.trim();

        // ✅ قاعدة: لازم وحدة تواصل (تظهر تحت الحقلين)
        if (v.isEmpty && emailTrim.isEmpty) {
          return 'يرجى إدخال(رقم الجوال أو البريد الإلكتروني).';
        }

        // إذا فاضي والهاتف مش مطلوب لأنه الإيميل موجود
        if (v.isEmpty) {
          return null;
        }

        // مسافات فقط
        if (raw.isNotEmpty && v.isEmpty) {
          return 'لا يمكن إدخال مسافات فقط في رقم الجوال.';
        }

        // أرقام فقط
        if (!RegExp(r'^\d+$').hasMatch(v)) {
          return 'رقم الجوال يجب أن يحتوي أرقام فقط.';
        }

        // 10 أرقام
        if (v.length != 10) {
          return 'رقم الجوال يجب أن يتكون من 10 أرقام.';
        }

        // يبدأ بـ 07
        if (!v.startsWith('07')) {
          return 'رقم الجوال يجب أن يبدأ بـ 07.';
        }

        // 077 / 078 / 079 (أرقام أردنية)
        final third = v[2];
        if (!(third == '7' || third == '8' || third == '9')) {
          return 'يرجى إدخال رقم جوال أردني صالح (077 ,078 , 079).';
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
