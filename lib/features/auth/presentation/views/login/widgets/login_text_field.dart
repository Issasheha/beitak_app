import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;

  final String hint;

  /// ✅ Label فوق الحقل
  final String? label;

  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;

  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;

  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  /// ✅ لتصفية الإدخال (مثل منع مسافات)
  final List<TextInputFormatter>? inputFormatters;

  /// ✅ خطأ خارجي (سيرفر) يظهر تحت الحقل بدل SnackBar
  final String? errorText;

  /// ✅ لمسح خطأ السيرفر عند الكتابة
  final ValueChanged<String>? onChanged;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // ✅ نستخدم Align يمين للـlabel
      children: [
        if (label != null) ...[
          Align(
            alignment: Alignment.centerRight, // ✅ يمين دائمًا
            child: Padding(
              padding: EdgeInsets.only(bottom: SizeConfig.h(6)),
              child: Text(
                label!,
                textAlign: TextAlign.right,
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.ts(13),
                ),
              ),
            ),
          ),
        ],
        Material(
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(18),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted,
            inputFormatters: inputFormatters,
            onChanged: onChanged,

            enableInteractiveSelection: true,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,

            style: AppTextStyles.body14.copyWith(
              color: AppColors.textPrimary,
              fontSize: SizeConfig.ts(14.5),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body14.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.5),
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: AppColors.darkGreen,
                size: SizeConfig.w(24),
              ),
              suffixIcon: suffixIcon != null
                  ? GestureDetector(onTap: onSuffixTap, child: suffixIcon)
                  : null,

              // ✅ أهم سطر: خطأ السيرفر تحت الحقل
              errorText: errorText,

              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeConfig.w(20),
                vertical: SizeConfig.h(19),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    const BorderSide(color: AppColors.darkGreen, width: 2.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
