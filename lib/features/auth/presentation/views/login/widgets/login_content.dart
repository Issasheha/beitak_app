import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/continue_as_guest_button.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/email_password_section.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/login_header.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/send_code_button.dart';
import 'package:flutter/material.dart';

// في ملف login_content.dart
class LoginContent extends StatefulWidget {
  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onMainActionPressed;
  final VoidCallback onContinueAsGuest;
  const LoginContent({
    super.key,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    required this.onMainActionPressed,
    required this.onContinueAsGuest,
  });

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  // تعريف FocusNodes للتركيز التلقائي والتحكم في الإرسال عبر Enter
  final FocusNode _identifierFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // تعريف المتغيرات المفقودة
  static const double _padding = 20.0; // جانبي
  static const double _gap = 16.0; // بين العناصر
  static const double _sectionGap = 24.0; // بين الأقسام الكبيرة

  @override
  void initState() {
    super.initState();
    // Auto-focus على حقل الإيميل/الهاتف عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_identifierFocus);
    });
  }

  @override
  void dispose() {
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmall = mediaQuery.size.width < 360;
    final scale = isSmall ? 0.95 : 1.0;
    return TapRegion(
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverSafeArea(
            sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: _padding).copyWith(
                top: _sectionGap,
                bottom: mediaQuery.viewInsets.bottom + _gap,
              ),
              sliver: SliverList.list(children: [
                // 1. Header
                LoginHeader(fontScale: scale),
                const SizedBox(height: _gap),

                // 3. Description
                _DescriptionText(scale: scale),
                const SizedBox(height: _sectionGap),

                // 4. Input Section (Animated)
                EmailPasswordSection(
                  key: const ValueKey('email'),
                  emailController: widget.emailController,
                  passwordController: widget.passwordController,
                  formKey: widget.formKey,
                  isLoading: widget.isLoading,
                  identifierFocus: _identifierFocus, // مرر FocusNode لحقل الإيميل/الهاتف
                  passwordFocus: _passwordFocus, // مرر FocusNode لحقل كلمة المرور
                  onPasswordSubmitted: widget.onMainActionPressed, // إرسال النموذج عند Enter في كلمة المرور
                ),
                const SizedBox(height: _sectionGap),

                // 5. Main Action Button
                SendCodeButton(
                  onPressed: widget.isLoading ? null : widget.onMainActionPressed,
                  text: 'تسجيل الدخول',
                  isLoading: widget.isLoading,
                ),
                const SizedBox(height: _gap),

                // 6. Continue as Guest
                ContinueAsGuestButton(
                  onPressed: widget.isLoading ? null : widget.onContinueAsGuest,
                ),
                const SizedBox(height: _sectionGap),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final double scale;
  const _DescriptionText({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Text(
      'سجل دخولك باستخدام البريد الإلكتروني أو رقم الهاتف وكلمة المرور',
      textAlign: TextAlign.center,
      style: AppTextStyles.body14.copyWith(
        color: AppColors.textSecondary,
        fontSize: 15 * scale, // نفس الحجم اللي كان موجود
        height: 1.5,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w700, // كان Bold، نخليه Bold حقيقي
      ),
    );
  }
}
