// phone_field.dart
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_text_field.dart';
import 'package:flutter/material.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController? controller;

  const PhoneField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return RegisterTextField(
      controller: controller,
      label: 'رقم الجوال *',
      hint: '07X XXX XXXX',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) {
          // Required فقط إذا الإيميل فارغ → هذا متحقق على مستوى الـ Form
          return null;
        }

        // أرقام فقط
        if (!RegExp(r'^\d+$').hasMatch(v)) {
          return 'يرجى إدخال رقم هاتف صالح.';
        }

        // 10 أرقام
        if (v.length != 10) {
          return 'يرجى إدخال رقم هاتف صالح.';
        }

        // يبدأ بـ 07
        if (!v.startsWith('07')) {
          return 'يرجى إدخال رقم هاتف صالح.';
        }

        // 077 / 078 / 079
        final third = v[2];
        if (!(third == '7' || third == '8' || third == '9')) {
          return 'يرجى إدخال رقم هاتف صالح.';
        }

        return null;
      },
    );
  }
}
