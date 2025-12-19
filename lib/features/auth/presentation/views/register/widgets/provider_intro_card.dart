import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ProviderIntroCard extends StatelessWidget {
  final VoidCallback onStartApplication;

  const ProviderIntroCard({
    super.key,
    required this.onStartApplication,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: SizeConfig.h(8)),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
        boxShadow: [AppColors.primaryShadow],
      ),
      child: Padding(
        padding: SizeConfig.padding(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20,
        ),
        child: Column(
          children: [
            Icon(
              Icons.build_outlined,
              size: SizeConfig.w(40),
              color: AppColors.lightGreen,
            ),
            SizeConfig.v(12),
            Text(
              'انضم كمزوّد خدمة',
              style: TextStyle(
                fontSize: SizeConfig.ts(18),
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizeConfig.v(6),
            Text(
              'أكمل طلب الانضمام بثلاث خطوات بسيطة للانضمام إلى شبكة مزودي خدمات بيتك المعتمدين.',
              style: TextStyle(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizeConfig.v(18),
            _buildStepRow(
              '1',
              'المعلومات الشخصية',
              'بيانات أساسية ومعلومات الاتصال',
            ),
            SizeConfig.v(8),
            _buildStepRow(
              '2',
              'معلومات العمل',
              'تفاصيل عملك والخدمات التي تقدمها',
            ),
            SizeConfig.v(8),
            _buildStepRow(
              '3',
              'التوفر والتحقق',
              'أوقات العمل ومناطق الخدمة ووثائق التحقق',
            ),
            SizeConfig.v(12),
            Text(
              'يستغرق مراجعة الطلب عادة ٢٤–٤٨ ساعة.',
              style: TextStyle(
                fontSize: SizeConfig.ts(11),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizeConfig.v(16),

            // زر التقديم الحقيقي
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.h(12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      SizeConfig.radius(16),
                    ),
                    side: const BorderSide(
                      color: AppColors.buttonBackground,
                      width: 2,
                    ),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'بدء التقديم →',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(15),
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStepRow(
    String step,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: SizeConfig.w(15),
          backgroundColor: AppColors.lightGreen.withValues(alpha: 0.70),
          child: Text(
            step,
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.ts(13),
            ),
          ),
        ),
        SizeConfig.hSpace(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  fontWeight: FontWeight.bold,
                  color: AppColors.buttonBackground,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: SizeConfig.ts(11),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
