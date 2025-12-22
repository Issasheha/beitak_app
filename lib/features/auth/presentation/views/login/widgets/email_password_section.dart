import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/login_text_field.dart';

class EmailPasswordSection extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback? onForgotPassword;

  final FocusNode? identifierFocus;
  final FocusNode? passwordFocus;
  final VoidCallback? onPasswordSubmitted;

  /// ✅ أخطاء سيرفر تظهر تحت الحقول
  final String? identifierErrorText;
  final String? passwordErrorText;

  /// ✅ لمسح خطأ السيرفر عند الكتابة
  final VoidCallback? onIdentifierChanged;
  final VoidCallback? onPasswordChanged;

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
    this.identifierErrorText,
    this.passwordErrorText,
    this.onIdentifierChanged,
    this.onPasswordChanged,
  });

  @override
  State<EmailPasswordSection> createState() => _EmailPasswordSectionState();
}

class _EmailPasswordSectionState extends State<EmailPasswordSection> {
  bool _obscure = true;

  static const double _fieldSpacing = 15.0;
  static const double _bottomSpacing = 18.0;

  void _toggleObscure() => setState(() => _obscure = !_obscure);

  // ✅ تحويل أرقام عربية/فارسية -> إنجليزية
  String _normalizeArabicDigits(String input) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) {
      input = input.replaceAll(ar[i], en[i]);
    }
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < fa.length; i++) {
      input = input.replaceAll(fa[i], en[i]);
    }
    return input;
  }

  // ✅ استخراج أرقام فقط (يشيل - مسافة .. إلخ)
  String _digitsOnly(String input) {
    final normalized = _normalizeArabicDigits(input);
    return normalized.replaceAll(RegExp(r'\D'), '');
  }

  String? _validateIdentifier(String? v) {
    if (v == null) return 'أدخل بريدك الإلكتروني أو رقم هاتفك';
    final raw = v.trim();
    if (raw.isEmpty) return 'أدخل بريدك الإلكتروني أو رقم هاتفك';

    final value = _normalizeArabicDigits(raw);
    final isEmail = value.contains('@');

    if (isEmail) {
      if (RegExp(r'\s').hasMatch(value)) return 'أدخل عنوان بريد إلكتروني صالح';

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
      // ✅ هنا الحل: نقبل ٠٧٨-٦٠٤٦٠١١ .. ونحوّله ل digits only
      final digits = _digitsOnly(value);

      if (digits.length != 10) return 'أدخل رقم هاتف صالح';
      if (!digits.startsWith('07')) return 'أدخل رقم هاتف صالح';

      final okPrefix =
          digits.startsWith('077') || digits.startsWith('078') || digits.startsWith('079');
      if (!okPrefix) return 'أدخل رقم هاتف صالح';

      return null;
    }
  }

  String? _validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'أدخل كلمة المرور';

    // ✅ منع أي مسافات
    if (RegExp(r'\s').hasMatch(v)) {
      return 'كلمة المرور لا يمكن أن تحتوي على مسافات';
    }

    if (v.length < 8) return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoginTextField(
            controller: widget.emailController,
            label: 'البريد الإلكتروني أو رقم الهاتف',
            hint: 'أدخل بريدك الإلكتروني أو رقم هاتفك',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.text,
            validator: _validateIdentifier,
            focusNode: widget.identifierFocus,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(widget.passwordFocus);
            },
            errorText: widget.identifierErrorText,
            onChanged: (_) => widget.onIdentifierChanged?.call(),

            // ✅ اختياري: نمنع المسافات (بس نسمح بشرطات/أرقام/رموز عشان ما نضايق المستخدم)
            // إذا بدك تشدد أكثر خبرني.
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
          ),
          SizedBox(height: SizeConfig.h(_fieldSpacing)),

          LoginTextField(
            controller: widget.passwordController,
            label: 'كلمة المرور',
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
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            errorText: widget.passwordErrorText,
            onChanged: (_) => widget.onPasswordChanged?.call(),
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
