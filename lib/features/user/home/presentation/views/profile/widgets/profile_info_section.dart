// lib/features/home/presentation/views/profile_widgets/profile_info_section.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoField('الاسم الكامل', 'سارة أحمد', Icons.person_outline),
        SizeConfig.v(16),
        _buildInfoField('عنوان البريد الإلكتروني', 'sarah.ahmed@email.com', Icons.email_outlined),
        SizeConfig.v(16),
        _buildInfoField('رقم الهاتف', '+971 50 123 4567', Icons.phone_outlined),
      ],
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary)),
        SizeConfig.v(8),
        Container(
          padding: const  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.lightGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: SizeConfig.w(22)),
              SizeConfig.hSpace(12),
              Expanded(
                child: Text(value, style: TextStyle(fontSize: SizeConfig.ts(16), color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}