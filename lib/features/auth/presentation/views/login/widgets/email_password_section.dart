import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/login_text_field.dart';
import 'package:flutter/material.dart';

class EmailPasswordSection extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback? onForgotPassword;
  final FocusNode? identifierFocus; // FocusNode لحقل الإيميل/الهاتف
  final FocusNode? passwordFocus; // FocusNode لحقل كلمة المرور
  final VoidCallback? onPasswordSubmitted; // للإرسال عند Enter في كلمة المرور

  const EmailPasswordSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    this.isLoading = false,
    this.onForgotPassword,
    this.identifierFocus,
    this.passwordFocus,
    this.onPasswordSubmitted,
  });

  @override
  State<EmailPasswordSection> createState() => _EmailPasswordSectionState();
}

class _EmailPasswordSectionState extends State<EmailPasswordSection> {
  bool _obscure = true;

  static const double _fieldSpacing = 15.0;
  static const double _bottomSpacing = 18.0;

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  String? _validateIdentifier(String? v) {
    if (v == null) return 'أدخل بريدك الإلكتروني أو رقم هاتفك';

    final value = v.trim();
    if (value.isEmpty) return 'أدخل بريدك الإلكتروني أو رقم هاتفك';

    final isEmail = value.contains('@');

    if (isEmail) {
      final emailRegex = RegExp(r'^[^.][\w\-.]+@([\w-]+\.)+[\w-]{2,4}[^.]$');
      if (!emailRegex.hasMatch(value) ||
          value.contains('..') ||
          value.contains('@@') ||
          value.contains(' ') ||
          !value.contains('.') ||
          value.startsWith('.') ||
          value.endsWith('.')) {
        return 'أدخل عنوان بريد إلكتروني صالح';
      }
    } else {
      final normalized = value.replaceAll(RegExp(r'\D'), '');
      if (normalized.length != 10 ||
          !normalized.startsWith('07') ||
          !['5', '7', '8', '9'].contains(normalized[2])) {
        return 'أدخل رقم هاتف صالح';
      }
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'أدخل كلمة المرور';

    final trimmed = v.trim();
    if (trimmed.length < 8) return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
    if (v.contains(' ')) return 'كلمة المرور لا يمكن أن تحتوي على مسافات';
    if (!RegExp(r'[0-9]').hasMatch(trimmed)) {
      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Identifier Field (إيميل أو هاتف)
          LoginTextField(
            controller: widget.emailController,
            hint: 'أدخل بريدك الإلكتروني أو رقم هاتفك',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.text,
            validator: _validateIdentifier,
            focusNode: widget.identifierFocus,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(widget.passwordFocus);
            },
          ),
          SizedBox(height: SizeConfig.h(_fieldSpacing)),

          // Password Field
          LoginTextField(
            controller: widget.passwordController,
            hint: 'كلمة المرور',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscure,
            suffixIcon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              color: AppColors.buttonBackground,
              size: 24,
            ),
            onSuffixTap: _toggleObscure,
            validator: _validatePassword,
            focusNode: widget.passwordFocus,
            onFieldSubmitted: (_) => widget.onPasswordSubmitted?.call(),
          ),
          SizedBox(height: SizeConfig.h(_bottomSpacing)),

          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onForgotPassword,
              child: Text(
                'هل نسيت كلمة السر؟',
                style: AppTextStyles.body16.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
