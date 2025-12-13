// lib/features/auth/presentation/views/widgets/register_header.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class RegisterHeader extends StatelessWidget {
  final VoidCallback? onLoginTap;
  final double fontScale;

  const RegisterHeader({super.key, this.onLoginTap, this.fontScale = 1.0});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isShortHeight = media.size.height < 700;

    final subtitleSize = SizeConfig.ts(isShortHeight ? 13 : 14) * fontScale;
    final logoWidth = SizeConfig.w(isShortHeight ? 52.5 : 60) * fontScale;

    return Column(
      children: [
        SvgPicture.asset('assets/images/Baitak Logo.svg', width: logoWidth),
        const SizedBox(height: 16),

        Text(
          'إنشاء حساب',
          textAlign: TextAlign.center,
          style: AppTextStyles.display28.copyWith(
            // نفس السابق (28) + نفس اللون
            fontSize: SizeConfig.ts(28),
            fontWeight: FontWeight.w700, // كان bold
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => context.push(AppRoutes.login),
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.body14.copyWith(
                fontSize: subtitleSize,
                height: 1.4,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: 'هل لديك حساب بالفعل؟ '),
                TextSpan(
                  text: 'تسجيل الدخول',
                  style: AppTextStyles.body14.copyWith(
                    fontSize: subtitleSize,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightGreen,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkGreen,
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
