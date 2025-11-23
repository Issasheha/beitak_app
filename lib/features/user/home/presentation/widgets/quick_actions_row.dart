import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart'; // Assuming AppColors is in colors.dart, adjust if needed
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(16))),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.white.withValues(alpha: 0.2),
          padding: SizeConfig.padding(all: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إجراءات سريعة',
                style: TextStyle(
                    fontSize: SizeConfig.ts(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              SizeConfig.v(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(context, 'طلب خدمة', Icons.request_page, () {
                    Navigator.pop(context);
                    context.go(AppRoutes.requestService);
                  }),
                  _actionButton(context, 'تصفح الخدمات', Icons.search, () {
                    Navigator.pop(context);
                    context.go(AppRoutes.browseServices);
                  }),
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
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: SizeConfig.w(30),
            backgroundColor: AppColors.lightGreen,
            child: Icon(icon, color: AppColors.white, size: SizeConfig.ts(24)),
          ),
          SizeConfig.v(8),
          Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.ts(14), color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
