// lib/features/home/presentation/views/profile_widgets/profile_footer.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ProfileFooter extends StatelessWidget {
  const ProfileFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Baitak v1.0.0 • © 2025 جميع الحقوق محفوظة',
        style: TextStyle(
          fontSize: SizeConfig.ts(12),
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}