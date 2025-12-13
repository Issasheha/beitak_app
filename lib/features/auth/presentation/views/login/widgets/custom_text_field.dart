import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixTap;
  final String? errorText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onSuffixTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = SizeConfig.w(15);
    final vertical = SizeConfig.h(13);
    final radius = SizeConfig.w(15);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: AppTextStyles.body14.copyWith(
        color: AppColors.textSecondary, // اللون الأساسي للنص
        fontSize: SizeConfig.ts(13.5), // نفس الحجم
        fontWeight: FontWeight.w400, // Regular (حسب توجه المصممة)
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body14.copyWith(
          color: AppColors.textPrimary.withValues(alpha: 0.6),
          fontSize: SizeConfig.ts(12.75), // نفس الحجم
          fontWeight: FontWeight.w400, // Regular
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.textPrimary,
          size: SizeConfig.w(22.5),
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(onTap: onSuffixTap, child: suffixIcon)
            : null,

        // باقي الكود زي ما هو...
        filled: true,
        fillColor: AppColors.darkGreen,
        errorText: errorText,
        errorStyle: AppTextStyles.caption11.copyWith(
          color: AppColors.goldAccent,
          fontSize: SizeConfig.ts(11.25), // نفس الحجم
          fontWeight: FontWeight.w400,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: vertical,
          horizontal: horizontal,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: AppColors.lightGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: AppColors.goldAccent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
