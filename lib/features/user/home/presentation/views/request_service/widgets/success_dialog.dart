// lib/features/home/presentation/views/request_widgets/success_dialog.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGreen.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.check, size: 70, color: AppColors.lightGreen),
          ),
          const SizedBox(height: 32),
          Text(
            'تم إرسال الطلب!',
            style: TextStyle(fontSize: SizeConfig.ts(24), fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
         const  SizedBox(height: 16),
          Padding(
            padding: SizeConfig.padding(horizontal: 32),
            child: Text(
              'طلبك قيد المراجعة. سنتواصل معك عبر الرسائل النصية قريبًا للخطوات التالية.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: SizeConfig.ts(15), color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightGreen,
              padding: SizeConfig.padding(horizontal: 50, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('العودة للرئيسية', style: TextStyle(fontSize: SizeConfig.ts(16), color: Colors.white)),
          ),
         const  SizedBox(height: 24),
        ],
      ),
    );
  }
}