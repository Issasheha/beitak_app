import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/profile_action_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderSupportSection extends StatelessWidget {
  const ProviderSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // تغيير كلمة المرور (تفتح نفس ChangePasswordView الموجودة عندك)
        ProfileActionItem(
          label: 'تغيير كلمة المرور',
          icon: Icons.lock_outline,
          onTap: () => context.push(AppRoutes.changePassword),
        ),
        SizeConfig.v(12),

        // مركز المساعدة
        ProfileActionItem(
          label: 'مركز المساعدة',
          icon: Icons.help_outline,
          onTap: () => context.push(AppRoutes.helpCenter),
        ),
        SizeConfig.v(12),

        // تسجيل الخروج
        ProfileActionItem(
          label: 'تسجيل الخروج',
          icon: Icons.logout,
          color: AppColors.error,
          onTap: () {
            // TODO: هنا لاحقاً تضيف منطق تسجيل الخروج (مسح SharedPreferences مثلاً)
            context.go(AppRoutes.login);
          },
        ),
        SizeConfig.v(12),

        // حذف الحساب
        ProfileActionItem(
          label: 'حذف الحساب',
          icon: Icons.delete_forever,
          color: AppColors.error,
          onTap: () {
            // TODO: فتح Dialog تأكيد وحذف الحساب من الـ backend
          },
        ),
      ],
    );
  }
}
