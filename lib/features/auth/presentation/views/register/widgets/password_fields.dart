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
            onPressed: () {
              setState(() => _obscurePass = !_obscurePass);
            },
          ),
          // رسالة خطأ مختصرة + شروط ثابتة تحت الحقل
          validator: (value) {
            final text = value ?? '';
            if (text.isEmpty) {
              return 'كلمة المرور مطلوبة.';
            }

            if (!_isValidPassword(text)) {
              return 'كلمة المرور غير صالحة، يرجى مراجعة الشروط أسفل الحقل.';
            }
            return null;
          },
        ),

        // شروط ثابتة صغيرة تحت حقل كلمة السر
        SizeConfig.v(6),
        Padding(
          padding: EdgeInsets.only(right: SizeConfig.w(4)),
          child: Text(
            '• 6 أحرف على الأقل\n'
            '• حرف كبير واحد على الأقل (A-Z)\n'
            '• رقم واحد على الأقل\n'
            '• رمز خاص واحد على الأقل (مثل @ أو # أو \$)\n'
            '• بدون مسافات',
            style: TextStyle(
              fontSize: SizeConfig.ts(11),
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
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
            onPressed: () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            },
          ),
          validator: (value) {
            final text = value ?? '';
            if (text.isEmpty) {
              return 'تأكيد كلمة المرور مطلوب.';
            }
            if (text != widget.passwordController.text) {
              return 'كلمتا المرور غير متطابقتين.';
            }
            return null;
          },
        ),
      ],
    );
  }

  bool _isValidPassword(String value) {
    if (value.length < 6) return false;
    if (value.contains(' ')) return false;

    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?]').hasMatch(value);

    return hasUpper && hasDigit && hasSpecial;
  }
}
