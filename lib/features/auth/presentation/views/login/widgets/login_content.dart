import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/continue_as_guest_button.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/email_password_section.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/login_header.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/send_code_button.dart';

class LoginContent extends StatefulWidget {
  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onMainActionPressed;
  final VoidCallback onContinueAsGuest;

  /// ✅ خطأ عام داخل الفورم
  final String? formErrorText;

  /// ✅ أخطاء تحت الحقول
  final String? identifierErrorText;
  final String? passwordErrorText;

  /// ✅ لمسح الأخطاء عند الكتابة
  final VoidCallback? onClearIdentifierError;
  final VoidCallback? onClearPasswordError;

  const LoginContent({
    super.key,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    required this.onMainActionPressed,
    required this.onContinueAsGuest,
    this.formErrorText,
    this.identifierErrorText,
    this.passwordErrorText,
    this.onClearIdentifierError,
    this.onClearPasswordError,
  });

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final FocusNode _identifierFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
    final mq = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;

    // ✅ تظبيط الـscale والمسافات حسب الوضع
    final double scale = isLandscape ? 0.88 : (mq.size.width < 360 ? 0.95 : 1.0);

    final double horizontalPadding = isLandscape ? 16.0 : 20.0;
    final double gap = isLandscape ? 10.0 : 16.0;
    final double sectionGap = isLandscape ? 14.0 : 24.0;

    // ✅ max width عشان ما يتمدد المحتوى كثير بالـLandscape
    final double maxContentWidth = isLandscape ? 560 : 520;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverSafeArea(
            sliver: SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding).copyWith(
                top: sectionGap,
                bottom: mq.viewInsets.bottom + gap,
              ),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxContentWidth,
                      // ✅ مهم: ما نخلي الارتفاع يضرب layout
                      minHeight: math.max(0, mq.size.height - mq.padding.top - mq.padding.bottom),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1) Header
                        LoginHeader(fontScale: scale),
                        SizedBox(height: gap),

                        // 2) Description
                        _DescriptionText(scale: scale),
                        SizedBox(height: sectionGap),

                        // 3) Inputs
                        EmailPasswordSection(
                          key: const ValueKey('email'),
                          emailController: widget.emailController,
                          passwordController: widget.passwordController,
                          formKey: widget.formKey,
                          isLoading: widget.isLoading,
                          identifierFocus: _identifierFocus,
                          passwordFocus: _passwordFocus,
                          onPasswordSubmitted: widget.onMainActionPressed,

                          identifierErrorText: widget.identifierErrorText,
                          passwordErrorText: widget.passwordErrorText,
                          onIdentifierChanged: widget.onClearIdentifierError,
                          onPasswordChanged: widget.onClearPasswordError,
                        ),

                        // ✅ خطأ عام (شبكة/غيره) داخل الشاشة وما يتكسر بالـLandscape
                        if (widget.formErrorText != null &&
                            widget.formErrorText!.trim().isNotEmpty) ...[
                          SizedBox(height: SizeConfig.h(isLandscape ? 10 : 12)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget.formErrorText!,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.caption11.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: sectionGap),

                        // 4) Main Button
                        SendCodeButton(
                          onPressed: widget.isLoading ? null : widget.onMainActionPressed,
                          text: 'تسجيل الدخول',
                          isLoading: widget.isLoading,
                        ),
                        SizedBox(height: gap),

                        // 5) Continue as Guest
                        ContinueAsGuestButton(
                          onPressed: widget.isLoading ? null : widget.onContinueAsGuest,
                        ),

                        SizedBox(height: sectionGap),
                      ],
                    ),
                  ),
                ),
              ),
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
        fontSize: 15 * scale,
        height: 1.5,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
