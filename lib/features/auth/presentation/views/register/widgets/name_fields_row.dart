// lib/features/auth/presentation/views/widgets/register_widgets/name_fields_row.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_text_field.dart';

class NameFieldsRow extends StatelessWidget {
  const NameFieldsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: RegisterTextField(
            label: 'الاسم الأول *',
            hint: 'أحمد',
            icon: Icons.person_outline,
            validator: _firstNameValidator,
            autofocus: true, // تركيز تلقائي عند فتح صفحة التسجيل
            textInputAction: TextInputAction.next,
          ),
        ),
         SizedBox(width: 12),
        Expanded(
          child: RegisterTextField(
            label: 'اسم العائلة *',
            hint: 'محمد',
            icon: Icons.person_outline,
            validator: _lastNameValidator,
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
    );
  }

  /// First Name:
  /// - مطلوب
  /// - 2 أحرف على الأقل
  /// - أحرف فقط (عربي/إنجليزي)
  static String? _firstNameValidator(String? value) {
    const error =
        'يرجى إدخال اسم أول صالح (أحرف فقط، حرفان على الأقل).';

    if (value == null) return error;
    final trimmed = value.trim();

    if (trimmed.isEmpty || trimmed.length < 2) {
      return error;
    }

    final regex = RegExp(r'^[A-Za-z\u0600-\u06FF]+$');
    if (!regex.hasMatch(trimmed)) {
      return error;
    }

    return null;
  }

  /// Last Name:
  /// - مطلوب
  /// - 2 أحرف على الأقل
  /// - أحرف + مسافات + شرطة -
  /// - لا مسافات في البداية/النهاية
  static String? _lastNameValidator(String? value) {
    const error =
        'يرجى إدخال اسم عائلة صالح (أحرف، مسافات، وشرطات فقط، حرفان على الأقل).';

    if (value == null) return error;

    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length < 2) {
      return error;
    }

    final regex =
        RegExp(r'^[A-Za-z\u0600-\u06FF]+([ -][A-Za-z\u0600-\u06FF]+)*$');
    if (!regex.hasMatch(trimmed)) {
      return error;
    }

    return null;
  }
}
