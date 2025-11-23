// lib/features/auth/presentation/views/register/widgets/password_fields.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_text_field.dart';

class PasswordFields extends StatefulWidget {
  final VoidCallback? onSubmit;

  const PasswordFields({super.key, this.onSubmit});

  @override
  State<PasswordFields> createState() => _PasswordFieldsState();
}

class _PasswordFieldsState extends State<PasswordFields> {
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  static const String _passwordError =
      'كلمة المرور غير صالحة، يرجى مراجعة الشروط.';

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? value) {
    final v = value ?? '';
    final trimmed = v.trim();

    if (trimmed.isEmpty) {
      return _passwordError;
    }

    if (trimmed.length < 6) {
      return _passwordError;
    }

    // لا نسمح بمسافات
    if (v.contains(' ')) {
      return _passwordError;
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(trimmed);
    final hasDigit = RegExp(r'[0-9]').hasMatch(trimmed);
    final hasSpecial =
        RegExp(r'[!@#\$%^&*()_+\-=]').hasMatch(trimmed);

    if (!hasUppercase || !hasDigit || !hasSpecial) {
      return _passwordError;
    }

    return null;
  }

  String? _confirmValidator(String? value) {
    final v = value ?? '';
    if (v.isEmpty) {
      return 'كلمتا المرور غير متطابقتين.';
    }
    if (v != _passwordController.text) {
      return 'كلمتا المرور غير متطابقتين.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // حقل كلمة المرور
        RegisterTextField(
          controller: _passwordController,
          label: 'كلمة المرور *',
          hint: 'أدخل كلمة مرور قوية',
          icon: Icons.lock_outline,
          obscureText: _obscurePass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              size: 24,
            ),
            onPressed: () {
              setState(() => _obscurePass = !_obscurePass);
            },
          ),
          validator: _passwordValidator,
          textInputAction: TextInputAction.next,
        ),
        // نص الشروط الثابت تحت حقل كلمة المرور
        SizedBox(height: SizeConfig.h(6)),
        Text(
          'يجب أن تحتوي كلمة المرور على:\n'
          '• ٦ أحرف على الأقل\n'
          '• حرف كبير واحد (A–Z)\n'
          '• رقم واحد (0–9)\n'
          '• رمز خاص واحد (مثل @ أو # أو \$)\n'
          'ولا يُسمح بالمسافات.',
          style: TextStyle(
            fontSize: SizeConfig.ts(11.5),
            color: AppColors.textSecondary.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        // حقل تأكيد كلمة المرور
        RegisterTextField(
          controller: _confirmController,
          label: 'تأكيد كلمة المرور *',
          hint: 'أعد كتابة كلمة المرور',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              size: 24,
            ),
            onPressed: () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            },
          ),
          validator: _confirmValidator,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            // الضغط على Enter / تم يرسل الفورم
            widget.onSubmit?.call();
          },
        ),
      ],
    );
  }
}
