// lib/features/user/home/presentation/views/request_service/widgets/success_dialog.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Icon(Icons.check_circle, color: AppColors.lightGreen, size: 48),
        content: Text(
          'تم إرسال طلب الخدمة بنجاح ✅',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeConfig.ts(15),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                padding: SizeConfig.padding(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                'حسنًا',
                style: TextStyle(
                  fontSize: SizeConfig.ts(14),
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
