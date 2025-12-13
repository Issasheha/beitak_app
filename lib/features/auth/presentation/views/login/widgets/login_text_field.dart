import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode; // جديد: للتركيز التلقائي والتحكم
  final ValueChanged<String>? onFieldSubmitted; // جديد: للإرسال عند Enter

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
        style: AppTextStyles.body14.copyWith(
          color: AppColors.textPrimary,
          fontSize: SizeConfig.ts(14.5),
          fontWeight: FontWeight.w500, // نفس السابق
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body14.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.5),
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w400, // hint غالبًا Regular
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.darkGreen,
            size: SizeConfig.w(24),
          ),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: suffixIcon,
                )
              : null,
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
            borderSide: const BorderSide(color: AppColors.darkGreen, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}
