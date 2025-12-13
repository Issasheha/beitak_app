// lib/features/user/home/presentation/views/request_service/widgets/share_phone_dialog.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class SharePhoneDialog extends StatelessWidget {
  final String? phone;

  const SharePhoneDialog({super.key, this.phone});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'مشاركة رقم الهاتف؟',
          style: TextStyle(
            fontSize: SizeConfig.ts(17),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'هل تريد إظهار رقم الهاتف لمزوّد الخدمة؟\n'
          'إذا اخترت "لا" سنرسل الطلب بشكل طبيعي لكن بدون إظهار الرقم للمزوّد.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'لا',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'نعم',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
