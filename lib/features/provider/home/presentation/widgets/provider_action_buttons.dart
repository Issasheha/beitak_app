import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderPrimaryActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const ProviderPrimaryActionBtn({
    super.key,
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightGreen,
        elevation: 0,
        padding: SizeConfig.padding(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: SizeConfig.w(18),
              height: SizeConfig.w(18),
              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: SizeConfig.ts(13),
              ),
            ),
    );
  }
}

class ProviderOutlineActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ProviderOutlineActionBtn({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderLight),
        padding: SizeConfig.padding(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: SizeConfig.ts(13),
        ),
      ),
    );
  }
}

class ProviderGreenDetailsButton extends StatelessWidget {
  const ProviderGreenDetailsButton({super.key, required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightGreen,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(18),
          vertical: SizeConfig.h(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: SizeConfig.ts(13),
        ),
      ),
    );
  }
}
