// email_field.dart
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_text_field.dart';
import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final TextEditingController? controller;

  const EmailField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return RegisterTextField(
      controller: controller,
      label: 'البريد الإلكتروني',
      hint: 'ahmad@example.com',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) {
          // مطلوب فقط إذا الهاتف فارغ → هذا متحقق على مستوى الـ Form
          return null;
        }

        final emailRegex =
            RegExp(r'^[^.][\w\-.]+@([\w-]+\.)+[\w-]{2,4}[^.]$');

        final hasSpaces = v.contains(' ');
        final hasDoubleDot = v.contains('..');
        final hasDoubleAt = v.contains('@@');
        final hasDot = v.contains('.');
        final startsWithDot = v.startsWith('.');
        final endsWithDot = v.endsWith('.');

        if (!emailRegex.hasMatch(v) ||
            hasSpaces ||
            hasDoubleDot ||
            hasDoubleAt ||
            !hasDot ||
            startsWithDot ||
            endsWithDot) {
          return 'يرجى إدخال بريد إلكتروني صالح.';
        }

        return null;
      },
    );
  }
}
