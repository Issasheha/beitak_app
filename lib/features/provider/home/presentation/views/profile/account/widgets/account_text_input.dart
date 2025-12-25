// lib/features/provider/home/presentation/views/profile/account/widgets/account_text_input.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class AccountTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;

  const AccountTextInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.textInputAction,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: !enabled,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: AppTextStyles.body14.copyWith(
        fontSize: SizeConfig.ts(13.5),
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(13),
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: SizeConfig.padding(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.8),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: const BorderSide(
            color: AppColors.lightGreen,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
