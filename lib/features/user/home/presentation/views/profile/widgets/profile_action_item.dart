// lib/features/home/presentation/views/profile_widgets/profile_action_item.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ProfileActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const ProfileActionItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: SizeConfig.padding(vertical: 6),
        padding: SizeConfig.padding(all: 16),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primaryGreen).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.6),),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primaryGreen, size: SizeConfig.w(24)),
            SizeConfig.hSpace(16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary.withValues(alpha: 0.7), size: SizeConfig.w(16)),
          ],
        ),
      ),
    );
  }
}