import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderQuickActionsRow extends ConsumerWidget {
  const ProviderQuickActionsRow({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProviderQuickActionsRow(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: SizeConfig.padding(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SizeConfig.radius(18)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizeConfig.v(10),

              Text(
                'إجراءات سريعة',
                style: AppTextStyles.title18.copyWith(
                  fontSize: SizeConfig.ts(16.5),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(12),

              _QuickActionTile(
                icon: Icons.design_services_rounded,
                title: 'أضف خدمة',
                subtitle: 'أنشئ خدمة جديدة وابدأ بعرضها للعملاء.',
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.providerAddService);
                },
              ),

              Divider(height: SizeConfig.h(18), color: AppColors.borderLight),

              _QuickActionTile(
                icon: Icons.view_module_rounded,
                title: 'أضف باقة',
                subtitle: 'أنشئ باقة لخدماتك لتسهيل الحجز وزيادة المبيعات.',
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.providerAddPackage);
                },
              ),

              SizeConfig.v(6),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: SizeConfig.padding(vertical: 10),
        child: Row(
          children: [
            Container(
              width: SizeConfig.w(44),
              height: SizeConfig.w(44),
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.lightGreen,
                size: SizeConfig.ts(22),
              ),
            ),
            SizedBox(width: SizeConfig.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.semiBold.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: SizeConfig.ts(14.3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: SizeConfig.ts(12.3),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              size: SizeConfig.ts(22),
            ),
          ],
        ),
      ),
    );
  }
}
