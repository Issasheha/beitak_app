// lib/features/auth/presentation/views/widgets/register_header.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
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

    // حجم اللوجو: قلّلناه عن السابق + مختلف للأجهزة القصيرة
    final logoWidth = SizeConfig.w(isShortHeight ? 52.5 : 60) * fontScale;
    return Column(
      children: [
        SvgPicture.asset('assets/images/Baitak Logo.svg', width: logoWidth),
        const SizedBox(height: 16),
        const Text(
          'إنشاء حساب',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        GestureDetector(
  onTap: () => context.push(AppRoutes.login),
  child: RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: subtitleSize,
        fontFamily: 'Cairo', // أو أي خط تستخدمه في التطبيق
        height: 1.4,
      ),
      children: [
        const TextSpan(
          text: 'هل لديك حساب بالفعل؟ ',
          style: TextStyle(
            color: AppColors.textSecondary, // اللون الرمادي الفاتح العادي
          ),
        ),
        TextSpan(
          text: 'تسجيل الدخول',
          style: TextStyle(
            color: AppColors.lightGreen,           // لون أخضر قوي وواضح (أو استخدم goldAccent لو حابب ذهبي)
            fontSize: subtitleSize,         // أكبر شوي من باقي النص
            fontWeight: FontWeight.bold,          // جريء عشان يبرز أكثر
            decoration: TextDecoration.underline, // خط تحت الكلمة (اختياري)
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
