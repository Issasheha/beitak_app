// lib/features/provider/home/presentation/views/profile/documents/widgets/documents_hint_box.dart

import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class DocumentsHintBox extends StatelessWidget {
  const DocumentsHintBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'متطلبات الوثائق',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(6),

          _bullet('جميع الوثائق مطلوبة ولا يوجد وثائق اختيارية.'),
          _bullet('الهوية الوطنية فقط: مسموح رفع ملفين كحد أقصى (أمامي + خلفي) أو PDF.'),
          _bullet('باقي الوثائق: مسموح رفع ملف واحد فقط (صورة أو PDF).'),
          _bullet('الصيغ المدعومة: PDF, JPG, PNG, WEBP.'),
          _bullet('الحد الأقصى للحجم: 5MB لكل ملف.'),
          _bullet('جميع الوثائق تخضع للمراجعة والموافقة.'),
          _bullet('اضغط على اسم الملف لفتحه داخل التطبيق (للصور).'),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.h(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption11.copyWith(
                fontSize: SizeConfig.ts(11.5),
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
