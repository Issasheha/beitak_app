// lib/features/auth/presentation/views/register/widgets/password_fields.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_text_field.dart';
import 'package:flutter/material.dart';

class PasswordFields extends StatefulWidget {
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const PasswordFields({
    super.key,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  State<PasswordFields> createState() => _PasswordFieldsState();
}

class _PasswordFieldsState extends State<PasswordFields> {
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterTextField(
          controller: widget.passwordController,
          label: 'كلمة المرور *',
          hint: '••••••',
          icon: Icons.lock_outline,
          obscureText: _obscurePass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              size: 22,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
          // ✅ رسالة خطأ واحدة حسب الشرط الناقص
          validator: (value) => _passwordError(value),
        ),

        SizeConfig.v(16),

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
              size: 22,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          validator: (value) {
            final text = (value ?? '').trim();
            if (text.isEmpty) return 'تأكيد كلمة المرور مطلوب.';
            if (text != widget.passwordController.text) {
              return 'كلمتا المرور غير متطابقتين.';
            }
            return null;
          },
        ),
      ],
    );
  }

  String? _passwordError(String? value) {
    final text = (value ?? '');

    if (text.trim().isEmpty) {
      return 'كلمة المرور مطلوبة.';
    }

    // ممنوع مسافات
    if (text.contains(' ')) {
      return 'كلمة المرور يجب ألا تحتوي على مسافات.';
    }

    // طول أدنى
    if (text.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.';
    }

    // حرف كبير
    final hasUpper = RegExp(r'[A-Z]').hasMatch(text);
    if (!hasUpper) {
      return 'أضف حرفًا كبيرًا واحدًا على الأقل (A-Z).';
    }

    // رقم
    final hasDigit = RegExp(r'\d').hasMatch(text);
    if (!hasDigit) {
      return 'أضف رقمًا واحدًا على الأقل.';
    }

    // رمز خاص
    final hasSpecial = RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?]')
        .hasMatch(text);
    if (!hasSpecial) {
      return 'أضف رمزًا خاصًا واحدًا على الأقل مثل @ أو # أو \$';
    }

    return null;
  }
}
