import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.radius(16)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: AppColors.white.withValues(alpha: 0.20),
            padding: SizeConfig.padding(all: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'إجراءات سريعة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenTitle.copyWith(
                    fontSize: SizeConfig.ts(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizeConfig.v(14),

                _quickTile(
                  context,
                  title: 'احجز خدمة',
                  subtitle: 'اختر مزود خدمة واحجز مباشرة',
                  icon: Icons.receipt_long,
                  iconBg: AppColors.lightGreen.withValues(alpha: 0.18),
                  iconColor: AppColors.lightGreen,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.requestService);
                  },
                ),
                SizeConfig.v(12),
                _quickTile(
                  context,
                  title: 'ارسل طلب',
                  subtitle: 'ارسل طلب مع تحديد ميزانيتك',
                  icon: Icons.add,
                  iconBg: AppColors.lightGreen.withValues(alpha: 0.18),
                  iconColor: AppColors.lightGreen,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.search);
                  },
                ),

                SizeConfig.v(12),
                SafeArea(top: false, child: SizedBox(height: SizeConfig.h(2))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
          onTap: onTap,
          child: Container(
            padding: SizeConfig.padding(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.60),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: SizeConfig.ts(16),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizeConfig.v(4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.helper.copyWith(
                          fontSize: SizeConfig.ts(12.5),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SizeConfig.w(12)),
                Container(
                  width: SizeConfig.w(44),
                  height: SizeConfig.w(44),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: SizeConfig.ts(22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
