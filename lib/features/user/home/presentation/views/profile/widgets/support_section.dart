import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'profile_action_item.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileActionItem(
          label: 'مركز المساعدة',
          icon: Icons.help_outline,
          onTap: () => context.push(AppRoutes.helpCenter),
        ),
        SizeConfig.v(12),
        ProfileActionItem(
          label: 'كن مقدم خدمة',
          icon: Icons.build_outlined,
          onTap: () => context.push(AppRoutes.providerApplication),
          color: AppColors.error,
        ),
        SizeConfig.v(12),
        ProfileActionItem(
          label: 'تسجيل الخروج',
          icon: Icons.logout,
          onTap: () {
            // لاحقًا: logout logic
            context.go(AppRoutes.login);
          },
          color: AppColors.error,
        ),
        SizeConfig.v(12),
        ProfileActionItem(
          label: 'حذف الحساب',
          icon: Icons.delete_forever,
          onTap: () {
            // لاحقًا: delete account logic
          },
          color: AppColors.error,
        ),
      ],
    );
  }
}