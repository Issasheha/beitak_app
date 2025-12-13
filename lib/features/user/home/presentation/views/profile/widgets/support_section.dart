import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';

class SupportSection extends ConsumerWidget {
  final Future<bool> Function() onDeleteAccount;

  const SupportSection({
    super.key,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _ActionTile(
          title: 'تغيير كلمة المرور',
          icon: Icons.lock_outline,
          color: AppColors.lightGreen,
          onTap: () {
            context.push(AppRoutes.changePassword);
          },
        ),
        SizedBox(height: SizeConfig.h(10)),
        _ActionTile(
          title: 'تسجيل الخروج',
          icon: Icons.logout,
          color: Colors.redAccent,
          onTap: () async {
            await ref
                .read(authControllerProvider.notifier)
                .logout();
            // GoRouter redirect رح يوديك /login تلقائيًا
          },
        ),
        SizedBox(height: SizeConfig.h(10)),
        _ActionTile(
          title: 'حذف الحساب',
          icon: Icons.delete_forever,
          color: Colors.red,
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('تأكيد حذف الحساب'),
                content: const Text(
                  'هل أنت متأكد؟\n'
                  'سيتم حذف الحساب نهائيًا ولا يمكن التراجع عن ذلك.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('حذف'),
                  ),
                ],
              ),
            );

            if (confirmed != true) return;

            final ok = await onDeleteAccount();
            if (!context.mounted) return;

            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف الحساب بنجاح'),
                ),
              );
              context.go(AppRoutes.login);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('حدث خطأ، حاول مرة أخرى'),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          SizeConfig.radius(14),
        ),
        onTap: onTap,
        child: Container(
          padding: SizeConfig.padding(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              SizeConfig.radius(14),
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: SizeConfig.w(12)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
