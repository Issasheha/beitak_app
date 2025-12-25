import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

enum ProviderActivationMode { activate, deactivate }

class ProviderAccountActivationDialog extends StatelessWidget {
  final ProviderActivationMode mode;

  const ProviderAccountActivationDialog({
    super.key,
    required this.mode,
  });

  bool get isActivate => mode == ProviderActivationMode.activate;

  @override
  Widget build(BuildContext context) {
    final title = isActivate ? 'تفعيل الحساب؟' : 'تعطيل الحساب؟';

    final subtitle = isActivate
        ? 'عند تفعيل حسابك:'
        : 'عند تعطيل حسابك:';

    final bullets = isActivate
        ? const [
            'سيظهر ملفك للعملاء داخل التطبيق',
            'ستتمكن من استقبال طلبات حجز جديدة',
            'ستظهر خدماتك في نتائج البحث',
          ]
        : const [
            'لن يظهر ملفك للعملاء داخل التطبيق',
            'لن تستقبل طلبات حجز جديدة',
            'يمكنك إعادة التفعيل لاحقًا بنفس الزر',
          ];

    final confirmText = isActivate ? 'نعم، فعّل' : 'نعم، عطّل';

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
      ),
      titlePadding: SizeConfig.padding(horizontal: 16, vertical: 14),
      contentPadding: SizeConfig.padding(horizontal: 16, vertical: 0),
      actionsPadding: SizeConfig.padding(horizontal: 12, vertical: 12),
      title: Row(
        children: [
          Icon(
            isActivate ? Icons.check_circle_outline : Icons.pause_circle_outline,
            color: isActivate ? AppColors.lightGreen : const Color(0xFFE53935),
          ),
          SizeConfig.hSpace(10),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body16.copyWith(
                fontSize: SizeConfig.ts(16),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Padding(
        padding: SizeConfig.padding(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            SizeConfig.v(10),
            ...bullets.map((t) => _Bullet(text: t)),
            SizeConfig.v(6),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'إلغاء',
            style: AppTextStyles.body14.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.h(42),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isActivate ? AppColors.lightGreen : const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: AppTextStyles.body14.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.h(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(12.8),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
