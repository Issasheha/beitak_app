// lib/features/auth/presentation/views/register/widgets/name_fields_row.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_text_field.dart';

class NameFieldsRow extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const NameFieldsRow({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RegisterTextField(
            controller: firstNameController,
            label: 'الاسم الأول *',
            hint: 'أحمد',
            icon: Icons.person_outline,
            validator: _firstNameValidator,
            autofocus: true, // Auto-focus على أول حقل
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RegisterTextField(
            controller: lastNameController,
            label: 'اسم العائلة *',
            hint: 'محمد',
            icon: Icons.person_outline,
            validator: _lastNameValidator,
          ),
        ),
      ],
    );
  }

  /// First Name:
  /// - Required
  /// - Min 2 chars
  /// - Letters only (A–Z + Arabic)
  static String? _firstNameValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || text.length < 2) {
      return 'الرجاء إدخال اسم أول صحيح (أحرف فقط، حرفان على الأقل).';
    }

    final regex = RegExp(r'^[A-Za-z\u0600-\u06FF]+$');
    if (!regex.hasMatch(text)) {
      return 'الرجاء إدخال اسم أول صحيح (أحرف فقط، حرفان على الأقل).';
    }
    return null;
  }

  /// Last Name:
  /// - Required
  /// - Min 2 chars
  /// - Letters + spaces + hyphens
  /// - No leading/trailing spaces
  static String? _lastNameValidator(String? value) {
    final raw = value ?? '';
    final text = raw.trim();

    if (text.isEmpty || text.length < 2) {
      return 'الرجاء إدخال اسم عائلة صحيح (أحرف، مسافات وشرطات فقط، حرفان على الأقل).';
    }

    // لا نسمح بمسافة أول/آخر
    if (raw.startsWith(' ') || raw.endsWith(' ')) {
      return 'الرجاء إدخال اسم عائلة صحيح (أحرف، مسافات وشرطات فقط، حرفان على الأقل).';
    }

    final regex =
        RegExp(r'^[A-Za-z\u0600-\u06FF]+(?:[ -][A-Za-z\u0600-\u06FF]+)*$');
    if (!regex.hasMatch(text)) {
      return 'الرجاء إدخال اسم عائلة صحيح (أحرف، مسافات وشرطات فقط، حرفان على الأقل).';
    }

    return null;
  }
}
