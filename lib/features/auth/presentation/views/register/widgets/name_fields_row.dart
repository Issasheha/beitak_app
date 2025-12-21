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
      crossAxisAlignment: CrossAxisAlignment.start, // ✅ مهم
      children: [
        Expanded(
          child: RegisterTextField(
            controller: firstNameController,
            label: 'الاسم الأول *',
            hint: 'أحمد',
            icon: Icons.person_outline,
            validator: _firstNameValidator,
            autofocus: true,
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

  // Helpers
  static bool _hasDigits(String s) => RegExp(r'\d').hasMatch(s);
  static bool _hasSymbols(String s) =>
      RegExp(r'[^\p{L}\s-]', unicode: true).hasMatch(s);
  static bool _lettersOnlyNoSpaces(String s) =>
      RegExp(r'^[\p{L}]+$', unicode: true).hasMatch(s);

  static String? _firstNameValidator(String? value) {
    final raw = value ?? '';
    final text = raw.trim();

    if (raw.isEmpty) return 'الاسم الأول مطلوب.';
    if (text.isEmpty) return 'لا يمكن إدخال مسافات فقط في الاسم الأول.';
    if (text.length < 2) return 'الاسم الأول يجب أن يكون حرفين على الأقل.';

    if (text.contains(' ')) return 'الاسم الأول يجب أن يكون بدون مسافات.';
    if (_hasDigits(text)) return 'الاسم الأول لا يجوز أن يحتوي أرقام.';
    if (!_lettersOnlyNoSpaces(text)) return 'الاسم الأول لا يجوز أن يحتوي رموز.';

    return null;
  }

  static String? _lastNameValidator(String? value) {
    final raw = value ?? '';
    final text = raw.trim();

    if (raw.isEmpty) return 'اسم العائلة مطلوب.';
    if (text.isEmpty) return 'لا يمكن إدخال مسافات فقط في اسم العائلة.';
    if (text.length < 2) return 'اسم العائلة يجب أن يكون حرفين على الأقل.';
        if (text.contains(' ')) return 'اسم العائلة يجب أن يكون بدون مسافات.';

    if (raw.startsWith(' ') || raw.endsWith(' ')) {
      return 'يرجى إزالة المسافات من بداية/نهاية اسم العائلة.';
    }

    if (_hasDigits(text)) return 'اسم العائلة لا يجوز أن يحتوي أرقام.';
    if (_hasSymbols(text)) return 'اسم العائلة لا يجوز أن يحتوي رموز.';

    final regex = RegExp(r'^[\p{L}]+(?:[ -][\p{L}]+)*$', unicode: true);
    if (!regex.hasMatch(text)) {
      return 'يرجى إدخال اسم عائلة صحيح (أحرف، مسافات وشرطات فقط).';
    }

    return null;
  }
}
