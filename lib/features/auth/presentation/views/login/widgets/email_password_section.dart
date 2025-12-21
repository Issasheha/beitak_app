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
    // قواعد بسيطة + مرنة:
    // - ممنوع مسافات
    // - @ واحدة
    // - الدومين لازم فيه نقطة
    // - ممنوع يبدأ/ينتهي بنقطة
    // - ممنوع ".."
    if (value.contains(' ')) return 'أدخل عنوان بريد إلكتروني صالح';

    final parts = value.split('@');
    if (parts.length != 2) return 'أدخل عنوان بريد إلكتروني صالح';

    final local = parts[0];
    final domain = parts[1];

    if (local.isEmpty ||
        domain.isEmpty ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        domain.startsWith('.') ||
        domain.endsWith('.') ||
        local.contains('..') ||
        domain.contains('..') ||
        !domain.contains('.')) {
      return 'أدخل عنوان بريد إلكتروني صالح';
    }

    final tld = domain.split('.').last;
    if (tld.length < 2) return 'أدخل عنوان بريد إلكتروني صالح';

    return null;
  } else {
    // Sign In spec: أرقام فقط، بدون رموز/مسافات
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'أدخل رقم هاتف صالح';
    if (value.length != 10) return 'أدخل رقم هاتف صالح';

    final okPrefix =
        value.startsWith('077') || value.startsWith('078') || value.startsWith('079');
    if (!okPrefix) return 'أدخل رقم هاتف صالح';

    return null;
  }
}

String? _validatePassword(String? v) {
  if (v == null || v.trim().isEmpty) return 'أدخل كلمة المرور';

  // doc للـSign In: مطلوب 8 أحرف على الأقل
  if (v.trim().length < 8) return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
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
