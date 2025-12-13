import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class LoginHeader extends StatelessWidget {
  final double fontScale;

  const LoginHeader({super.key, this.fontScale = 1.0});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isShortHeight = media.size.height < 700;

    // حجم اللوجو: قلّلناه عن السابق + مختلف للأجهزة القصيرة
    final logoWidth = SizeConfig.w(isShortHeight ? 52.5 : 60) * fontScale;

    // حجم العنوان والنص الفرعي
    final titleSize = SizeConfig.ts(isShortHeight ? 20 : 22) * fontScale;
    final subtitleSize = SizeConfig.ts(isShortHeight ? 13 : 14) * fontScale;

    // المسافات بين العناصر
    final betweenLogoAndTitle =
        SizeConfig.h(isShortHeight ? 10 : 14) * fontScale;
    final betweenTitleAndSubtitle =
        SizeConfig.h(isShortHeight ? 5.5 : 7) * fontScale;

    return Column(
      children: [
        // اللوجو
        SvgPicture.asset(
          'assets/images/Baitak Logo.svg',
          width: logoWidth,
        ),

        // مسافة بين اللوجو والعنوان
        SizedBox(height: betweenLogoAndTitle),

        // العنوان
        Text(
          'مرحبا بعودتك',
          style: AppTextStyles.title18.copyWith(
            fontSize: titleSize,
            fontWeight: FontWeight.w900, // نفس السابق
            color: AppColors.textSecondary,
          ),
        ),

        // مسافة بين العنوان والجملة الثانية
        SizedBox(height: betweenTitleAndSubtitle),

        // جملة التسجيل
        GestureDetector(
          onTap: () => context.push(AppRoutes.register),
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.body14.copyWith(
                fontSize: subtitleSize,
                height: 1.4,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400, // Regular default
              ),
              children: [
                const TextSpan(text: 'ما عندك حساب؟ '),
                TextSpan(
                  text: 'سجّل من هنا',
                  style: AppTextStyles.body14.copyWith(
                    fontSize: subtitleSize,
                    color: AppColors.lightGreen,
                    fontWeight: FontWeight.w700, // Bold مثل السابق
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkGreen,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
