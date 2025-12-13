// lib/features/auth/presentation/views/widgets/register_widgets/register_text_field.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class RegisterTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;

  const RegisterTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الليبل فوق الحقل
        Text(
          label,
          style: AppTextStyles.body14.copyWith(
            color: AppColors.textPrimary,
            fontSize: SizeConfig.ts(14.5),
            fontWeight: FontWeight.w600, // نفس السابق
          ),
        ),
        const SizedBox(height: 9),

        // الحقل الأبيض المرفوع
        Material(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(18),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            autofocus: autofocus,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
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
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.darkGreen,
                size: SizeConfig.w(24),
              ),
              suffixIcon: suffixIcon,
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
                borderSide: const BorderSide(
                  color: AppColors.darkGreen,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
