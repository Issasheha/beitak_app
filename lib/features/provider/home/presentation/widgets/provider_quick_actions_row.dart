import 'dart:ui';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderQuickActionsRow extends StatelessWidget {
  const ProviderQuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(16))),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.white.withValues(alpha: 0.25),
          padding: SizeConfig.padding(all: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إجراءات سريعة',
                style: AppTextStyles.title18.copyWith(
                  fontSize: SizeConfig.ts(18),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    context,
                    'إنشاء خدمة جديدة',
                    Icons.design_services_rounded,
                    () {
                      Navigator.pop(context);
                      context.push(AppRoutes.providerAddService);
                    },
                  ),
                  _actionButton(
                    context,
                    'إضافة باقة',
                    Icons.view_module_rounded,
                    () {
                      Navigator.pop(context);
                      context.push(AppRoutes.providerAddPackage);
                    },
                  ),
                ],
              ),
              SizeConfig.v(16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: SizeConfig.w(30),
            backgroundColor: AppColors.lightGreen,
            child: Icon(icon, color: Colors.white, size: SizeConfig.ts(22)),
          ),
          SizeConfig.v(8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body16.copyWith(
              fontSize: SizeConfig.ts(13.5),
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
